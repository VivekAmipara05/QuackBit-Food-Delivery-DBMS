-- ==========================================================
-- R1: Which Bangalore customers ordered from restaurants
--     also located in Bangalore?
--     Business use: Hyperlocal marketing -- target users who
--     order within their own city for same-day promos.
-- ==========================================================
SELECT DISTINCT
    u.UserID,
    u.User_Name,
    u.Email,
    r.Name                              AS restaurant_name,
    ra.City                             AS restaurant_city
FROM Users u
JOIN User_Has_Address uha ON u.UserID = uha.UserID
JOIN User_Address     ua  ON uha.Add_ID = ua.Add_ID
JOIN Orders           o   ON u.UserID = o.UserID
JOIN Restaurant       r   ON o.Restaurant_ID = r.Restaurant_ID
JOIN Restaurant_Address ra ON r.Restaurant_ID = ra.Restaurant_ID
WHERE ua.City = 'Bangalore'
  AND ra.City = 'Bangalore'
ORDER BY u.User_Name, r.Name;


-- ==========================================================
-- R2: Orders where payment amount does not match order total
--     (after discount) -- reconciliation report.
--     Business use: Finance audit -- catch billing mismatches
--     before month-end close.
-- ==========================================================
SELECT
    o.OrderID,
    o.Total_Amount                      AS order_total,
    COALESCE(disc.Discount_Amount, 0)   AS discount_applied,
    o.Total_Amount - COALESCE(disc.Discount_Amount, 0)
                                        AS expected_payment,
    p.Amount                            AS amount_paid,
    p.Mode                              AS payment_mode,
    p.Status                            AS payment_status,
    ABS(p.Amount - (o.Total_Amount - COALESCE(disc.Discount_Amount, 0)))
                                        AS discrepancy
FROM Orders o
JOIN Payment p ON o.OrderID = p.Order_ID
LEFT JOIN Discount disc ON o.OrderID = disc.OrderID
WHERE ABS(p.Amount - (o.Total_Amount - COALESCE(disc.Discount_Amount, 0))) > 0.01
ORDER BY discrepancy DESC;


-- ==========================================================
-- R3: Delivery partners who took longer than 45 minutes
--     on any completed delivery.
--     Business use: SLA breach alerts -- warn or retrain
--     partners exceeding the delivery window.
-- ==========================================================
SELECT DISTINCT
    dp.Partner_ID,
    dp.Name                             AS partner_name,
    dp.Phone_No,
    d.Delivery_ID,
    d.OrderID,
    d.Pickup_Time,
    d.Delivery_Time,
    TIMESTAMPDIFF(MINUTE, d.Pickup_Time, d.Delivery_Time)
                                        AS transit_minutes
FROM Delivery_Partner dp
JOIN Delivery d ON dp.Partner_ID = d.Partner_ID
WHERE d.Status = 'Delivered'
  AND d.Delivery_Time IS NOT NULL
  AND d.Pickup_Time   IS NOT NULL
  AND TIMESTAMPDIFF(MINUTE, d.Pickup_Time, d.Delivery_Time) > 45
ORDER BY transit_minutes DESC;


-- ==========================================================
-- R4: Restaurants with open complaints but rating still
--     above 4.0.
--     Business use: Quality monitoring -- high-rated partners
--     with unresolved issues need proactive outreach.
-- ==========================================================
SELECT
    r.Restaurant_ID,
    r.Name                              AS restaurant_name,
    r.Rating                            AS cached_rating,
    COUNT(DISTINCT comp.Complaint_ID)   AS open_complaints
FROM Restaurant r
JOIN Orders    o    ON r.Restaurant_ID = o.Restaurant_ID
JOIN Complaint comp ON o.OrderID = comp.OrderID
WHERE r.Rating > 4.0
  AND comp.Status IN ('Open', 'Under Review')
GROUP BY r.Restaurant_ID, r.Name, r.Rating
ORDER BY open_complaints DESC, r.Rating DESC;


-- ==========================================================
-- R5: Customers with abandoned carts worth more than Rs 500.
--     Business use: Re-engagement push -- "Complete your
--     order!" notification for high-value abandoned carts.
-- ==========================================================
SELECT
    u.UserID,
    u.User_Name,
    u.Email,
    c.Cart_ID,
    c.Created_At                        AS cart_created,
    SUM(mi.Price * ci.Quantity)         AS cart_value
