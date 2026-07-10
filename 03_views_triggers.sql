DELIMITER $$

CREATE TRIGGER trg_update_restaurant_rating_insert
AFTER INSERT ON Review
FOR EACH ROW
BEGIN
    UPDATE Restaurant
    SET Rating = (
        SELECT ROUND(AVG(Rating), 2)
        FROM Review
        WHERE Restaurant_ID = NEW.Restaurant_ID
    )
    WHERE Restaurant_ID = NEW.Restaurant_ID;
END$$

CREATE TRIGGER trg_update_restaurant_rating_update
AFTER UPDATE ON Review
FOR EACH ROW
BEGIN
    UPDATE Restaurant
    SET Rating = (
        SELECT ROUND(AVG(Rating), 2)
        FROM Review
        WHERE Restaurant_ID = NEW.Restaurant_ID
    )
    WHERE Restaurant_ID = NEW.Restaurant_ID;
END$$

CREATE TRIGGER trg_update_restaurant_rating_delete
AFTER DELETE ON Review
FOR EACH ROW
BEGIN
    UPDATE Restaurant
    SET Rating = COALESCE(
        (SELECT ROUND(AVG(Rating), 2) FROM Review WHERE Restaurant_ID = OLD.Restaurant_ID),
        0.0
    )
    WHERE Restaurant_ID = OLD.Restaurant_ID;
END$$

CREATE TRIGGER trg_wallet_credit_on_refund
AFTER UPDATE ON Refund
FOR EACH ROW
BEGIN
    IF NEW.Refund_Status = 'Completed' AND OLD.Refund_Status != 'Completed' THEN
        UPDATE Wallet
        SET Balance = Balance + NEW.Refund_Amount
        WHERE Wallet_ID = NEW.Wallet_ID;

        INSERT INTO Wallet_Transaction (Wallet_ID, Type, Amount)
        VALUES (NEW.Wallet_ID, 'Credit', NEW.Refund_Amount);
    END IF;
END$$

CREATE TRIGGER trg_wallet_debit_on_payment
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    DECLARE v_wallet_id INT;
    DECLARE v_balance   DECIMAL(10,2);

    IF NEW.Mode = 'Wallet' AND NEW.Status = 'Paid' THEN
        SELECT Wallet_ID, Balance
        INTO   v_wallet_id, v_balance
        FROM   Wallet
        WHERE  UserID = (SELECT UserID FROM Orders WHERE OrderID = NEW.Order_ID);

        IF v_balance < NEW.Amount THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Insufficient wallet balance.';
        END IF;

        UPDATE Wallet
        SET Balance = Balance - NEW.Amount
        WHERE Wallet_ID = v_wallet_id;

        INSERT INTO Wallet_Transaction (Wallet_ID, Type, Amount)
        VALUES (v_wallet_id, 'Debit', NEW.Amount);
    END IF;
END$$

CREATE OR REPLACE VIEW v_order_summary AS
SELECT
    o.OrderID,
    o.Date_Time,
    o.Status                                    AS order_status,
    o.Total_Amount,

    u.UserID,
    u.User_Name                                 AS customer_name,
    u.Email                                     AS customer_email,

    r.Restaurant_ID,
    r.Name                                      AS restaurant_name,

    p.Transaction_ID                            AS payment_id,
    p.Mode                                      AS payment_mode,
    p.Status                                    AS payment_status,
    p.Amount                                    AS amount_paid,
    p.Paid_At,

    d.Delivery_ID,
    d.Status                                    AS delivery_status,
    d.Pickup_Time,
    d.Delivery_Time,

    dp.Name                                     AS partner_name,
    dp.Phone_No                                 AS partner_phone,

    COALESCE(disc.Discount_PR, 0)               AS discount_pct,
    COALESCE(disc.Discount_Amount, 0)           AS discount_amount

