CREATE DATABASE db_chweapon;
USE db_chweapon;
SET sql_mode = "";
SET NAMES 'utf8mb4';
SET CHARACTER SET utf8mb4;


DROP TABLE products;
CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(100),
  product_description VARCHAR(255),
  product_category VARCHAR(50),
  supplier_id INT,
  warehouse_id INT,
  FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
);

INSERT INTO products (product_id, product_name, product_description, product_category, supplier_id, warehouse_id)
VALUES 
(1, 'Mustard Gas', 'A chemical weapon used in World War I', 'Chemical Weapons', 1, 2),
(2, 'Phosgene', 'A chemical weapon used in World War I', 'Chemical Weapons', 2, 3),
(3, 'Chlorine', 'A chemical weapon used by Russia during World War I', 'Chemical Weapons', 2, 3),
(4, 'Chloropicrin', 'A chemical weapon used by Russia during World War I', 'Chemical Weapons', 4, 4),
(5, 'Ethyldichloroarsine', 'A chemical weapon that Russia never developed due to insufficient technological advancement', 'Chemical Weapons', 6, 5),
(6, 'Binary Munitions', 'A type of chemical munition used by the United States', 'Chemical Weapons', 5, 6);


DROP TABLE orders;
CREATE TABLE orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT,
  store_id INT,
  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

INSERT INTO orders (order_id, customer_id, store_id)
VALUES 
(1, 1, 4),
(2, 2,  3),
(3, 4,  3),
(4, 4,  1),
(5, 3,  5),
(6, 6, 4);



DROP TABLE suppliers;
CREATE TABLE suppliers (
  supplier_id INT PRIMARY KEY AUTO_INCREMENT,
  supplier_name VARCHAR(100),
  supplier_email VARCHAR(100)
);

 INSERT INTO suppliers (supplier_id, supplier_name, supplier_email)
 VALUES 
 (1, 'Supplier A', 'supplierA@example.com'),
 (2, 'Supplier B', 'supplierB@example.com'),
 (3, 'Supplier C', 'supplierC@example.com'),
 (4, 'Supplier D', 'supplierD@example.com'),
 (5, 'Supplier E', 'supplierE@example.com'),
 (6, 'Supplier F', 'supplierF@example.com');



DROP TABLE customers;
CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_name VARCHAR(512),
  customer_phone VARCHAR(20)
);

 INSERT INTO customers (customer_id, customer_name, customer_phone)
 VALUES 
 (1, 'John Doe', '123-456-7890'),
 (2, 'Jane Smith', '098-765-4321'),
 (3, 'Robert Johnson', '111-222-3333'),
 (4, 'Emily Davis', '444-555-6666'),
 (5, 'Michael Brown', '777-888-9999'),
 (6, 'Sarah Williams', '222-333-4444');

  
UPDATE customers SET customer_name = TO_BASE64(AES_ENCRYPT(customer_name, "42BED335F64171E6"));
select * from customers;
UPDATE customers SET customer_name = AES_DECRYPT(FROM_BASE64(customer_name), "42BED335F64171E6");

