SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Cancellation;
DROP TABLE IF EXISTS Refund;
DROP TABLE IF EXISTS Complaint;
DROP TABLE IF EXISTS Wallet_TopUP;
DROP TABLE IF EXISTS Wallet_Transaction;
DROP TABLE IF EXISTS Wallet;
DROP TABLE IF EXISTS Discount;
DROP TABLE IF EXISTS Delivery;
DROP TABLE IF EXISTS Delivery_Partner;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Order_Item;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Cart_Item;
DROP TABLE IF EXISTS Cart;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Menu_Item;
DROP TABLE IF EXISTS Menu_Category;
DROP TABLE IF EXISTS Cuisine;
DROP TABLE IF EXISTS Restaurant_Address;
DROP TABLE IF EXISTS Restaurant;
DROP TABLE IF EXISTS User_Has_Address;
DROP TABLE IF EXISTS User_Address;
DROP TABLE IF EXISTS Users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Users (
    UserID      INT           NOT NULL AUTO_INCREMENT,
    User_Name   VARCHAR(100)  NOT NULL,
    Phone_No    BIGINT        NOT NULL UNIQUE
                              CHECK (Phone_No BETWEEN 6000000000 AND 9999999999),
    Email       VARCHAR(100)  NOT NULL UNIQUE,
    Password    VARCHAR(255)  NOT NULL,
    Role        ENUM('customer','restaurant_owner','admin') NOT NULL DEFAULT 'customer',
    Created_At  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_At  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (UserID)
) ENGINE=InnoDB;
-- FIX: Added UNIQUE + range CHECK on Phone_No (Indian mobiles: 6-9 series, 10 digits).
-- FIX: Added Updated_At for audit trail / change tracking.

CREATE TABLE User_Address (
    Add_ID      INT           NOT NULL AUTO_INCREMENT,
    Add_line_1  VARCHAR(255)  NOT NULL,
    Add_line_2  VARCHAR(255),
    Area        VARCHAR(100)  NOT NULL,
    City        VARCHAR(100)  NOT NULL,
    Pincode     INT           NOT NULL CHECK (Pincode BETWEEN 100000 AND 999999),
    PRIMARY KEY (Add_ID)
) ENGINE=InnoDB;