FROM Orders o
JOIN Users            u    ON o.UserID        = u.UserID
JOIN Restaurant       r    ON o.Restaurant_ID = r.Restaurant_ID
LEFT JOIN Payment     p    ON o.OrderID       = p.Order_ID
LEFT JOIN Delivery    d    ON o.OrderID       = d.OrderID
LEFT JOIN Delivery_Partner dp ON d.Partner_ID = dp.Partner_ID
LEFT JOIN Discount    disc ON o.OrderID       = disc.OrderID$$

CREATE OR REPLACE VIEW v_restaurant_leaderboard AS
SELECT
    r.Restaurant_ID,
    r.Name                                          AS restaurant_name,
    r.Rating                                        AS avg_rating,
    r.Restaurant_Status                             AS is_active,
    COUNT(DISTINCT rev.Review_ID)                   AS total_reviews,
    COUNT(DISTINCT o.OrderID)                       AS total_orders,
    ROUND(
        SUM(CASE WHEN p.Status = 'Paid' THEN p.Amount ELSE 0 END), 2
    )                                               AS total_revenue,
    COUNT(DISTINCT CASE
        WHEN o.Status = 'cancelled' THEN o.OrderID
    END)                                            AS cancelled_orders
FROM Restaurant r
LEFT JOIN Review       rev ON r.Restaurant_ID = rev.Restaurant_ID
LEFT JOIN Orders       o   ON r.Restaurant_ID = o.Restaurant_ID
LEFT JOIN Payment      p   ON o.OrderID       = p.Order_ID
GROUP BY r.Restaurant_ID, r.Name, r.Rating, r.Restaurant_Status
ORDER BY avg_rating DESC, total_orders DESC$$

CREATE OR REPLACE VIEW v_menu_with_category AS
SELECT
    mi.Item_ID,
    mi.Item_Name,
    mi.Description,
    mi.Price,
    mi.Preparation_Time,
    mi.Is_Available,
    mi.Category_Name,
    mc.Type                 AS category_type,
    mi.Restaurant_ID
FROM Menu_Item mi
JOIN Menu_Category mc ON mi.Category_Name = mc.Category_Name
                     AND mi.Restaurant_ID  = mc.Restaurant_ID
ORDER BY mi.Restaurant_ID, mi.Category_Name, mi.Item_Name$$

CREATE PROCEDURE place_order(
    IN  p_user_id          INT,
    IN  p_cart_id          INT,
    IN  p_payment_mode     VARCHAR(50),
    IN  p_delivery_address VARCHAR(255),
    OUT p_order_id         INT
)
BEGIN
    DECLARE v_restaurant_id  INT;
    DECLARE v_total          DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_unavailable    INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM Cart
        WHERE Cart_ID = p_cart_id AND UserID = p_user_id AND Status = 'Active'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No active cart found for this user.';
    END IF;

    SELECT COUNT(*) INTO v_unavailable
    FROM Cart_Item ci
    JOIN Menu_Item mi ON ci.Item_ID = mi.Item_ID
    WHERE ci.Cart_ID = p_cart_id AND mi.Is_Available = FALSE;

    IF v_unavailable > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'One or more cart items are currently unavailable.';
    END IF;

    SELECT
        SUM(mi.Price * ci.Quantity),
        MAX(mi.Restaurant_ID)
    INTO v_total, v_restaurant_id
    FROM Cart_Item ci
    JOIN Menu_Item mi ON ci.Item_ID = mi.Item_ID
    WHERE ci.Cart_ID = p_cart_id;

    INSERT INTO Orders (UserID, Restaurant_ID, Status, Total_Amount)
    VALUES (p_user_id, v_restaurant_id, 'pending', v_total);

    SET p_order_id = LAST_INSERT_ID();

    INSERT INTO Order_Item (Item_ID, OrderID, Quantity, Unit_Price)
    SELECT ci.Item_ID, p_order_id, ci.Quantity, mi.Price
    FROM Cart_Item ci
    JOIN Menu_Item mi ON ci.Item_ID = mi.Item_ID
    WHERE ci.Cart_ID = p_cart_id;

    UPDATE Cart SET Status = 'Checked Out' WHERE Cart_ID = p_cart_id;

    COMMIT;
END$$

DELIMITER ;
