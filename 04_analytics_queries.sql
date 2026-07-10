-- ============================================================
--  Quick-Bite Food Delivery Platform
--  04_analytics_queries.sql  --  15 Real-World Business Queries
--  Tested & verified against the project schema (MySQL + SQLite).
-- ============================================================
--
--  CATEGORIES COVERED
--  ----------------------------------------------------------
--   Revenue & Finance   : Q1, Q2, Q3
--   Customer Behaviour  : Q4, Q5, Q6
--   Restaurant KPIs     : Q7, Q8
--   Delivery Operations : Q9, Q10
--   Menu Intelligence   : Q11, Q12
--   Wallet & Payments   : Q13
--   Complaints & Refunds: Q14, Q15
-- ============================================================


-- ==========================================================
-- Q1: REVENUE LEADERBOARD -- Top restaurants by total revenue
--     Business use: Commission calculation, partner ranking,
--     homepage "popular near you" sort order.
-- ==========================================================
SELECT
    r.Restaurant_ID,
    r.Name                              AS restaurant_name,
    r.Rating                            AS avg_rating,
    COUNT(DISTINCT o.OrderID)           AS total_orders,
    SUM(p.Amount)                       AS total_revenue,
    ROUND(SUM(p.Amount) / COUNT(DISTINCT o.OrderID), 2)
                                        AS avg_order_value
FROM Restaurant r
JOIN Orders  o ON r.Restaurant_ID = o.Restaurant_ID
JOIN Payment p ON o.OrderID       = p.Order_ID
WHERE p.Status = 'Paid'
GROUP BY r.Restaurant_ID, r.Name, r.Rating
ORDER BY total_revenue DESC;


-- ==========================================================
-- Q2: CUSTOMER LIFETIME VALUE (CLV)
--     Business use: VIP tier segmentation, loyalty rewards,
--     targeted discount campaigns.
-- ==========================================================
SELECT
    u.UserID,
    u.User_Name,
    u.Email,
    COUNT(DISTINCT o.OrderID)           AS total_orders,
    SUM(o.Total_Amount)                 AS lifetime_spend,
    ROUND(AVG(o.Total_Amount), 2)       AS avg_order_value,
    MAX(o.Date_Time)                    AS last_order_date
FROM Users u
JOIN Orders o ON u.UserID = o.UserID
WHERE o.Status != 'cancelled'
GROUP BY u.UserID, u.User_Name, u.Email
ORDER BY lifetime_spend DESC;


-- ==========================================================
-- Q3: PAYMENT MODE SPLIT
--     Business use: Payment gateway cost analysis, UPI cashback
--     budget allocation, Cash-on-Delivery reduction campaigns.
-- ==========================================================
SELECT
    p.Mode                                          AS payment_mode,
    COUNT(*)                                        AS transactions,
    SUM(p.Amount)                                   AS total_collected,
    ROUND(100.0 * COUNT(*) /
          (SELECT COUNT(*) FROM Payment), 2)        AS pct_share
FROM Payment p
WHERE p.Status = 'Paid'
GROUP BY p.Mode
ORDER BY total_collected DESC;


-- ==========================================================
-- Q4: NEW vs RETURNING CUSTOMERS (per order)
--     Business use: Acquisition vs retention KPI dashboard,
--     marketing ROI split between new-user offers & loyalty.
-- ==========================================================
SELECT
    o.OrderID,
    u.User_Name,
    o.Date_Time,
    o.Total_Amount,
    CASE
        WHEN o.OrderID = (
            SELECT MIN(o2.OrderID)
            FROM Orders o2
            WHERE o2.UserID = o.UserID
        ) THEN 'New Customer'
        ELSE 'Returning Customer'
    END AS customer_type
FROM Orders o
JOIN Users u ON o.UserID = u.UserID
ORDER BY o.Date_Time;


