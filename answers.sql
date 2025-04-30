-- How I would avoid the issue in the first place.

-- Question 1. Achieving 1NF
-- To eliminate the multi-valued Products field, I would split it so that each row holds exactly one product. 
-- 1. Create a new table in 1NF
CREATE TABLE ProductDetail1NF (
  OrderID        INT,
  CustomerName   VARCHAR(100),
  Product        VARCHAR(100)
);

-- 2. Populate it by splitting the comma-separated list
INSERT INTO ProductDetail1NF (OrderID, CustomerName, Product)
SELECT 
  OrderID,
  CustomerName,
  LTRIM(RTRIM(value)) AS Product
FROM ProductDetail
CROSS APPLY STRING_SPLIT(Products, ',');

-- By using STRING_SPLIT which is concise and leverages built-in functionality; it enforces atomicity (one product per row) 
-- and prevents anomalies when querying or updating products.

-- Question 2. Achieving 2NF
-- Here I would remove the partial dependency (CustomerName depends only on OrderID, not on the full composite key). 
-- I do this by factoring out orders into their own table:
-- 1. Create Orders and OrderItems tables
CREATE TABLE Orders (
  OrderID       INT PRIMARY KEY,
  CustomerName  VARCHAR(100)
);

CREATE TABLE OrderItems (
  OrderID   INT,
  Product   VARCHAR(100),
  Quantity  INT,
  PRIMARY KEY (OrderID, Product),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- 2. Populate Orders (each order once)
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- 3. Populate OrderItems (the 1NF detail)
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- By splitting into Orders and OrderItems removes redundancy of CustomerName and ensures that every non-key attribute 
-- in each table fully depends on its table’s primary key, eliminating update anomalies.