Set NAMES utf8mb4;
ALTER TABLE customers CHANGE customer_name customer_name VARCHAR(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER DATABASE db_chweapon CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

DROP TABLE inventory;
CREATE TABLE inventory (
  inventory_id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT,
  quantity INT,
  warehouse_id INT,
  FOREIGN KEY (warehouse_id) REFERENCES warehouses (warehouse_id),
  FOREIGN KEY (product_id) REFERENCES products (product_id)
);

INSERT INTO inventory (product_id, quantity, warehouse_id)
VALUES 
(1, 100, 1),
(2, 200, 2),
(3, 300, 3),
(4,  400, 4);



DROP TABLE warehouses;
CREATE TABLE warehouses(
  warehouse_id INT PRIMARY KEY AUTO_INCREMENT,
  warehouse_country VARCHAR(255),
  warehouse_city VARCHAR(255),
  warehouse_street VARCHAR(255)
);

 INSERT INTO warehouses (warehouse_id, warehouse_country, warehouse_city, warehouse_street)
 VALUES 
 (1, 'USA', 'New York', '5th Avenue'),
 (2, 'Canada', 'Toronto', 'Bloor Street'),
 (3, 'UK', 'London', 'Baker Street'),
 (4, 'Australia', 'Sydney', 'George Street');

SELECT * FROM inventory;
  
  DROP TABLE stores;
  CREATE TABLE stores (
  store_id INT PRIMARY KEY AUTO_INCREMENT,
  store_name VARCHAR(100),
  store_country VARCHAR(255),
  store_city VARCHAR(255),
  store_street VARCHAR(255)
);

ALTER TABLE stores
ADD COLUMN warehouse_id INT,
ADD FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id);

 INSERT INTO stores (store_id, store_name, store_country, store_city, store_street, warehouse_id)
 VALUES 
 (1, 'Store A', 'USA', 'New York', '5th Avenue',1),
 (2, 'Store B', 'Canada', 'Toronto', 'Bloor Street',1),
 (3, 'Store C', 'UK', 'London', 'Baker Street',1),
 (4, 'Store D', 'Australia', 'Sydney', 'George Street',1),
 (5, 'Store E', 'Germany', 'Berlin', 'Unter den Linden',1),
 (6, 'Store F', 'France', 'Paris', 'Champs-Élysées',1);

  
  DROP TABLE order_products;
  CREATE TABLE order_products (
  order_product_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT,
  product_id INT,
  order_product_quantity INT,
  order_product_date DATE,
  FOREIGN KEY (order_id) REFERENCES orders (order_id),
  FOREIGN KEY (product_id) REFERENCES products (product_id)
);

 INSERT INTO order_products (order_id, product_id, order_product_quantity, order_product_date)
 VALUES 
 (1, 2,  5, '2023-01-01'),
 (2, 1, 3, '2023-02-01'),
 (3, 3, 7, '2023-03-01'),
 (4, 3, 2, '2023-04-01'),
 (5,1, 6, '2023-05-01'),
 (6, 2, 8, '2023-06-01');

select * from order_products;
SHOW TABLES FROM db_chweapon;

# SELECT HEX(RANDOM_BYTES(8));
# 42BED335F64171E6

SELECT
    p.product_name,
    GROUP_CONCAT(DISTINCT w.warehouse_city ORDER BY w.warehouse_city) AS available_cities
FROM
    products p
JOIN
    inventory i ON p.product_id = i.product_id
JOIN
    warehouses w ON i.warehouse_id = w.warehouse_id
GROUP BY
    p.product_name;


#____________________________________ЛАБ 5______________________________

#___________________________________2______________________________________

