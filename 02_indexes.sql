-- =============================================================
--  02_indexes.sql  --  Quick-Bite Index Definitions (Cleaned Up)
--
--  CHANGES vs original:
--  REMOVED 6 redundant indexes -- MySQL automatically creates
--  a B-tree index for every UNIQUE constraint, so adding a
--  separate CREATE INDEX on the same column wastes disk space
--  and slows down INSERT/UPDATE:
--    idx_users_email    (Email is already UNIQUE)
--    idx_payment_orderid (Order_ID is already UNIQUE)
--    idx_delivery_orderid (OrderID is already UNIQUE)
--    idx_discount_orderid (OrderID is already UNIQUE)
--    idx_cancel_orderid   (OrderID is already UNIQUE)
--    idx_wallet_userid    (UserID is already UNIQUE)
--
--  ADDED 3 new useful indexes:
--    idx_orders_amount      -- range queries: "orders > Rs 500"
--    idx_complaint_createdat -- sort open complaints by age
--    idx_review_createdat   -- latest reviews first on homepage
-- =============================================================

-- Users
-- NOTE: idx_users_email REMOVED -- Email column has UNIQUE
--       constraint which already creates an implicit index.
CREATE INDEX idx_users_role        ON Users(Role);

-- User_Has_Address
CREATE INDEX idx_uha_userid        ON User_Has_Address(UserID);

-- Restaurant
CREATE INDEX idx_restaurant_status ON Restaurant(Restaurant_Status);
CREATE INDEX idx_restaurant_rating ON Restaurant(Rating DESC);
CREATE INDEX idx_restaurant_name   ON Restaurant(Name);

-- Restaurant_Address
CREATE INDEX idx_raddr_restid      ON Restaurant_Address(Restaurant_ID);
CREATE INDEX idx_raddr_city        ON Restaurant_Address(City);

-- Cuisine
CREATE INDEX idx_cuisine_restid    ON Cuisine(Restaurant_ID);

-- Menu_Category
CREATE INDEX idx_mcat_restid       ON Menu_Category(Restaurant_ID);

-- Menu_Item
CREATE INDEX idx_mitem_restid      ON Menu_Item(Restaurant_ID);
CREATE INDEX idx_mitem_category    ON Menu_Item(Category_Name, Restaurant_ID);
CREATE INDEX idx_mitem_price       ON Menu_Item(Price);
CREATE INDEX idx_mitem_available   ON Menu_Item(Is_Available);

-- Review
CREATE INDEX idx_review_restid     ON Review(Restaurant_ID);
CREATE INDEX idx_review_userid     ON Review(UserID);
CREATE INDEX idx_review_rating     ON Review(Rating DESC);
CREATE INDEX idx_review_createdat  ON Review(Created_At DESC);   -- NEW: latest reviews first

-- Cart
CREATE INDEX idx_cart_userid       ON Cart(UserID);
CREATE INDEX idx_cart_status       ON Cart(Status);

-- Cart_Item
CREATE INDEX idx_cartitem_cartid   ON Cart_Item(Cart_ID);
CREATE INDEX idx_cartitem_itemid   ON Cart_Item(Item_ID);

-- Orders
CREATE INDEX idx_orders_userid     ON Orders(UserID);
CREATE INDEX idx_orders_restid     ON Orders(Restaurant_ID);
CREATE INDEX idx_orders_status     ON Orders(Status);
CREATE INDEX idx_orders_datetime   ON Orders(Date_Time DESC);
CREATE INDEX idx_orders_amount     ON Orders(Total_Amount);      -- NEW: range/analytics queries

-- Order_Item
CREATE INDEX idx_oitem_orderid     ON Order_Item(OrderID);
CREATE INDEX idx_oitem_itemid      ON Order_Item(Item_ID);

-- Payment
-- NOTE: idx_payment_orderid REMOVED -- Order_ID is UNIQUE.
CREATE INDEX idx_payment_status    ON Payment(Status);
CREATE INDEX idx_payment_mode      ON Payment(Mode);

-- Delivery_Partner
CREATE INDEX idx_dp_rating         ON Delivery_Partner(Rating DESC);
CREATE INDEX idx_dp_active         ON Delivery_Partner(Is_Active);

-- Delivery
-- NOTE: idx_delivery_orderid REMOVED -- OrderID is UNIQUE.
CREATE INDEX idx_delivery_partner  ON Delivery(Partner_ID);
CREATE INDEX idx_delivery_status   ON Delivery(Status);

-- Wallet
-- NOTE: idx_wallet_userid REMOVED -- UserID is UNIQUE.

-- Wallet_Transaction
CREATE INDEX idx_wtxn_walletid     ON Wallet_Transaction(Wallet_ID);
CREATE INDEX idx_wtxn_type         ON Wallet_Transaction(Type);
CREATE INDEX idx_wtxn_datetime     ON Wallet_Transaction(Date_Time DESC);

-- Wallet_TopUP
CREATE INDEX idx_topup_walletid    ON Wallet_TopUP(Wallet_ID);
CREATE INDEX idx_topup_status      ON Wallet_TopUP(Status);

-- Discount
-- NOTE: idx_discount_orderid REMOVED -- OrderID is UNIQUE.

-- Complaint
CREATE INDEX idx_complaint_orderid  ON Complaint(OrderID);
CREATE INDEX idx_complaint_status   ON Complaint(Status);
CREATE INDEX idx_complaint_createdat ON Complaint(Created_At);   -- NEW: sort by age for SLA

-- Refund
CREATE INDEX idx_refund_orderid    ON Refund(OrderID);
CREATE INDEX idx_refund_complaint  ON Refund(Complaint_ID);
CREATE INDEX idx_refund_wallet     ON Refund(Wallet_ID);
CREATE INDEX idx_refund_status     ON Refund(Refund_Status);

-- Cancellation
-- NOTE: idx_cancel_orderid REMOVED -- OrderID is UNIQUE.
CREATE INDEX idx_cancel_by         ON Cancellation(Cancelled_By);
