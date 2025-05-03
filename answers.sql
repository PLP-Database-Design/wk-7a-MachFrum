-- ================================================
-- Proactive Design: Building a Normalized Schema from Scratch (2NF)
-- ================================================
-- Basically, how I would design a normalized schema from scratch to avoid future issues.

USE normalizationDB;

-- I am making an assumption that the database was created this way.

-- Original Schema: Violates 1NF

CREATE TABLE ProductDetail (
  OrderID INT,
  CustomerName VARCHAR(100),
  Products VARCHAR(255) -- comma-separated list of products
);

-- I create the Orders table to store each order once, avoiding CustomerName duplication.
-- CustomerName depends ONLY on OrderID (no partial dependencies).
CREATE TABLE Orders (
  OrderID      INT PRIMARY KEY,       -- Natural key for orders (unique identifier)
  CustomerName VARCHAR(100) NOT NULL  -- Store customer once per order (no redundancy)
);

-- I create the OrderItems table to store one product per row, ensuring atomicity.
-- Quantity depends on BOTH OrderID and Product (no partial dependencies).
CREATE TABLE OrderItems (
  OrderID  INT NOT NULL,              -- Foreign key linking to Orders
  Product  VARCHAR(100) NOT NULL,     -- Atomic product (no comma-separated lists)
  Quantity INT          NOT NULL,     -- Quantity depends on OrderID+Product
  PRIMARY KEY (OrderID, Product),     -- Composite key enforces uniqueness
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) -- Ensure valid orders exist
);

-- I insert sample data directly into the normalized tables to avoid future cleanup.
-- This reflects how data should be captured in a real-world system.
INSERT INTO Orders (OrderID, CustomerName) VALUES
  (101, 'John Doe'),
  (102, 'Jane Smith'),
  (103, 'Emily Clark');

-- I insert product-quantity pairs as separate rows to comply with 1NF/2NF upfront.
INSERT INTO OrderItems (OrderID, Product, Quantity) VALUES
  (101, 'Laptop', 2),
  (101, 'Mouse',  1),
  (102, 'Tablet',   3),
  (102, 'Keyboard', 1),
  (102, 'Mouse',    2),
  (103, 'Phone',    1);

-- ================================================
-- Migration Script: Fixing an Existing Database
-- ================================================

-- ================================
-- STEP 1: Convert ProductDetail → 1NF
-- ================================

-- I am making an assumption that the database was created this way.

--Original Schema: Violates 2NF

CREATE TABLE OrderDetails (
  OrderID INT,
  CustomerName VARCHAR(100),
  Product VARCHAR(100),
  Quantity INT
);

-- Here's the migration script to convert the existing denormalized table into a normalized schema.

START TRANSACTION;

-- I rename the old table to avoid conflicts during migration.
ALTER TABLE ProductDetail RENAME TO ProductDetail_OLD;

-- I create a new 1NF table to hold split products.
-- Primary key ensures no duplicate products per order.
CREATE TABLE ProductDetail (
  OrderID      INT,
  CustomerName VARCHAR(100),
  Product      VARCHAR(100),
  PRIMARY KEY (OrderID, Product) -- Enforce one product per row
);

-- I split comma-separated products using a recursive CTE.
-- This handles any number of products dynamically (not just 3).
WITH RECURSIVE split_products AS (
  -- Anchor query: Extract the first product from the list
  SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(Products, ',', 1)) AS Product,
    SUBSTR(Products, LENGTH(SUBSTRING_INDEX(Products, ',', 1)) + 2) AS Remaining
  FROM ProductDetail_OLD
  UNION ALL
  -- Recursive query: Keep splitting until no products remain
  SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(Remaining, ',', 1)),
    SUBSTR(Remaining, LENGTH(SUBSTRING_INDEX(Remaining, ',', 1)) + 2)
  FROM split_products
  WHERE Remaining <> '' -- Stop when no products are left
)
-- I insert the cleaned, split data into the new 1NF table.
INSERT INTO ProductDetail (OrderID, CustomerName, Product)
SELECT OrderID, CustomerName, Product
FROM split_products
WHERE Product <> ''; -- Skip empty strings

-- I clean up the old table after successful migration.
DROP TABLE ProductDetail_OLD;

COMMIT;


-- ================================
-- STEP 2: Convert OrderDetails → 2NF
-- ================================
START TRANSACTION;

-- I rename the old table to preserve data during migration.
ALTER TABLE OrderDetails RENAME TO OrderDetails_OLD;

-- I create the Orders table to isolate CustomerName dependency on OrderID.
CREATE TABLE Orders (
  OrderID      INT PRIMARY KEY,
  CustomerName VARCHAR(100) NOT NULL
);

-- I migrate unique orders to avoid CustomerName redundancy.
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName -- Remove duplicates
FROM OrderDetails_OLD;

-- I create the OrderItems table to store product-level data.
-- Quantity now depends on the full composite key (OrderID + Product).
CREATE TABLE OrderItems (
  OrderID  INT NOT NULL,
  Product  VARCHAR(100) NOT NULL,
  Quantity INT          NOT NULL,
  PRIMARY KEY (OrderID, Product),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) -- Enforce valid orders
);

-- I migrate product-quantity pairs, retaining their relationship to orders.
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails_OLD;

-- I remove the old denormalized table after successful migration.
DROP TABLE OrderDetails_OLD;

COMMIT;