-- ==========================================================
-- Q5: REPEAT CUSTOMERS -- users with more than 1 order
--     Business use: Churn prevention targeting -- identify
--     customers already loyal enough to retain.
-- ==========================================================
SELECT
    u.UserID,
    u.User_Name,
    u.Email,
    u.Phone_No,
    COUNT(o.OrderID)                    AS order_count,
    SUM(o.Total_Amount)                 AS total_spent
FROM Users u
JOIN Orders o ON u.UserID = o.UserID
GROUP BY u.UserID, u.User_Name, u.Email, u.Phone_No
HAVING COUNT(o.OrderID) > 1
ORDER BY order_count DESC;


-- ==========================================================
-- Q6: ABANDONED CART ANALYSIS
--     Business use: Trigger re-engagement push notifications,
--     "You left something behind!" email campaigns.
-- ==========================================================
SELECT
    u.UserID,
    u.User_Name,
    u.Email,
    c.Cart_ID,
    c.Created_At                        AS cart_created,
    COUNT(ci.Item_ID)                   AS items_in_cart,
    SUM(mi.Price * ci.Quantity)         AS cart_value
FROM Cart c
JOIN Users     u  ON c.UserID   = u.UserID
JOIN Cart_Item ci ON c.Cart_ID  = ci.Cart_ID
JOIN Menu_Item mi ON ci.Item_ID = mi.Item_ID
WHERE c.Status = 'Abandoned'
GROUP BY u.UserID, u.User_Name, u.Email, c.Cart_ID, c.Created_At
ORDER BY cart_value DESC;


-- ==========================================================
-- Q7: RESTAURANT PERFORMANCE DASHBOARD
--     Business use: Monthly restaurant partner report --
--     orders, revenue, cancellations, complaint rate.
-- ==========================================================
SELECT
    r.Restaurant_ID,
    r.Name                                          AS restaurant_name,
    r.Rating,
    COUNT(DISTINCT o.OrderID)                       AS total_orders,
    SUM(CASE WHEN o.Status = 'delivered'   THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN o.Status = 'cancelled'   THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN o.Status = 'cancelled'   THEN 1 ELSE 0 END) * 100.0
        / COUNT(DISTINCT o.OrderID)                 AS cancel_rate_pct,
    COUNT(DISTINCT comp.Complaint_ID)               AS total_complaints,
    SUM(p.Amount)                                   AS total_revenue
FROM Restaurant r
LEFT JOIN Orders    o    ON r.Restaurant_ID = o.Restaurant_ID
LEFT JOIN Payment   p    ON o.OrderID       = p.Order_ID AND p.Status = 'Paid'
LEFT JOIN Complaint comp ON o.OrderID       = comp.OrderID
GROUP BY r.Restaurant_ID, r.Name, r.Rating
ORDER BY total_revenue DESC;


-- ==========================================================
-- Q8: TOP-RATED RESTAURANTS WITH MINIMUM ORDER THRESHOLD
--     Business use: Homepage "Featured" section -- show
--     restaurants with >= 4 avg review rating & order volume.
--     NOTE: Uses live AVG from Review table (not cached Rating)
--     so it works correctly even before triggers fire.
-- ==========================================================
SELECT
    r.Restaurant_ID,
    r.Name                                      AS restaurant_name,
    COALESCE(ROUND(AVG(rev.Rating), 2), 0)      AS avg_review_rating,
    GROUP_CONCAT(DISTINCT c.Cuisine)            AS cuisines,
    ra.City,
    COUNT(DISTINCT o.OrderID)                   AS total_orders
FROM Restaurant r
JOIN Restaurant_Address ra  ON r.Restaurant_ID  = ra.Restaurant_ID
LEFT JOIN Review        rev ON r.Restaurant_ID  = rev.Restaurant_ID
LEFT JOIN Cuisine       c   ON r.Restaurant_ID  = c.Restaurant_ID
LEFT JOIN Orders        o   ON r.Restaurant_ID  = o.Restaurant_ID
WHERE r.Restaurant_Status = 1
GROUP BY r.Restaurant_ID, r.Name, ra.City
HAVING avg_review_rating >= 4.0
   AND total_orders >= 1
