-- Question 1;
-- I'm using 'id' as an auto-incrementing primary key, so the database will automatically assign a unique ID to each row.
-- To ensure that I don't have duplicate product entries within the same order, I'm adding a UNIQUE KEY constraint on the combination of 'OrderID' and 'ProductID'.
CREATE TABLE ProductDetail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    OrderID      INT NOT NULL,
    ProductID    INT NOT NULL,
    ProductName  VARCHAR(100) NOT NULL,
    CustomerName VARCHAR(100),
    UNIQUE KEY (OrderID, ProductID) -- Prevents duplicate products per order
);

-- I'm inserting product details into the ProductDetail table, with one row per product.
  INSERT INTO ProductDetail (OrderID, ProductID, ProductName, CustomerName) VALUES
  (101, 1, 'Laptop',   'John Doe'),
  (101, 2, 'Mouse',    'John Doe'),
  (102, 3, 'Tablet',   'Jane Smith'),
  (102, 4, 'Keyboard', 'Jane Smith'),
  (102, 2, 'Mouse',    'Jane Smith'),
  (103, 5, 'Phone',    'Emily Clark');


-- Question 2. 

-- 1. Customers: isolates customer data (no repeats across orders)
CREATE TABLE Customers (
  CustomerID   INT AUTO_INCREMENT PRIMARY KEY,
  CustomerName VARCHAR(100) NOT NULL
);

-- 2. Orders: each order tied to one customer
CREATE TABLE Orders (
  OrderID      INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID   INT NOT NULL,
  OrderDate    DATETIME    DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 3. Products: master list of products
CREATE TABLE Products (
  ProductID    INT AUTO_INCREMENT PRIMARY KEY,
  ProductName  VARCHAR(100) NOT NULL
);

-- 4. OrderItems: links Orders ↔ Products and holds order-specific quantity
CREATE TABLE OrderItems (
  OrderID     INT NOT NULL,
  ProductID   INT NOT NULL,
  Quantity    INT NOT NULL DEFAULT 1,
  PRIMARY KEY (OrderID, ProductID),
  FOREIGN KEY (OrderID)  REFERENCES Orders(OrderID),
  FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- How I would insert data to the tables.

-- 1. Populate Customers
INSERT INTO Customers (CustomerID, CustomerName) VALUES
  (1, 'John Doe'),
  (2, 'Jane Smith'),
  (3, 'Emily Clark');

-- 2. Populate Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES
  (101, 1, '2025-05-01 10:00:00'),
  (102, 2, '2025-05-02 11:30:00'),
  (103, 3, '2025-05-03 14:45:00');

-- 3. Populate Products
INSERT INTO Products (ProductID, ProductName) VALUES
  (1, 'Laptop'),
  (2, 'Mouse'),
  (3, 'Tablet'),
  (4, 'Keyboard'),
  (5, 'Phone');

-- 4. Populate OrderItems (links orders ↔ products with quantities)
INSERT INTO OrderItems (OrderID, ProductID, Quantity) VALUES
  (101, 1, 2),   -- John Doe ordered 2 Laptops
  (101, 2, 1),   -- John Doe ordered 1 Mouse
  (102, 3, 3),   -- Jane Smith ordered 3 Tablets
  (102, 4, 2),   -- Jane Smith ordered 2 Keyboards
  (102, 2, 1),   -- Jane Smith ordered 1 Mouse
  (103, 5, 1);   -- Emily Clark ordered 1 Phone
