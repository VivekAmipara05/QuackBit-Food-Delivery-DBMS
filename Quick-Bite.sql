-- ============================================================
--   QuackBit - Food Delivery Database Management System
--   Project  : QuackBit DBMS
--   Database : MySQL
--   Author   : [Your Name]
--   Version  : 2.0
-- ============================================================


-- ============================================================
--  CREATE & SELECT DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS QuackBit;
USE QuackBit;


-- ============================================================
--  TABLE: Address
--  (Created first — referenced by User, Restaurant, Orders)
-- ============================================================

CREATE TABLE Address (
    Add_ID     BIGINT       PRIMARY KEY,
    Add_line_1 VARCHAR(100),
    Add_line_2 VARCHAR(100),
    Area       VARCHAR(50),
    City       VARCHAR(50),
    Pincode    INT
);

INSERT INTO Address (Add_ID, Add_line_1, Add_line_2, Area, City, Pincode) VALUES
(101, 'Street 1',  'Near Park',       'Sector 21',     'Gandhinagar', 382021),
(102, 'Street 2',  'Opp Mall',        'Sector 22',     'Ahmedabad',   380015),
(103, 'Street 3',  'Near Lake',       'Adajan',        'Surat',       395009),
(104, 'Street 4',  'Market Area',     'Alkapuri',      'Vadodara',    390007),
(105, 'Street 5',  'Near Temple',     'Raiya Road',    'Rajkot',      360005),
(106, 'Street 6',  'Bus Stand',       'Kalanala',      'Bhavnagar',   364001),
(107, 'Street 7',  'Railway Station', 'Digvijay Plot', 'Jamnagar',    361005),
(108, 'Street 8',  'Near College',    'Vidhyanagar',   'Anand',       388120),
(109, 'Street 9',  'Hospital Road',   'Modhera Road',  'Mehsana',     384002),
(110, 'Street 10', 'Garden Area',     'Mahendranagar', 'Morbi',       363642);


-- ============================================================
--  TABLE: User
-- ============================================================