CREATE TABLE User_Has_Address (
    Add_ID  INT NOT NULL,
    UserID  INT NOT NULL,
    PRIMARY KEY (Add_ID, UserID),
    FOREIGN KEY (Add_ID) REFERENCES User_Address(Add_ID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)         ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Restaurant (
    Restaurant_ID      INT           NOT NULL AUTO_INCREMENT,
    Name               VARCHAR(150)  NOT NULL,
    Open_Time          TIME          NOT NULL,
    Close_Time         TIME          NOT NULL,
    Restaurant_Status  BOOLEAN       NOT NULL DEFAULT TRUE,
    FSSAI_License_No   BIGINT        NOT NULL UNIQUE,
    Contact_No         BIGINT        NOT NULL UNIQUE,
    Rating             FLOAT         NOT NULL DEFAULT 0.0 CHECK (Rating >= 0.0 AND Rating <= 5.0),
    Owner_UserID       INT           NOT NULL,
    Created_At         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_At         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Restaurant_ID),
    FOREIGN KEY (Owner_UserID) REFERENCES Users(UserID) ON DELETE RESTRICT,
    CHECK (Close_Time > Open_Time)
) ENGINE=InnoDB;
-- FIX: Open_Time/Close_Time changed DATETIME -> TIME (daily hours, not a specific calendar date).
-- FIX: Contact_No UNIQUE added (two restaurants can't share a phone).
-- FIX: Owner_UserID FK added (links restaurant to its owner in Users table).
-- FIX: Created_At + Updated_At added for audit trail.

CREATE TABLE Restaurant_Address (
    Add_ID        INT           NOT NULL AUTO_INCREMENT,
    Add_line_1    VARCHAR(255)  NOT NULL,
    Add_line_2    VARCHAR(255),
    Area          VARCHAR(100)  NOT NULL,
    City          VARCHAR(100)  NOT NULL,
    Pincode       INT           NOT NULL CHECK (Pincode BETWEEN 100000 AND 999999),
    Restaurant_ID INT           NOT NULL,
    PRIMARY KEY (Add_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Cuisine (
    Cuisine        VARCHAR(100) NOT NULL,
    Restaurant_ID  INT          NOT NULL,
    PRIMARY KEY (Cuisine, Restaurant_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Menu_Category (
    Category_Name  VARCHAR(100) NOT NULL,
    Type           ENUM('Veg','Non-Veg','Vegan') NOT NULL DEFAULT 'Veg',
    Restaurant_ID  INT          NOT NULL,
    PRIMARY KEY (Category_Name, Restaurant_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Menu_Item (
    Item_ID           INT           NOT NULL AUTO_INCREMENT,
    Item_Name         VARCHAR(150)  NOT NULL,
    Description       TEXT,
    Price             DECIMAL(8,2)  NOT NULL CHECK (Price > 0),
    Preparation_Time  INT           NOT NULL CHECK (Preparation_Time > 0),
    Is_Available      BOOLEAN       NOT NULL DEFAULT TRUE,
    Category_Name     VARCHAR(100)  NOT NULL,
    Restaurant_ID     INT           NOT NULL,
    Created_At        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_At        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Item_ID),
    FOREIGN KEY (Category_Name, Restaurant_ID)
        REFERENCES Menu_Category(Category_Name, Restaurant_ID)
        ON DELETE RESTRICT
) ENGINE=InnoDB;
-- FIX: Created_At + Updated_At added for menu version history / price change tracking.

CREATE TABLE Review (
    Review_ID      INT    NOT NULL AUTO_INCREMENT,
    Review         TEXT   NOT NULL,
    Rating         FLOAT  NOT NULL CHECK (Rating >= 1.0 AND Rating <= 5.0),
    Restaurant_ID  INT    NOT NULL,
    UserID         INT    NOT NULL,
    Created_At     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Review_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID) ON DELETE CASCADE,
    FOREIGN KEY (UserID)        REFERENCES Users(UserID)              ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Cart (
    Cart_ID     INT       NOT NULL AUTO_INCREMENT,
    Created_At  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status      ENUM('Active','Checked Out','Abandoned') NOT NULL DEFAULT 'Active',
    UserID      INT       NOT NULL,
    PRIMARY KEY (Cart_ID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Cart_Item (
    Item_ID  INT NOT NULL,
    Cart_ID  INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1 CHECK (Quantity > 0),
    PRIMARY KEY (Item_ID, Cart_ID),
    FOREIGN KEY (Item_ID) REFERENCES Menu_Item(Item_ID) ON DELETE CASCADE,
    FOREIGN KEY (Cart_ID) REFERENCES Cart(Cart_ID)      ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Orders (
    OrderID        INT       NOT NULL AUTO_INCREMENT,
    Date_Time      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UserID         INT       NOT NULL,
    Restaurant_ID  INT       NOT NULL,
    Status         ENUM('pending','confirmed','preparing','out_for_delivery','delivered','cancelled')
                   NOT NULL DEFAULT 'pending',
    Total_Amount   DECIMAL(10,2) NOT NULL CHECK (Total_Amount >= 0),
    Updated_At     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (OrderID),
    FOREIGN KEY (UserID)        REFERENCES Users(UserID)           ON DELETE RESTRICT,
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurant(Restaurant_ID) ON DELETE RESTRICT
) ENGINE=InnoDB;
-- FIX: Updated_At added -- essential for tracking order status changes over time.

CREATE TABLE Order_Item (
    Item_ID   INT NOT NULL,
    OrderID   INT NOT NULL,
    Quantity  INT NOT NULL DEFAULT 1 CHECK (Quantity > 0),
    Unit_Price DECIMAL(8,2) NOT NULL CHECK (Unit_Price >= 0),
    PRIMARY KEY (Item_ID, OrderID),
    FOREIGN KEY (Item_ID) REFERENCES Menu_Item(Item_ID) ON DELETE RESTRICT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Payment (
    Transaction_ID  INT           NOT NULL AUTO_INCREMENT,
    Mode            ENUM('UPI','Card','Cash','Wallet','NetBanking') NOT NULL,
    Status          ENUM('Pending','Paid','Failed','Refunded') NOT NULL DEFAULT 'Pending',
    Amount          DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    Gateway_Ref     VARCHAR(100),
    Paid_At         TIMESTAMP,
    Order_ID        INT           NOT NULL UNIQUE,
    PRIMARY KEY (Transaction_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(OrderID) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Delivery_Partner (
    Partner_ID  INT           NOT NULL AUTO_INCREMENT,
    Name        VARCHAR(100)  NOT NULL,
    Phone_No    BIGINT        NOT NULL UNIQUE
                              CHECK (Phone_No BETWEEN 6000000000 AND 9999999999),
    Vehicle_No  VARCHAR(20)   NOT NULL UNIQUE,
    Rating      FLOAT         NOT NULL DEFAULT 0.0 CHECK (Rating >= 0.0 AND Rating <= 5.0),
    Is_Active   BOOLEAN       NOT NULL DEFAULT TRUE,
    Created_At  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Partner_ID)
) ENGINE=InnoDB;
-- FIX: Phone_No UNIQUE + range CHECK added.
-- FIX: Created_At added for partner onboarding audit.

CREATE TABLE Delivery (
    Delivery_ID    INT       NOT NULL AUTO_INCREMENT,
    Pickup_Time    DATETIME,
    Delivery_Time  DATETIME,
    Status         ENUM('Assigned','Picked Up','In Transit','Delivered','Failed')
                   NOT NULL DEFAULT 'Assigned',
    OrderID        INT       NOT NULL UNIQUE,
    Partner_ID     INT       NOT NULL,
    PRIMARY KEY (Delivery_ID),
    FOREIGN KEY (OrderID)    REFERENCES Orders(OrderID)            ON DELETE RESTRICT,
    FOREIGN KEY (Partner_ID) REFERENCES Delivery_Partner(Partner_ID) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Wallet (
    Wallet_ID   INT           NOT NULL AUTO_INCREMENT,
    Balance     DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (Balance >= 0),
    Created_At  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UserID      INT           NOT NULL UNIQUE,
    PRIMARY KEY (Wallet_ID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Wallet_Transaction (
    Wallet_ID       INT           NOT NULL,
    Transaction_ID  INT           NOT NULL AUTO_INCREMENT,
    Type            ENUM('Credit','Debit') NOT NULL,
    Amount          DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    Date_Time       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Transaction_ID),
    FOREIGN KEY (Wallet_ID) REFERENCES Wallet(Wallet_ID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Wallet_TopUP (
    Transaction_ID   INT           NOT NULL,
    Status           ENUM('Success','Failed','Pending') NOT NULL DEFAULT 'Pending',
    Payment_mode     ENUM('UPI','Card','NetBanking')    NOT NULL,
    Transaction_Ref  BIGINT        NOT NULL UNIQUE,
    Date_Time        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Wallet_ID        INT           NOT NULL,
    PRIMARY KEY (Transaction_ID),
    FOREIGN KEY (Transaction_ID) REFERENCES Wallet_Transaction(Transaction_ID) ON DELETE CASCADE,
    FOREIGN KEY (Wallet_ID)      REFERENCES Wallet(Wallet_ID)                  ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Discount (
    Discount_ID      INT           NOT NULL AUTO_INCREMENT,
    Discount_PR      FLOAT         NOT NULL CHECK (Discount_PR >= 0 AND Discount_PR <= 100),
    Discount_Amount  DECIMAL(8,2)  NOT NULL CHECK (Discount_Amount >= 0),
    OrderID          INT           NOT NULL UNIQUE,
    PRIMARY KEY (Discount_ID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Complaint (
    Complaint_ID  INT       NOT NULL AUTO_INCREMENT,
    OrderID       INT       NOT NULL,
    Issue_Type    ENUM('Late Delivery','Wrong Item','Cold Food','Missing Item',
                       'Quality Issue','Packaging','Spill','Other') NOT NULL,
    Description   TEXT      NOT NULL,
    Created_At    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status        ENUM('Open','Under Review','Resolved','Closed') NOT NULL DEFAULT 'Open',
    Resolved_At   TIMESTAMP,
    PRIMARY KEY (Complaint_ID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Refund (
    Refund_ID      INT           NOT NULL AUTO_INCREMENT,
    OrderID        INT           NOT NULL,
    Complaint_ID   INT           NOT NULL,
    Refund_Amount  DECIMAL(8,2)  NOT NULL CHECK (Refund_Amount >= 0),
    Refund_Status  ENUM('Pending','Completed','Rejected') NOT NULL DEFAULT 'Pending',
    Completed_At   TIMESTAMP,
    Wallet_ID      INT           NOT NULL,
    PRIMARY KEY (Refund_ID),
    FOREIGN KEY (OrderID)      REFERENCES Orders(OrderID)       ON DELETE RESTRICT,
    FOREIGN KEY (Complaint_ID) REFERENCES Complaint(Complaint_ID) ON DELETE RESTRICT,
    FOREIGN KEY (Wallet_ID)    REFERENCES Wallet(Wallet_ID)     ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Cancellation (
    Cancellation_ID      INT           NOT NULL AUTO_INCREMENT,
    Cancelled_By         ENUM('Customer','Restaurant','System') NOT NULL,
    Cancellation_Reason  TEXT          NOT NULL,
    Cancelled_At         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Refund_Eligible      BOOLEAN       NOT NULL DEFAULT TRUE,
    Penalty_Amount       DECIMAL(8,2)  NOT NULL DEFAULT 0.00 CHECK (Penalty_Amount >= 0),
    OrderID              INT           NOT NULL UNIQUE,
    PRIMARY KEY (Cancellation_ID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE RESTRICT
) ENGINE=InnoDB;
