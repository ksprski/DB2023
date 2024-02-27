USE db_chweapon;
CREATE TABLE everything (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(100),
  product_description VARCHAR(255),
  product_category VARCHAR(50),
  supplier_name VARCHAR(100),
  supplier_email VARCHAR(100),
  customer_name VARCHAR(100),
  customer_phone VARCHAR(20),
  inventory_quantity INT,
  warehouse_adress VARCHAR(255),
  store_name VARCHAR(100),
  store_adress VARCHAR(255)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  order_date DATE,
  product_name INT,
  product_quantity INT,
  store_adress VARCHAR(255),
  supplier_name VARCHAR(100),
  FOREIGN KEY (product_name) REFERENCES everything (product_name),
  FOREIGN KEY (supplier_name) REFERENCES everything (supplier_name)
);