CREATE TABLE User (
    UserID       BIGINT       PRIMARY KEY AUTO_INCREMENT,
    User_Name    VARCHAR(100) NOT NULL,
    Email        VARCHAR(100) NOT NULL UNIQUE,
    Phone_No     VARCHAR(15)  NOT NULL UNIQUE,
    Password_Hash VARCHAR(255) NOT NULL,              -- hashed password for auth
    Profile_Pic  VARCHAR(300) DEFAULT NULL,           -- URL to profile image
    Is_Active    BOOLEAN      DEFAULT TRUE,           -- account active/banned
    Created_At   DATETIME     DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO User (UserID, User_Name, Email, Phone_No, Password_Hash, Is_Active, Created_At) VALUES
(1,  'Vivek', 'vivek@gmail.com', '9876543210', 'hashed_pw_1',  TRUE, '2025-10-20 10:00:00'),
(2,  'Rahul', 'rahul@gmail.com', '9123456780', 'hashed_pw_2',  TRUE, '2025-10-25 12:30:00'),
(3,  'Amit',  'amit@gmail.com',  '9000000001', 'hashed_pw_3',  TRUE, '2025-11-01 09:15:00'),
(4,  'Neha',  'neha@gmail.com',  '9000000002', 'hashed_pw_4',  TRUE, '2025-09-15 14:00:00'),
(5,  'Priya', 'priya@gmail.com', '9000000003', 'hashed_pw_5',  TRUE, '2025-10-26 16:45:00'),
(6,  'Karan', 'karan@gmail.com', '9000000004', 'hashed_pw_6',  TRUE, '2025-08-10 11:20:00'),
(7,  'Riya',  'riya@gmail.com',  '9000000005', 'hashed_pw_7',  TRUE, '2025-10-27 18:10:00'),
(8,  'Ankit', 'ankit@gmail.com', '9000000006', 'hashed_pw_8',  TRUE, '2025-07-05 08:00:00'),
(9,  'Sneha', 'sneha@gmail.com', '9000000007', 'hashed_pw_9',  TRUE, '2025-10-28 20:30:00'),
(10, 'Yash',  'yash@gmail.com',  '9000000008', 'hashed_pw_10', TRUE, '2025-10-29 09:45:00');


-- ============================================================
--  TABLE: User_Address  (Junction: User <-> Address)
-- ============================================================

CREATE TABLE User_Address (
    UserID      BIGINT,
    Add_ID      BIGINT,
    Is_Default  BOOLEAN DEFAULT FALSE,               -- which address is default delivery
    Label       VARCHAR(20) DEFAULT 'Home',          -- Home / Work / Other
    PRIMARY KEY (UserID, Add_ID),
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (Add_ID) REFERENCES Address(Add_ID)
);

INSERT INTO User_Address (UserID, Add_ID, Is_Default, Label) VALUES
(1,101,TRUE,'Home'),(2,102,TRUE,'Home'),(3,103,TRUE,'Home'),
(4,104,TRUE,'Home'),(5,105,TRUE,'Home'),(6,106,TRUE,'Work'),
(7,107,TRUE,'Home'),(8,108,TRUE,'Home'),(9,109,TRUE,'Home'),
(10,110,TRUE,'Home');


-- ============================================================
--  TABLE: Restaurant
-- ============================================================

CREATE TABLE Restaurant (
    Restaurant_ID     BIGINT        PRIMARY KEY,
    Resto_Name        VARCHAR(50)   NOT NULL,
    Open_Time         TIME,
    Close_Time        TIME,
    Restaurant_Status BOOLEAN       DEFAULT TRUE,
    FSSAI_License_No  BIGINT        UNIQUE,
    Contact_No        VARCHAR(15),
    Add_ID            BIGINT,
    Rating            DECIMAL(3,1)  DEFAULT 0,
    Total_Reviews     INT           DEFAULT 0,
    Min_Order_Amount  INT           DEFAULT 0,        -- minimum order value to place order
    Avg_Delivery_Time INT           DEFAULT 30,       -- estimated delivery time in minutes
    FOREIGN KEY (Add_ID) REFERENCES Address(Add_ID)
);

INSERT INTO Restaurant
(Restaurant_ID, Resto_Name, Open_Time, Close_Time, Restaurant_Status, FSSAI_License_No, Contact_No, Add_ID, Rating, Total_Reviews, Min_Order_Amount, Avg_Delivery_Time)
VALUES
(201, 'FoodHub',      '10:00:00', '23:00:00', TRUE, 111001, '900001', 101, 4.5, 120, 100, 30),
(202, 'SpiceVilla',   '09:00:00', '22:00:00', TRUE, 111002, '900002', 102, 4.2,  98, 150, 35),
(203, 'TastyTown',    '11:00:00', '23:30:00', TRUE, 111003, '900003', 103, 4.0,  75, 120, 40),
(204, 'UrbanBite',    '08:00:00', '21:00:00', TRUE, 111004, '900004', 104, 4.8, 150,  80, 25),
(205, 'Cafe99',       '09:30:00', '22:30:00', TRUE, 111005, '900005', 105, 3.9,  60,  50, 20),
(206, 'FoodZone',     '10:00:00', '23:00:00', TRUE, 111006, '900006', 106, 4.1,  80, 100, 30),
(207, 'RoyalEat',     '11:00:00', '23:00:00', TRUE, 111007, '900007', 107, 4.6, 140, 200, 45),
(208, 'MealBox',      '08:30:00', '21:30:00', TRUE, 111008, '900008', 108, 4.3, 110, 150, 35),
(209, 'BiryaniHouse', '10:30:00', '23:30:00', TRUE, 111009, '900009', 109, 4.7, 160, 120, 30),
(210, 'PizzaWorld',   '09:00:00', '22:00:00', TRUE, 111010, '900010', 110, 4.4, 130, 100, 25);


-- ============================================================
--  TABLE: Cuisine
-- ============================================================

CREATE TABLE Cuisine (
    Cuisine       VARCHAR(30),
    Restaurant_ID BIGINT,
    PRIMARY KEY (Cuisine, Restaurant_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID)
);

INSERT INTO Cuisine VALUES
('Indian',   201),('Chinese',  201),('Italian',  202),
('Mexican',  203),('Indian',   204),('Cafe',     205),
('FastFood', 206),('Royal',    207),('Gujarati', 208),
('Biryani',  209);


-- ============================================================
--  TABLE: Menu_Category
-- ============================================================

CREATE TABLE Menu_Category (
    Category_Name VARCHAR(30),
    Cat_Type      VARCHAR(10),
    Restaurant_ID BIGINT,
    PRIMARY KEY (Category_Name, Restaurant_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID)
);

INSERT INTO Menu_Category VALUES
('Veg',      'Food',  201),('NonVeg',   'Food',  201),
('Dessert',  'Food',  202),('Beverage', 'Drink', 202),
('Veg',      'Food',  203),('Snacks',   'Food',  204),
('Dessert',  'Food',  205),('Beverage', 'Drink', 206),
('FastFood', 'Food',  207),('Combo',    'Food',  208);


-- ============================================================
--  TABLE: Menu_Item
-- ============================================================

CREATE TABLE Menu_Item (
    Item_ID             BIGINT        PRIMARY KEY,
    Item_Name           VARCHAR(50)   NOT NULL,
    Description         VARCHAR(200),
    Price               INT           NOT NULL,
    Preparation_Time    INT,                          -- in minutes
    Is_Available        BOOLEAN       DEFAULT TRUE,
    Is_Veg              BOOLEAN,
    Weight              INT,                          -- in grams
    Total_Rating        INT           DEFAULT 0,
    Rating              FLOAT         DEFAULT 0,
    Calories            INT,
    Protein             FLOAT,
    Carbs               FLOAT,
    Fat                 FLOAT,
    Image_URL           VARCHAR(300)  DEFAULT NULL,   -- food item image
    Discount_Percentage INT           DEFAULT 0,      -- item-level discount %
    Category_Name       VARCHAR(30),
    Restaurant_ID       BIGINT,
    FOREIGN KEY (Category_Name, Restaurant_ID)
        REFERENCES Menu_Category(Category_Name, Restaurant_ID)
);

INSERT INTO Menu_Item
(Item_ID, Item_Name, Description, Price, Preparation_Time,
 Is_Available, Is_Veg, Weight, Total_Rating, Rating,
 Calories, Protein, Carbs, Fat, Discount_Percentage, Category_Name, Restaurant_ID)
VALUES
(1001,'Paneer Butter Masala','Rich creamy gravy',       220,15,TRUE,TRUE, 300,120,4.5,450,18,20,30, 0,'Veg',      201),
(1002,'Chicken Curry',       'Spicy and flavorful',     260,20,TRUE,FALSE,350,150,4.6,500,25,10,35, 5,'NonVeg',   201),
(1003,'Ice Cream',           'Vanilla sweet dessert',   100, 5,TRUE,TRUE, 150, 80,4.2,200, 4,25,10, 0,'Dessert',  202),
(1004,'Cold Drink',          'Chilled soft drink',       50, 2,TRUE,TRUE, 300, 60,4.0,150, 0,35, 0, 0,'Beverage', 202),
(1005,'Veg Thali',           'Complete meal platter',   180,20,TRUE,TRUE, 500, 90,4.3,600,20,60,25,10,'Veg',      203),
(1006,'Grilled Sandwich',    'Toasted snack',            90,10,TRUE,TRUE, 200, 70,4.1,300,10,30,15, 0,'Snacks',   204),
(1007,'Chocolate Cake',      'Soft sweet cake',         150,12,TRUE,TRUE, 250,110,4.7,400, 6,50,20, 0,'Dessert',  205),
(1008,'Fresh Juice',         'Natural fruit juice',      80, 5,TRUE,TRUE, 250, 65,4.2,120, 2,28, 1, 0,'Beverage', 206),
(1009,'Burger',              'Cheese loaded burger',    130,10,TRUE,FALSE,220,140,4.6,550,20,40,25,15,'FastFood',  207),
(1010,'Combo Meal',          'Burger + drink combo',    300,25,TRUE,FALSE,600,100,4.4,700,22,70,30, 5,'Combo',    208);


-- ============================================================
--  TABLE: Coupon
--  (Coupon codes users apply at checkout — separate from Discount)
-- ============================================================

CREATE TABLE Coupon (
    Coupon_ID       BIGINT        PRIMARY KEY,
    Coupon_Code     VARCHAR(20)   NOT NULL UNIQUE,    -- e.g. SAVE20, FIRST50
    Description     VARCHAR(100),
    Discount_PR     INT           DEFAULT 0,          -- percentage off
    Discount_Amount INT           DEFAULT 0,          -- flat off in ₹
    Min_Order_Value INT           DEFAULT 0,          -- minimum cart value to apply
    Max_Uses        INT           DEFAULT 100,        -- total times coupon can be used
    Used_Count      INT           DEFAULT 0,          -- how many times used so far
    Valid_From      DATE,
    Valid_Till      DATE,
    Is_Active       BOOLEAN       DEFAULT TRUE
);

INSERT INTO Coupon (Coupon_ID, Coupon_Code, Description, Discount_PR, Discount_Amount, Min_Order_Value, Max_Uses, Used_Count, Valid_From, Valid_Till) VALUES
(1, 'FIRST50',  'First order flat ₹50 off',    0,  50, 100, 500, 120, '2025-10-01', '2025-12-31'),
(2, 'SAVE20',   '20% off on orders above ₹200',20,   0, 200, 300,  80, '2025-10-01', '2025-11-30'),
(3, 'WEEKEND15','15% off every weekend',       15,   0, 150, 200,  45, '2025-10-01', '2025-12-31'),
(4, 'FLAT100',  'Flat ₹100 off above ₹500',    0, 100, 500, 150,  30, '2025-11-01', '2025-12-31'),
(5, 'QUACK10',  'QuackBit loyalty 10% off',    10,   0,   0, 999,  60, '2025-09-01', '2025-12-31');


-- ============================================================
--  TABLE: Discount
--  (Auto-applied discounts linked to orders)
-- ============================================================

CREATE TABLE Discount (
    Discount_ID     BIGINT PRIMARY KEY,
    Discount_PR     INT    DEFAULT 0,
    Discount_Amount INT    DEFAULT 0,
    Coupon_ID       BIGINT DEFAULT NULL,              -- which coupon triggered this discount
    FOREIGN KEY (Coupon_ID) REFERENCES Coupon(Coupon_ID)
);

INSERT INTO Discount (Discount_ID, Discount_PR, Discount_Amount, Coupon_ID) VALUES
(1,  10,   0, NULL),
(2,  20,   0, 2),
(3,   0,  50, 1),
(4,   0, 100, 4),
(5,  15, 100, NULL),
(6,  25,   0, NULL),
(7,   0,  75, NULL),
(8,   5,   0, 5),
(9,  30,   0, NULL),
(10,  0, 150, NULL);


-- ============================================================
--  TABLE: Cart
-- ============================================================

CREATE TABLE Cart (
    Cart_ID      BIGINT      PRIMARY KEY,
    Created_At   TIMESTAMP,
    Updated_At   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Status       VARCHAR(20),                         -- Active / Ordered / Abandoned
    Total_Amount INT         DEFAULT 0,               -- running cart total
    UserID       BIGINT,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

INSERT INTO Cart (Cart_ID, Created_At, Status, Total_Amount, UserID) VALUES
(1, '2025-10-20 10:00:00','Active',  440, 1),
(2, '2025-10-21 11:00:00','Active',  410, 2),
(3, '2025-10-22 12:00:00','Ordered', 450, 3),
(4, '2025-10-23 13:00:00','Active',  310, 4),
(5, '2025-10-24 14:00:00','Ordered', 560, 5),
(6, '2025-10-25 15:00:00','Active',  400, 6),
(7, '2025-10-26 16:00:00','Active',  330, 7),
(8, '2025-10-27 17:00:00','Ordered', 460, 8),
(9, '2025-10-28 18:00:00','Active',  620, 9),
(10,'2025-10-29 19:00:00','Active',  750,10);


-- ============================================================
--  TABLE: Cart_Item
-- ============================================================

CREATE TABLE Cart_Item (
    Cart_ID  BIGINT,
    Item_ID  BIGINT,
    Quantity INT,
    PRIMARY KEY (Cart_ID, Item_ID),
    FOREIGN KEY (Cart_ID) REFERENCES Cart(Cart_ID),
    FOREIGN KEY (Item_ID) REFERENCES Menu_Item(Item_ID)
);

INSERT INTO Cart_Item (Cart_ID, Item_ID, Quantity) VALUES
(1,1001,2),(1,1003,1),(2,1002,1),(2,1004,3),
(3,1005,2),(3,1006,1),(4,1007,1),(4,1008,2),
(5,1009,2),(5,1010,1),(6,1001,1),(6,1006,2),
(7,1003,2),(7,1009,1),(8,1004,1),(8,1005,2),
(9,1002,2),(9,1008,1),(10,1007,1),(10,1010,2);


-- ============================================================
--  TABLE: Orders
-- ============================================================

CREATE TABLE Orders (
    OrderID              BIGINT      PRIMARY KEY,
    Date_Time            TIMESTAMP,
    Order_Status         VARCHAR(20) DEFAULT 'Placed', -- Placed/Preparing/OutForDelivery/Delivered/Cancelled
    Total_Amount         INT         DEFAULT 0,        -- final billed amount after discount
    Special_Instructions VARCHAR(200) DEFAULT NULL,    -- e.g. "no onion", "extra spicy"
    UserID               BIGINT,
    Add_ID               BIGINT,
    Discount_ID          BIGINT,
    FOREIGN KEY (UserID)      REFERENCES User(UserID),
    FOREIGN KEY (Add_ID)      REFERENCES Address(Add_ID),
    FOREIGN KEY (Discount_ID) REFERENCES Discount(Discount_ID)
);

INSERT INTO Orders (OrderID, Date_Time, Order_Status, Total_Amount, UserID, Add_ID, Discount_ID) VALUES
(1, '2025-10-20 10:30:00','Delivered', 594, 1,  101, 1),
(2, '2025-10-21 11:15:00','Delivered', 208, 2,  102, 2),
(3, '2025-10-22 12:45:00','Delivered', 450, 3,  103, 1),
(4, '2025-10-23 13:20:00','Cancelled', 150, 4,  104, 4),
(5, '2025-10-24 14:10:00','Delivered', 476, 5,  105, 1),
(6, '2025-10-25 15:05:00','Delivered', 202, 6,  106, 6),
(7, '2025-10-26 16:40:00','Delivered', 200, 7,  107, 1),
(8, '2025-10-27 17:25:00','Cancelled', 437, 8,  108, 8),
(9, '2025-10-28 18:55:00','Delivered', 460, 9,  109, 4),
(10,'2025-10-29 19:35:00','Delivered', 712, 10, 110, 5);


-- ============================================================
--  TABLE: Order_Status_Log
--  Track every status change for live order tracking
-- ============================================================

CREATE TABLE Order_Status_Log (
    Log_ID     BIGINT    PRIMARY KEY AUTO_INCREMENT,
    OrderID    BIGINT,
    Status     VARCHAR(20),
    Changed_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Note       VARCHAR(100) DEFAULT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO Order_Status_Log (Log_ID, OrderID, Status, Changed_At) VALUES
(1,  1, 'Placed',          '2025-10-20 10:30:00'),
(2,  1, 'Preparing',       '2025-10-20 10:35:00'),
(3,  1, 'OutForDelivery',  '2025-10-20 10:45:00'),
(4,  1, 'Delivered',       '2025-10-20 11:15:00'),
(5,  2, 'Placed',          '2025-10-21 11:15:00'),
(6,  2, 'Preparing',       '2025-10-21 11:20:00'),
(7,  2, 'OutForDelivery',  '2025-10-21 11:30:00'),
(8,  2, 'Delivered',       '2025-10-21 12:00:00'),
(9,  4, 'Placed',          '2025-10-23 13:20:00'),
(10, 4, 'Cancelled',       '2025-10-23 14:00:00'),
(11, 8, 'Placed',          '2025-10-27 17:25:00'),
(12, 8, 'Preparing',       '2025-10-27 17:30:00'),
(13, 8, 'Cancelled',       '2025-10-27 18:00:00'),
(14, 9, 'Placed',          '2025-10-28 18:55:00'),
(15, 9, 'Preparing',       '2025-10-28 19:00:00'),
(16, 9, 'OutForDelivery',  '2025-10-28 19:10:00'),
(17, 9, 'Delivered',       '2025-10-28 19:50:00');


-- ============================================================
--  TABLE: Order_Item
-- ============================================================

CREATE TABLE Order_Item (
    OrderID  BIGINT,
    Item_ID  BIGINT,
    Quantity INT,
    Price    INT,                                      -- price at time of order (snapshot)
    PRIMARY KEY (OrderID, Item_ID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (Item_ID) REFERENCES Menu_Item(Item_ID)
);

INSERT INTO Order_Item (OrderID, Item_ID, Quantity, Price) VALUES
(1,1001,2,220),(1,1003,1,100),(2,1002,1,260),(2,1004,2, 50),
(3,1005,2,180),(3,1006,1, 90),(4,1007,1,150),(4,1008,2, 80),
(5,1009,2,130),(5,1010,1,300),(6,1001,1,220),(6,1006,2, 90),
(7,1003,2,100),(7,1009,1,130),(8,1004,1, 50),(8,1005,2,180),
(9,1002,2,260),(9,1008,1, 80),(10,1007,1,150),(10,1010,2,300);


-- ============================================================
--  TABLE: Delivery_Partner
-- ============================================================

CREATE TABLE Delivery_Partner (
    Partner_ID       BIGINT       PRIMARY KEY,
    Name             VARCHAR(50),
    Phone_No         VARCHAR(15),
    Vehicle_No       CHAR(12),
    Rating           DECIMAL(3,1) DEFAULT 0,
    Is_Available     BOOLEAN      DEFAULT TRUE,       -- currently free or on delivery
    City             VARCHAR(50),                     -- city they operate in
    Total_Deliveries INT          DEFAULT 0,          -- lifetime delivery count
    Joining_Date     DATE
);

INSERT INTO Delivery_Partner (Partner_ID, Name, Phone_No, Vehicle_No, Rating, Is_Available, City, Total_Deliveries, Joining_Date) VALUES
(1,  'Amit',    '9000000001', 'GJ01AA1111', 4.5, TRUE,  'Gandhinagar', 245, '2024-01-15'),
(2,  'Rahul',   '9000000002', 'GJ01AA2222', 4.2, TRUE,  'Ahmedabad',   198, '2024-02-10'),
(3,  'Karan',   '9000000003', 'GJ01AA3333', 4.0, TRUE,  'Surat',       176, '2024-03-05'),
(4,  'Rohit',   '9000000004', 'GJ01AA4444', 4.8, TRUE,  'Vadodara',    312, '2023-12-20'),
(5,  'Vikas',   '9000000005', 'GJ01AA5555', 3.9, FALSE, 'Rajkot',      134, '2024-04-01'),
(6,  'Suresh',  '9000000006', 'GJ01AA6666', 4.1, TRUE,  'Bhavnagar',   167, '2024-01-30'),
(7,  'Mahesh',  '9000000007', 'GJ01AA7777', 4.6, TRUE,  'Jamnagar',    289, '2023-11-10'),
(8,  'Naresh',  '9000000008', 'GJ01AA8888', 4.3, FALSE, 'Anand',       210, '2024-02-25'),
(9,  'Jignesh', '9000000009', 'GJ01AA9999', 4.7, TRUE,  'Mehsana',     276, '2023-10-05'),
(10, 'Ramesh',  '9000000010', 'GJ01AA0000', 4.4, TRUE,  'Morbi',       223, '2024-03-18');


-- ============================================================
--  TABLE: Delivery
-- ============================================================

CREATE TABLE Delivery (
    Delivery_ID      BIGINT      PRIMARY KEY,
    Pickup_Time      TIMESTAMP,
    Delivery_Time    TIMESTAMP,
    Status           VARCHAR(15),                     -- Picked/InTransit/Delivered
    Delivery_Charges INT         DEFAULT 0,           -- delivery fee charged for this order
    OrderID          BIGINT,
    Partner_ID       BIGINT,
    FOREIGN KEY (OrderID)    REFERENCES Orders(OrderID),
    FOREIGN KEY (Partner_ID) REFERENCES Delivery_Partner(Partner_ID)
);

INSERT INTO Delivery (Delivery_ID, Pickup_Time, Delivery_Time, Status, Delivery_Charges, OrderID, Partner_ID) VALUES
(1,  '2025-10-20 10:45:00', '2025-10-20 11:15:00', 'Delivered', 30, 1,  1),
(2,  '2025-10-21 11:30:00', '2025-10-21 12:00:00', 'Delivered', 25, 2,  2),
(3,  '2025-10-22 13:00:00', '2025-10-22 13:40:00', 'Delivered', 30, 3,  3),
(4,  '2025-10-23 13:30:00', '2025-10-23 14:10:00', 'Delivered', 20, 4,  4),
(5,  '2025-10-24 14:30:00', '2025-10-24 15:10:00', 'Delivered', 30, 5,  5),
(6,  '2025-10-25 15:20:00', '2025-10-25 16:00:00', 'Delivered', 25, 6,  6),
(7,  '2025-10-26 17:00:00', '2025-10-26 17:50:00', 'Delivered', 35, 7,  7),
(8,  '2025-10-27 17:40:00', NULL,                  'InTransit', 30, 8,  8),
(9,  '2025-10-28 19:00:00', '2025-10-28 19:50:00', 'Delivered', 20, 9,  9),
(10, '2025-10-29 20:00:00', NULL,                  'Picked',    25, 10, 10);


-- ============================================================
--  TABLE: Payment
-- ============================================================

CREATE TABLE Payment (
    Transaction_ID BIGINT      PRIMARY KEY,
    Mode           VARCHAR(15),                       -- UPI/Card/Cash/NetBanking/Wallet
    Amount         INT,
    Status         VARCHAR(10) DEFAULT 'Success',     -- Success/Failed/Pending
    Payment_Date   TIMESTAMP,                         -- when payment was made
    Order_ID       BIGINT,
    FOREIGN KEY (Order_ID) REFERENCES Orders(OrderID)
);

INSERT INTO Payment (Transaction_ID, Mode, Amount, Status, Payment_Date, Order_ID) VALUES
(1,  'UPI',        594, 'Success', '2025-10-20 10:31:00', 1),
(2,  'Card',       208, 'Success', '2025-10-21 11:16:00', 2),
(3,  'Cash',       450, 'Success', '2025-10-22 13:40:00', 3),
(4,  'UPI',        150, 'Success', '2025-10-23 13:21:00', 4),
(5,  'Card',       476, 'Success', '2025-10-24 14:11:00', 5),
(6,  'Cash',       202, 'Success', '2025-10-25 16:00:00', 6),
(7,  'Wallet',     200, 'Success', '2025-10-26 16:41:00', 7),
(8,  'Card',       437, 'Success', '2025-10-27 17:26:00', 8),
(9,  'NetBanking', 460, 'Success', '2025-10-28 18:56:00', 9),
(10, 'UPI',        712, 'Success', '2025-10-29 19:36:00', 10);


-- ============================================================
--  TABLE: Review
-- ============================================================

CREATE TABLE Review (
    Review_ID     BIGINT        PRIMARY KEY,
    Review        VARCHAR(300),
    Rating        DECIMAL(3,1),
    Review_Date   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    Restaurant_ID BIGINT,
    UserID        BIGINT,
    Partner_ID    BIGINT,
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID),
    FOREIGN KEY (UserID)        REFERENCES User(UserID),
    FOREIGN KEY (Partner_ID)    REFERENCES Delivery_Partner(Partner_ID)
);

INSERT INTO Review (Review_ID, Review, Rating, Review_Date, Restaurant_ID, UserID, Partner_ID) VALUES
(1,  'Food was amazing and fresh',        4.5, '2025-10-20 12:00:00', 201, 1,  NULL),
(2,  'Nice taste but slightly expensive', 4.0, '2025-10-21 13:00:00', 202, 2,  NULL),
(3,  'Average food quality',              3.5, '2025-10-22 14:00:00', 203, 3,  NULL),
(4,  'Excellent, highly recommended',     5.0, '2025-10-23 15:00:00', 204, 4,  NULL),
(5,  'Desserts were very good',           4.2, '2025-10-24 16:00:00', 205, 5,  NULL),
(6,  'Delivery was very fast',            4.6, '2025-10-25 17:00:00', NULL, 6,  1),
(7,  'Polite delivery partner',           4.8, '2025-10-26 18:00:00', NULL, 7,  2),
(8,  'Late delivery but good behavior',   3.9, '2025-10-27 19:00:00', NULL, 8,  3),
(9,  'Package handled carefully',         4.7, '2025-10-28 20:00:00', NULL, 9,  4),
(10, 'Delivery was delayed',              3.5, '2025-10-29 21:00:00', NULL, 10, 5);


-- ============================================================
--  TABLE: Cancellation
-- ============================================================

CREATE TABLE Cancellation (
    Cancellation_ID BIGINT       PRIMARY KEY,
    Canceled_BY     BIGINT,                           -- UserID who cancelled
    Reason          VARCHAR(100),
    Cancel_At       TIMESTAMP,
    Refund_Eligible BOOLEAN,
    Penalty_Amount  INT          DEFAULT 0,
    Order_ID        BIGINT,
    FOREIGN KEY (Canceled_BY) REFERENCES User(UserID),
    FOREIGN KEY (Order_ID)    REFERENCES Orders(OrderID)
);

INSERT INTO Cancellation (Cancellation_ID, Canceled_BY, Reason, Cancel_At, Refund_Eligible, Penalty_Amount, Order_ID) VALUES
(1, 1, 'Changed mind',            '2025-10-23 14:00:00', TRUE,  0,  4),
(2, 2, 'Late delivery',           '2025-10-27 18:00:00', TRUE,  0,  8),
(3, 3, 'Wrong item delivered',    '2025-10-28 19:30:00', TRUE,  0,  9),
(4, 4, 'Order placed by mistake', '2025-10-25 16:00:00', FALSE, 50, 6);


-- ============================================================
--  TABLE: Wallet
-- ============================================================

CREATE TABLE Wallet (
    Wallet_ID  BIGINT PRIMARY KEY,
    Balance    INT    DEFAULT 0,
    Created_At TIMESTAMP,
    UserID     BIGINT UNIQUE,                         -- one wallet per user
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

INSERT INTO Wallet (Wallet_ID, Balance, Created_At, UserID) VALUES
(1, 1000,'2025-10-01 10:00:00', 1),
(2,  800,'2025-10-01 10:10:00', 2),
(3, 1200,'2025-10-01 10:20:00', 3),
(4,  500,'2025-10-01 10:30:00', 4),
(5,  700,'2025-10-01 10:40:00', 5),
(6,  900,'2025-10-01 10:50:00', 6),
(7,  400,'2025-10-01 11:00:00', 7),
(8,  600,'2025-10-01 11:10:00', 8),
(9,  300,'2025-10-01 11:20:00', 9),
(10,1000,'2025-10-01 11:30:00',10);


-- ============================================================
--  TABLE: Wallet_Transaction
-- ============================================================

CREATE TABLE Wallet_Transaction (
    Transaction_ID BIGINT      PRIMARY KEY,
    Wallet_ID      BIGINT,
    Type           VARCHAR(10),                       -- CREDIT / DEBIT
    Amount         INT,
    Balance_After  INT,                               -- wallet balance after this transaction
    Date_Time      TIMESTAMP,
    FOREIGN KEY (Wallet_ID) REFERENCES Wallet(Wallet_ID)
);

INSERT INTO Wallet_Transaction (Transaction_ID, Wallet_ID, Type, Amount, Balance_After, Date_Time) VALUES
(1,  1, 'CREDIT', 500, 1500,'2025-10-20 10:00:00'),
(2,  1, 'DEBIT',  200, 1300,'2025-10-21 11:00:00'),
(3,  2, 'CREDIT', 300, 1100,'2025-10-20 10:30:00'),
(4,  2, 'DEBIT',  100, 1000,'2025-10-21 11:30:00'),
(5,  3, 'CREDIT', 400, 1600,'2025-10-22 12:00:00'),
(6,  3, 'DEBIT',  150, 1450,'2025-10-23 13:00:00'),
(7,  4, 'CREDIT', 200,  700,'2025-10-22 12:30:00'),
(8,  5, 'DEBIT',  100,  600,'2025-10-23 14:00:00'),
(9,  6, 'CREDIT', 300, 1200,'2025-10-24 15:00:00'),
(10, 7, 'DEBIT',   50,  350,'2025-10-25 16:00:00');


-- ============================================================
--  TABLE: Wallet_Topup
-- ============================================================

CREATE TABLE Wallet_Topup (
    Transaction_ID  BIGINT      PRIMARY KEY,
    Status          VARCHAR(10),
    Payment_Mode    VARCHAR(15),
    Transaction_Ref BIGINT,
    Date_Time       TIMESTAMP,
    FOREIGN KEY (Transaction_ID) REFERENCES Wallet_Transaction(Transaction_ID)
);

INSERT INTO Wallet_Topup (Transaction_ID, Status, Payment_Mode, Transaction_Ref, Date_Time) VALUES
(1, 'Success', 'UPI',        111001,'2025-10-20 10:00:00'),
(3, 'Success', 'Card',       111002,'2025-10-20 10:30:00'),
(5, 'Success', 'UPI',        111003,'2025-10-22 12:00:00'),
(7, 'Success', 'NetBanking', 111004,'2025-10-22 12:30:00'),
(9, 'Success', 'UPI',        111005,'2025-10-24 15:00:00');


-- ============================================================
--  TABLE: Notification
--  Every push/in-app alert sent to users
-- ============================================================

CREATE TABLE Notification (
    Notification_ID BIGINT       PRIMARY KEY AUTO_INCREMENT,
    UserID          BIGINT,
    Title           VARCHAR(100),
    Message         VARCHAR(300),
    Type            VARCHAR(20),                      -- OrderUpdate/Promo/Refund/System
    Is_Read         BOOLEAN      DEFAULT FALSE,
    Created_At      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

INSERT INTO Notification (Notification_ID, UserID, Title, Message, Type, Is_Read, Created_At) VALUES
(1,  1, 'Order Placed',       'Your order #1 has been placed successfully.',   'OrderUpdate', TRUE,  '2025-10-20 10:30:00'),
(2,  1, 'Out for Delivery',   'Your order #1 is on the way!',                  'OrderUpdate', TRUE,  '2025-10-20 10:45:00'),
(3,  1, 'Order Delivered',    'Your order #1 has been delivered. Enjoy!',      'OrderUpdate', TRUE,  '2025-10-20 11:15:00'),
(4,  2, 'Order Placed',       'Your order #2 has been placed successfully.',   'OrderUpdate', TRUE,  '2025-10-21 11:15:00'),
(5,  4, 'Order Cancelled',    'Your order #4 has been cancelled.',             'OrderUpdate', TRUE,  '2025-10-23 14:00:00'),
(6,  4, 'Refund Initiated',   'Refund of ₹200 has been credited to wallet.',   'Refund',      FALSE, '2025-10-23 19:00:00'),
(7,  5, 'Special Offer!',     'Use SAVE20 to get 20% off your next order.',    'Promo',       FALSE, '2025-10-25 09:00:00'),
(8,  8, 'Order Cancelled',    'Your order #8 has been cancelled.',             'OrderUpdate', TRUE,  '2025-10-27 18:00:00'),
(9,  8, 'Refund Pending',     'Your refund of ₹120 is being processed.',       'Refund',      FALSE, '2025-10-27 18:30:00'),
(10, 3, 'Promo Alert',        'Weekend special: 15% off with WEEKEND15!',      'Promo',       FALSE, '2025-10-26 08:00:00');


-- ============================================================
--  TABLE: Complaint
-- ============================================================

CREATE TABLE Complaint (
    Complaint_ID BIGINT       PRIMARY KEY,
    OrderID      BIGINT,
    UserID       BIGINT,                              -- who raised the complaint
    Issue_Type   VARCHAR(30),
    Description  VARCHAR(200),
    Created_At   TIMESTAMP,
    Status       VARCHAR(10),                         -- Pending/Resolved/Rejected
    Resolved_At  TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (UserID)  REFERENCES User(UserID)
);

INSERT INTO Complaint (Complaint_ID, OrderID, UserID, Issue_Type, Description, Created_At, Status, Resolved_At) VALUES
(1, 4,  4,  'Late Delivery',   'Order arrived very late',    '2025-10-23 15:00:00','Resolved','2025-10-23 18:00:00'),
(2, 6,  6,  'Wrong Item',      'Received wrong food item',   '2025-10-25 16:30:00','Resolved','2025-10-25 19:00:00'),
(3, 8,  8,  'Cold Food',       'Food was cold on arrival',   '2025-10-27 18:30:00','Pending', NULL),
(4, 9,  9,  'Missing Item',    'One item missing in order',  '2025-10-28 20:00:00','Resolved','2025-10-28 22:00:00'),
(5, 2,  2,  'Bad Quality',     'Food quality was poor',      '2025-10-21 13:00:00','Resolved','2025-10-21 16:00:00'),
(6, 10, 10, 'Packaging Issue', 'Food packaging was damaged', '2025-10-29 21:00:00','Pending', NULL);


-- ============================================================
--  TABLE: Refund
-- ============================================================

CREATE TABLE Refund (
    Refund_ID      BIGINT      PRIMARY KEY,
    OrderID        BIGINT,
    Complaint_ID   BIGINT,
    Refund_Amount  INT,
    Refund_Status  VARCHAR(10),                       -- Pending/Completed/Rejected
    Initiated_At   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    Completed_At   TIMESTAMP,
    Wallet_ID      BIGINT,
    FOREIGN KEY (OrderID)      REFERENCES Orders(OrderID),
    FOREIGN KEY (Complaint_ID) REFERENCES Complaint(Complaint_ID),
    FOREIGN KEY (Wallet_ID)    REFERENCES Wallet(Wallet_ID)
);

INSERT INTO Refund (Refund_ID, OrderID, Complaint_ID, Refund_Amount, Refund_Status, Completed_At, Wallet_ID) VALUES
(1, 4,  1,    200,'Completed','2025-10-23 19:00:00', 4),
(2, 6,  2,    150,'Completed','2025-10-25 20:00:00', 6),
(3, 9,  4,    100,'Completed','2025-10-28 23:00:00', 9),
(4, 8,  3,    120,'Pending',  NULL,                  8),
(5, 10, 6,     80,'Pending',  NULL,                  10),
(6, 5,  NULL,  50,'Completed','2025-10-24 15:00:00', 5);


-- ============================================================
--  QUERIES
-- ============================================================

-- Q1: Menu items per category with price stats (Restaurant 201)
SELECT
    MC.Category_Name,
    COUNT(MI.Item_ID)       AS Item_Count,
    ROUND(AVG(MI.Price), 2) AS Avg_Price,
    MIN(MI.Price)           AS Min_Price,
    MAX(MI.Price)           AS Max_Price
FROM Menu_Item MI
JOIN Menu_Category MC
    ON MI.Category_Name   = MC.Category_Name
   AND MI.Restaurant_ID   = MC.Restaurant_ID
WHERE MI.Restaurant_ID = 201
  AND MI.Is_Available  = TRUE
GROUP BY MC.Category_Name
ORDER BY Avg_Price DESC;


-- Q2: Most used payment method
SELECT
    Mode              AS Payment_Method,
    COUNT(Order_ID)   AS Times_Used,
    SUM(Amount)       AS Total_Revenue
FROM Payment
WHERE Status = 'Success'
GROUP BY Mode
ORDER BY Times_Used DESC;


-- Q3: Orders placed by users with wallet balance below ₹500
SELECT
    O.OrderID,
    U.User_Name,
    W.Balance    AS Wallet_Balance,
    O.Date_Time  AS Order_Time,
    O.Total_Amount
FROM Orders O
JOIN User   U ON O.UserID  = U.UserID
JOIN Wallet W ON U.UserID  = W.UserID
WHERE W.Balance < 500
ORDER BY W.Balance ASC;


-- Q4: Total revenue per restaurant
SELECT
    R.Resto_Name                      AS Restaurant,
    SUM(OI.Quantity * OI.Price)       AS Gross_Revenue,
    COUNT(DISTINCT O.OrderID)         AS Total_Orders,
    ROUND(AVG(OI.Quantity * OI.Price),2) AS Avg_Order_Value
FROM Orders O
JOIN Order_Item OI ON O.OrderID      = OI.OrderID
JOIN Menu_Item  MI ON OI.Item_ID     = MI.Item_ID
JOIN Restaurant R  ON MI.Restaurant_ID = R.Restaurant_ID
WHERE O.Order_Status != 'Cancelled'
GROUP BY R.Restaurant_ID, R.Resto_Name
ORDER BY Gross_Revenue DESC;


-- Q5: Top rated restaurants
SELECT
    R.Resto_Name,
    R.Rating,
    R.Total_Reviews,
    R.Avg_Delivery_Time AS Est_Delivery_Mins
FROM Restaurant R
WHERE R.Restaurant_Status = TRUE
ORDER BY R.Rating DESC
LIMIT 5;


-- Q6: Average delivery time per partner (minutes)
SELECT
    DP.Name                                                              AS Partner_Name,
    DP.City,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, D.Pickup_Time, D.Delivery_Time)),1) AS Avg_Delivery_Mins,
    COUNT(D.Delivery_ID)                                                 AS Total_Deliveries,
    DP.Rating                                                            AS Partner_Rating
FROM Delivery D
JOIN Delivery_Partner DP ON D.Partner_ID = DP.Partner_ID
WHERE D.Delivery_Time IS NOT NULL
GROUP BY DP.Partner_ID, DP.Name, DP.City, DP.Rating
ORDER BY Avg_Delivery_Mins ASC;


-- Q7: Pending complaints with user details
SELECT
    C.Complaint_ID,
    C.Issue_Type,
    C.Description,
    U.User_Name,
    U.Phone_No,
    O.Date_Time  AS Order_Time,
    C.Created_At AS Complaint_Time
FROM Complaint C
JOIN Orders O ON C.OrderID = O.OrderID
JOIN User   U ON C.UserID  = U.UserID
WHERE C.Status = 'Pending'
ORDER BY C.Created_At ASC;


-- Q8: Users with most orders and total spend
SELECT
    U.User_Name,
    COUNT(O.OrderID)   AS Total_Orders,
    SUM(O.Total_Amount) AS Total_Spent,
    W.Balance           AS Current_Wallet_Balance
FROM User U
JOIN Orders O  ON U.UserID = O.UserID
JOIN Wallet W  ON U.UserID = W.UserID
WHERE O.Order_Status != 'Cancelled'
GROUP BY U.UserID, U.User_Name, W.Balance
ORDER BY Total_Spent DESC;


-- Q9: Refund summary by status
SELECT
    Refund_Status,
    COUNT(Refund_ID)   AS Refund_Count,
    SUM(Refund_Amount) AS Total_Amount
FROM Refund
GROUP BY Refund_Status;


-- Q10: Top 5 most ordered menu items
SELECT
    MI.Item_Name,
    MI.Is_Veg,
    MI.Price,
    SUM(OI.Quantity) AS Total_Ordered,
    MI.Rating        AS Item_Rating
FROM Order_Item OI
JOIN Menu_Item MI ON OI.Item_ID = MI.Item_ID
GROUP BY MI.Item_ID, MI.Item_Name, MI.Is_Veg, MI.Price, MI.Rating
ORDER BY Total_Ordered DESC
LIMIT 5;


-- Q11: Monthly revenue trend
SELECT
    DATE_FORMAT(O.Date_Time, '%Y-%m') AS Month,
    COUNT(O.OrderID)                  AS Total_Orders,
    SUM(O.Total_Amount)               AS Total_Revenue
FROM Orders O
WHERE O.Order_Status != 'Cancelled'
GROUP BY DATE_FORMAT(O.Date_Time, '%Y-%m')
ORDER BY Month ASC;


-- Q12: Veg vs Non-Veg order split
SELECT
    CASE WHEN MI.Is_Veg = TRUE THEN 'Veg' ELSE 'Non-Veg' END AS Food_Type,
    COUNT(OI.Item_ID)        AS Items_Ordered,
    SUM(OI.Quantity)         AS Total_Quantity
FROM Order_Item OI
JOIN Menu_Item MI ON OI.Item_ID = MI.Item_ID
GROUP BY MI.Is_Veg;


-- Q13: City-wise order distribution
SELECT
    A.City,
    COUNT(O.OrderID)     AS Total_Orders,
    SUM(O.Total_Amount)  AS Revenue
FROM Orders O
JOIN Address A ON O.Add_ID = A.Add_ID
WHERE O.Order_Status != 'Cancelled'
GROUP BY A.City
ORDER BY Total_Orders DESC;


-- Q14: Coupon usage and savings
SELECT
    C.Coupon_Code,
    C.Description,
    C.Used_Count,
    C.Max_Uses,
    ROUND((C.Used_Count / C.Max_Uses) * 100, 1) AS Usage_Pct
FROM Coupon C
ORDER BY C.Used_Count DESC;


-- Q15: Unread notifications per user
SELECT
    U.User_Name,
    COUNT(N.Notification_ID) AS Unread_Count
FROM Notification N
JOIN User U ON N.UserID = U.UserID
WHERE N.Is_Read = FALSE
GROUP BY U.UserID, U.User_Name
ORDER BY Unread_Count DESC;


-- Q16: Live order tracking — full status timeline for an order
SELECT
    O.OrderID,
    U.User_Name,
    OSL.Status,
    OSL.Changed_At,
    OSL.Note
FROM Order_Status_Log OSL
JOIN Orders O ON OSL.OrderID = O.OrderID
JOIN User   U ON O.UserID    = U.UserID
WHERE O.OrderID = 1
ORDER BY OSL.Changed_At ASC;


-- Q17: Available delivery partners in a city
SELECT
    Partner_ID,
    Name,
    Phone_No,
    Vehicle_No,
    Rating,
    Total_Deliveries
FROM Delivery_Partner
WHERE Is_Available = TRUE
  AND City = 'Ahmedabad'
ORDER BY Rating DESC;


-- Q18: Cancelled orders with refund status
SELECT
    O.OrderID,
    U.User_Name,
    C.Reason          AS Cancel_Reason,
    C.Cancel_At,
    R.Refund_Amount,
    R.Refund_Status
FROM Cancellation C
JOIN Orders O  ON C.Order_ID   = O.OrderID
JOIN User   U  ON O.UserID     = U.UserID
LEFT JOIN Refund R ON R.OrderID = O.OrderID
ORDER BY C.Cancel_At DESC;