ORDER BY avg_review_rating DESC, total_orders DESC;


-- ==========================================================
-- Q9: DELIVERY PARTNER PERFORMANCE SCORECARD
--     Business use: Monthly partner payouts, incentive bonus
--     for fast/high-rated partners, deactivation decisions.
-- ==========================================================
SELECT
    dp.Partner_ID,
    dp.Name                             AS partner_name,
    dp.Vehicle_No,
    dp.Rating,
    COUNT(d.Delivery_ID)                AS total_deliveries,
    SUM(CASE WHEN d.Status = 'Delivered' THEN 1 ELSE 0 END)
                                        AS completed,
    SUM(CASE WHEN d.Status = 'Failed'    THEN 1 ELSE 0 END)
                                        AS failed,
    ROUND(
        SUM(CASE WHEN d.Status = 'Delivered' THEN 1.0 ELSE 0 END)
        / COUNT(d.Delivery_ID) * 100, 2
    )                                   AS success_rate_pct
FROM Delivery_Partner dp
LEFT JOIN Delivery d ON dp.Partner_ID = d.Partner_ID
GROUP BY dp.Partner_ID, dp.Name, dp.Vehicle_No, dp.Rating
ORDER BY success_rate_pct DESC, total_deliveries DESC;


-- ==========================================================
-- Q10: AVERAGE DELIVERY DURATION PER PARTNER
--      Business use: SLA monitoring -- flag partners who
--      consistently exceed 45-minute delivery window.
--      TIMESTAMPDIFF used for DATETIME diff (MySQL-compatible)
-- ==========================================================
SELECT
    dp.Partner_ID,
    dp.Name                                         AS partner_name,
    COUNT(d.Delivery_ID)                            AS deliveries_completed,
    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, d.Pickup_Time, d.Delivery_Time)), 2
    )                                               AS avg_transit_minutes,
    ROUND(
        MIN(TIMESTAMPDIFF(MINUTE, d.Pickup_Time, d.Delivery_Time)), 2
    )                                               AS fastest_mins,
    ROUND(
        MAX(TIMESTAMPDIFF(MINUTE, d.Pickup_Time, d.Delivery_Time)), 2
    )                                               AS slowest_mins
FROM Delivery_Partner dp
JOIN Delivery d ON dp.Partner_ID = d.Partner_ID
WHERE d.Status = 'Delivered'
  AND d.Delivery_Time IS NOT NULL
  AND d.Pickup_Time   IS NOT NULL
GROUP BY dp.Partner_ID, dp.Name
ORDER BY avg_transit_minutes ASC;


-- ==========================================================
-- Q11: BEST-SELLING MENU ITEMS (by quantity sold)
--      Business use: Inventory forecasting, homepage
--      "Bestseller" badge, upsell recommendations engine.
-- ==========================================================
SELECT
    mi.Item_ID,
    mi.Item_Name,
    mi.Price,
    mc.Type                             AS veg_nonveg,
    r.Name                              AS restaurant_name,
    SUM(oi.Quantity)                    AS total_qty_sold,
    COUNT(DISTINCT oi.OrderID)          AS appeared_in_orders,
    SUM(oi.Unit_Price * oi.Quantity)    AS total_revenue
FROM Order_Item oi
JOIN Menu_Item      mi ON oi.Item_ID      = mi.Item_ID
JOIN Menu_Category  mc ON mi.Category_Name = mc.Category_Name
                       AND mi.Restaurant_ID = mc.Restaurant_ID
JOIN Restaurant     r  ON mi.Restaurant_ID = r.Restaurant_ID
GROUP BY mi.Item_ID, mi.Item_Name, mi.Price, mc.Type, r.Name
ORDER BY total_qty_sold DESC;


