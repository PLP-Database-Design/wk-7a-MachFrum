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


-- Question 2. Keyword on the question is (TRANSFORM)

-- 1. Create a pure Products master table (productName depends only on product_id)
CREATE TABLE Products (
  product_id   INT PRIMARY KEY,
  productName  VARCHAR(100) NOT NULL
);

-- How I would insert.
INSERT INTO Products (product_id, productName)
SELECT DISTINCT product_id, productName
FROM product;

-- 2. Create an OrderItems table where quantity depends on (order_id,product_id)
CREATE TABLE OrderItems (
  order_id    INT        NOT NULL,
  product_id  INT        NOT NULL,
  quantity    INT        NOT NULL,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id)   REFERENCES orders(OrderID),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- How I would insert.
INSERT INTO OrderItems (order_id, product_id, quantity)
SELECT order_id, product_id, quantity
FROM product;

-- 3. Drop the old combined table once you’ve verified the new ones:
DROP TABLE product;