CREATE TABLE keep_inventory (
  keep_inventory_id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT,
  quantity INT,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO keep_inventory (product_id, quantity)
VALUES
  (1, 50),   
  (2, 30),   
  (3, 40);   


DELIMITER //

CREATE TRIGGER after_purchase
AFTER INSERT ON order_products
FOR EACH ROW
BEGIN
  DECLARE available_quantity INT;
  DECLARE order_quantity INT;

  SELECT quantity INTO available_quantity
  FROM inventory
  WHERE product_id = NEW.product_id;

  SET order_quantity = NEW.order_product_quantity;


  IF available_quantity >= order_quantity THEN

    UPDATE inventory
    SET quantity = available_quantity - order_quantity
    WHERE product_id = NEW.product_id;
  ELSE

    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'нет продукта';
  END IF;
END //
DELIMITER ;




SELECT * FROM inventory;
SHOW TRIGGERS;
DROP TRIGGER check_inventory_threshold;
DELIMITER //
CREATE TRIGGER check_inventory_threshold
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
  DECLARE min_threshold INT;
  DECLARE current_quantity INT;
  DECLARE external_quantity INT;

  SET min_threshold = 10;
  SET current_quantity = NEW.quantity;

  IF current_quantity <= min_threshold THEN
    SELECT quantity INTO external_quantity
    FROM keep_inventory
    WHERE product_id = NEW.product_id;

    IF external_quantity IS NOT NULL AND external_quantity >= 5 THEN
      SET NEW.quantity = NEW.quantity + 5;

      INSERT INTO OrdersFromKeep (product_id, order_product_quantity, order_product_date)
      VALUES (NEW.product_id, 5, CURRENT_DATE());

      UPDATE keep_inventory
      SET quantity = external_quantity - 5
      WHERE product_id = NEW.product_id;
    ELSE
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Внешний склад пуст';
    END IF;
  END IF;
END//
DELIMITER;


ALTER TABLE orders ADD COLUMN confirmed BOOLEAN DEFAULT 0;

DROP PROCEDURE IF EXISTS PurchaseProduct;
DELIMITER //
CREATE PROCEDURE PurchaseProduct(
  IN p_customer_id INT,
  IN p_product_id INT,
  IN p_quantity INT
)
BEGIN
  DECLARE available_quantity INT;
  DECLARE order_amount INT;

  START TRANSACTION;

  SELECT SUM(quantity) INTO available_quantity
  FROM inventory
  WHERE product_id = p_product_id;

  IF available_quantity >= p_quantity THEN
    SET order_amount = p_quantity;

    UPDATE inventory
    SET quantity = available_quantity - p_quantity
    WHERE product_id = p_product_id;

    INSERT INTO order_products (order_id, product_id, order_product_quantity, order_product_date)
    VALUES (NULL, p_product_id, order_amount, CURRENT_DATE());
    COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'нет товара';
  END IF;

END //

DELIMITER ;

CREATE TABLE OrdersFromKeep(
order_id INT PRIMARY KEY AUTO_INCREMENT, 
product_id INT, 
order_product_quantity INT,
order_product_date DATE
);

DELIMITER //
CREATE PROCEDURE UpdateInventoryFromKeep(IN product_id INT, IN quantity_to_move INT)
BEGIN
  UPDATE inventory
  SET quantity = quantity + quantity_to_move
  WHERE product_id = product_id;

  UPDATE keep_inventory
  SET quantity = quantity - quantity_to_move
  WHERE product_id = product_id;
END //
DELIMITER ;

# в таблицу с заказами внести запись о заказе со склада
CALL PurchaseProduct(1, 1, 3);

CALL PurchaseProduct(2, 2, 500);

CALL PurchaseProduct(3, 1, 5);

SELECT * FROM order_products;
SELECT * FROM OrdersFromKeep;

SELECT * FROM keep_inventory;

CALL PurchaseProduct(4, 1, 5);

SELECT * FROM inventory;
SELECT * FROM order_products;


#___________________________________3______________________________________

#  3.1 Разработайте ряд ключевых учётных записей пользователей системы. 

DROP USER 'reader'@'localhost';

CREATE USER 'admin'@'localhost' IDENTIFIED BY '1';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;

CREATE USER 'reader'@'localhost' IDENTIFIED BY '2';
GRANT SELECT ON db_chweapon.* TO 'reader'@'localhost';

CREATE USER 'writer'@'localhost' IDENTIFIED BY '3';
GRANT INSERT ON db_chweapon.* TO 'writer'@'localhost';



# 3.2
# в № 2

# 3.3

# Индекс нужен для ускорения поиска товаров по поставщику
CREATE INDEX idx_supplier_id ON products (supplier_id);

# Индекс для ускорения поиска заказов по клиенту и магазину
CREATE INDEX idx_customer ON orders(customer_id);



# 3.4 

UPDATE customers SET customer_name = TO_BASE64(AES_ENCRYPT(customer_name, "42BED335F64171E6"));
SELECT * FROM customers;
UPDATE customers SET customer_name = AES_DECRYPT(FROM_BASE64(customer_name), "42BED335F64171E6");

SET NAMES utf8mb4;
ALTER TABLE customers CHANGE customer_name customer_name VARCHAR(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER DATABASE db_chweapon CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;