FROM Cart c
JOIN Users     u  ON c.UserID   = u.UserID
JOIN Cart_Item ci ON c.Cart_ID  = ci.Cart_ID
JOIN Menu_Item mi ON ci.Item_ID = mi.Item_ID
WHERE c.Status = 'Abandoned'
GROUP BY u.UserID, u.User_Name, u.Email, c.Cart_ID, c.Created_At
HAVING SUM(mi.Price * ci.Quantity) > 500
ORDER BY cart_value DESC;


-- ==========================================================
-- R6: Payment mode split -- Wallet vs UPI for March 2026.
--     Business use: Payment ops -- track wallet adoption vs
--     UPI for cashback budget planning.
-- ==========================================================
SELECT
    p.Mode                              AS payment_mode,
    COUNT(*)                            AS transaction_count,
    SUM(p.Amount)                       AS total_collected,
    ROUND(100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM Payment p2
         JOIN Orders o2 ON p2.Order_ID = o2.OrderID
         WHERE p2.Status = 'Paid'
           AND o2.Date_Time >= '2026-03-01'
           AND o2.Date_Time <  '2026-04-01'), 2)
                                        AS pct_share
FROM Payment p
JOIN Orders o ON p.Order_ID = o.OrderID
WHERE p.Status = 'Paid'
  AND p.Mode IN ('Wallet', 'UPI')
  AND o.Date_Time >= '2026-03-01'
  AND o.Date_Time <  '2026-04-01'
GROUP BY p.Mode
ORDER BY total_collected DESC;


-- ==========================================================
-- R7: Best-selling menu items at inactive restaurants.
--     Business use: Partner ops -- decide whether to reactivate
--     a closed restaurant based on past demand.
-- ==========================================================
SELECT
    r.Restaurant_ID,
    r.Name                              AS restaurant_name,
    mi.Item_ID,
    mi.Item_Name,
    SUM(oi.Quantity)                    AS total_qty_sold,
    SUM(oi.Unit_Price * oi.Quantity)    AS total_revenue
FROM Restaurant r
JOIN Menu_Item  mi ON r.Restaurant_ID = mi.Restaurant_ID
JOIN Order_Item oi ON mi.Item_ID      = oi.Item_ID
WHERE r.Restaurant_Status = FALSE
GROUP BY r.Restaurant_ID, r.Name, mi.Item_ID, mi.Item_Name
ORDER BY total_qty_sold DESC;


-- ==========================================================
-- R8: Pending refunds older than 24 hours.
--     Business use: CX escalation -- chase finance team on
--     refunds stuck in Pending status.
-- ==========================================================
SELECT
    ref.Refund_ID,
    ref.OrderID,
    u.User_Name                         AS customer,
    comp.Issue_Type,
    ref.Refund_Amount,
    comp.Created_At                     AS complaint_raised,
    TIMESTAMPDIFF(HOUR, comp.Created_At, NOW())
                                        AS hours_pending
FROM Refund ref
JOIN Complaint comp ON ref.Complaint_ID = comp.Complaint_ID
JOIN Orders    o    ON ref.OrderID      = o.OrderID
JOIN Users     u    ON o.UserID         = u.UserID
WHERE ref.Refund_Status = 'Pending'
  AND TIMESTAMPDIFF(HOUR, comp.Created_At, NOW()) > 24
ORDER BY hours_pending DESC;


-- ==========================================================
-- R9: Top 3 VIP loyalty candidates -- highest lifetime spend
--     with at least 2 orders.
--     Business use: Loyalty program -- invite top spenders
--     to VIP tier with exclusive perks.
-- ==========================================================
SELECT
    u.UserID,
    u.User_Name,
    u.Email,
    COUNT(o.OrderID)                    AS total_orders,
    SUM(o.Total_Amount)                 AS lifetime_spend
FROM Users u
JOIN Orders o ON u.UserID = o.UserID
WHERE o.Status != 'cancelled'
GROUP BY u.UserID, u.User_Name, u.Email
HAVING COUNT(o.OrderID) >= 2
ORDER BY lifetime_spend DESC
LIMIT 3;


-- ==========================================================
-- R10: Restaurants open after 11 PM with at least one
--      delivered order.
--     Business use: Late-night homepage curation -- feature
--     partners still serving after 11 PM.
-- ==========================================================
SELECT
    r.Restaurant_ID,
    r.Name                              AS restaurant_name,
    r.Open_Time,
    r.Close_Time,
    COUNT(DISTINCT o.OrderID)           AS delivered_orders
FROM Restaurant r
JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID
WHERE r.Close_Time > '23:00:00'
  AND o.Status = 'delivered'
GROUP BY r.Restaurant_ID, r.Name, r.Open_Time, r.Close_Time
ORDER BY delivered_orders DESC;