-- ==========================================================
-- Q12: MENU ITEMS NEVER ORDERED (dead stock)
--      Business use: Menu pruning -- remove or discount items
--      sitting on the menu that no customer ever ordered.
-- ==========================================================
SELECT
    mi.Item_ID,
    mi.Item_Name,
    mi.Price,
    mi.Is_Available,
    r.Name                              AS restaurant_name,
    mi.Category_Name
FROM Menu_Item mi
JOIN Restaurant r ON mi.Restaurant_ID = r.Restaurant_ID
WHERE mi.Item_ID NOT IN (
    SELECT DISTINCT Item_ID FROM Order_Item
)
ORDER BY r.Name, mi.Category_Name;


-- ==========================================================
-- Q13: WALLET USAGE AND BALANCE SUMMARY
--      Business use: Finance team -- total float held in
--      wallets, top wallet holders for loyalty perks.
-- ==========================================================
SELECT
    w.Wallet_ID,
    u.User_Name,
    u.Email,
    w.Balance                           AS current_balance,
    COUNT(DISTINCT wt.Transaction_ID)   AS total_transactions,
    SUM(CASE WHEN wt.Type = 'Credit' THEN wt.Amount ELSE 0 END)
                                        AS total_credited,
    SUM(CASE WHEN wt.Type = 'Debit'  THEN wt.Amount ELSE 0 END)
                                        AS total_debited
FROM Wallet w
JOIN Users              u  ON w.UserID    = u.UserID
LEFT JOIN Wallet_Transaction wt ON w.Wallet_ID = wt.Wallet_ID
GROUP BY w.Wallet_ID, u.User_Name, u.Email, w.Balance
ORDER BY w.Balance DESC;


-- ==========================================================
-- Q14: COMPLAINT RESOLUTION RATE BY ISSUE TYPE
--      Business use: Customer experience team -- which
--      complaint categories take longest to resolve or
--      have lowest resolution rates (SLA breaches).
-- ==========================================================
SELECT
    Issue_Type,
    COUNT(*)                            AS total_complaints,
    SUM(CASE WHEN Status = 'Resolved' OR Status = 'Closed'
             THEN 1 ELSE 0 END)         AS resolved_count,
    ROUND(
        SUM(CASE WHEN Status = 'Resolved' OR Status = 'Closed'
                 THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2
    )                                   AS resolution_rate_pct,
    SUM(CASE WHEN Status = 'Open' THEN 1 ELSE 0 END)
                                        AS still_open
FROM Complaint
GROUP BY Issue_Type
ORDER BY total_complaints DESC;


-- ==========================================================
-- Q15: REFUND IMPACT REPORT -- per order with full context
--      Business use: Finance reconciliation -- which orders
--      triggered refunds, how much was refunded vs paid,
--      and current refund pipeline status.
-- ==========================================================
SELECT
    o.OrderID,
    u.User_Name                         AS customer,
    r.Name                              AS restaurant,
    o.Total_Amount                      AS order_amount,
    p.Amount                            AS amount_paid,
    p.Mode                              AS payment_mode,
    comp.Issue_Type                     AS complaint_reason,
    ref.Refund_Amount,
    ref.Refund_Status,
    ref.Completed_At                    AS refund_completed,
    ROUND(ref.Refund_Amount * 100.0 / p.Amount, 1)
                                        AS refund_pct_of_payment
FROM Refund ref
JOIN Orders     o    ON ref.OrderID      = o.OrderID
JOIN Users      u    ON o.UserID         = u.UserID
JOIN Restaurant r    ON o.Restaurant_ID  = r.Restaurant_ID
JOIN Payment    p    ON o.OrderID        = p.Order_ID
JOIN Complaint  comp ON ref.Complaint_ID = comp.Complaint_ID
ORDER BY ref.Refund_Amount DESC;
