use db_chweapon;

#  Запрос к 4 –ем таблицам одновременно. 
SELECT
  o.order_id,
  c.customer_name,
  s.store_name,
  op.order_product_quantity,
  p.product_name
FROM
  orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN stores s ON o.store_id = s.store_id
LEFT JOIN order_products op ON o.order_id = op.order_id
LEFT JOIN products p ON op.product_id = p.product_id
LEFT JOIN inventory inv ON p.product_id = inv.product_id;


# 5 запросов на группировку.
SELECT customers.customer_id, customers.customer_name, COUNT(orders.order_id) AS NumOfOrders
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id;

SELECT product_category, COUNT(*) AS NumOfProductsInCategory
FROM products
GROUP BY product_category;

SELECT
  customers.customer_id,
  customers.customer_name,
  COUNT(order_products.product_id) AS total_ordered_products
FROM
  customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
LEFT JOIN order_products ON orders.order_id = order_products.order_id
GROUP BY
  customers.customer_id, customers.customer_name;


SELECT
  products.product_name,
  SUM(order_products.order_product_quantity) AS total_quantity
FROM
  products
LEFT JOIN order_products ON products.product_id = order_products.product_id
GROUP BY
  products.product_name;


SELECT
  warehouses.warehouse_id,
  warehouses.warehouse_city,
  SUM(inventory.quantity) AS total_quantity
FROM
  warehouses
LEFT JOIN inventory ON warehouses.warehouse_id = inventory.warehouse_id
GROUP BY
  warehouses.warehouse_id, warehouses.warehouse_city;


# 3 вложенных запроса. 
SELECT product_name
FROM products
WHERE product_id IN (
   SELECT product_id
   FROM order_products
   GROUP BY product_id
   HAVING COUNT(*) >= 1
);

SELECT
  products.product_id,
  products.product_name,
  inventory.quantity
FROM
  products
JOIN inventory ON products.product_id = inventory.product_id
WHERE
  quantity > (SELECT AVG(quantity) FROM inventory);

#  клиенты, у которых количество заказов больше среднего
SELECT
  customer_id,
  customer_name
FROM
  customers
WHERE
  (SELECT COUNT(order_id) FROM orders WHERE customer_id = customers.customer_id) > 
  (SELECT AVG(order_count) FROM (SELECT customer_id, COUNT(order_id) AS order_count FROM orders GROUP BY customer_id) AS avg_orders);


SELECT AVG(order_count) FROM (SELECT customer_id, COUNT(order_id) AS order_count FROM orders GROUP BY customer_id) AS avg_orders;

# Запрос с использованием операций над множествами.

-- продукты на складе, исключая те, которые были заказаны
SELECT
  product_id,
  product_name
FROM
  products
EXCEPT
SELECT
  products.product_id,
  products.product_name
FROM
  products
JOIN order_products ON products.product_id = order_products.product_id;


# Обновление таблиц с использованием оператора соединения.

UPDATE inventory
JOIN products ON inventory.product_id = products.product_id
SET inventory.quantity = inventory.quantity + 10
WHERE products.product_id = 1;

SELECT * FROM inventory;

# Запрос с использованием оконных функций.

SELECT DISTINCT customer_id, COUNT(*) OVER (PARTITION BY customer_id) AS NumOfOrdersAsc
FROM orders;


# представления

CREATE VIEW admin_chemical_weapons AS
SELECT
  products.product_id,
  products.product_name,
  products.product_description,
  products.product_category,
  suppliers.supplier_name,
  suppliers.supplier_email,
  warehouses.warehouse_country,
  warehouses.warehouse_city,
  warehouses.warehouse_street,
  inventory.quantity
FROM
  products
JOIN
  suppliers ON products.supplier_id = suppliers.supplier_id
JOIN
  inventory ON products.product_id = inventory.product_id
JOIN
  warehouses ON inventory.warehouse_id = warehouses.warehouse_id;

select * from admin_chemical_weapons;

DROP VIEW customer_view;

  CREATE VIEW customer_view AS
SELECT
  p.product_name,
  p.product_description,
  p.product_category,
  i.quantity,
  (
    SELECT
      GROUP_CONCAT(DISTINCT w.warehouse_city ORDER BY w.warehouse_city)
    FROM
      warehouses w
    WHERE
      w.warehouse_id = i.warehouse_id
  ) AS available_cities
FROM
  products p
JOIN
  inventory i ON p.product_id = i.product_id;

  
  SELECT * FROM customer_view;
  
DROP VIEW logistics_manager_view;  
CREATE VIEW logistics_manager_view AS
SELECT
  w.warehouse_id,
  w.warehouse_country,
  w.warehouse_city,
  w.warehouse_street,
  p.product_id,
  p.product_name,
  p.product_category,
  i.quantity,
  s.supplier_name,
  s.supplier_email
FROM
  warehouses w
JOIN
  inventory i ON w.warehouse_id = i.warehouse_id
JOIN
  products p ON i.product_id = p.product_id
JOIN
  suppliers s ON p.supplier_id = s.supplier_id;
  
  SELECT * FROM logistics_manager_view;

SET SQL_SAFE_UPDATES = 1;

	DROP VIEW customer_view2;
CREATE VIEW customer_view2 AS
SELECT
  p.product_id,
  p.product_name
FROM
  products p
  WHERE product_id > 3
  WITH check option;
  
  SELECT * FROM products;
  
SELECT * FROM customer_view2;
# апдейт с check option почему выполнился
UPDATE customer_view2 SET product_name =  'Mustard Gas' WHERE product_id = 5;

# в TXT файле один запрос, считать его через терминал

	DROP VIEW customer_view3;
CREATE VIEW customer_view3 AS
SELECT
  i.product_id,
  i.quantity
FROM
  inventory i
  WHERE quantity > 300
  WITH check option;
  
SELECT * FROM inventory;
  
SELECT * FROM customer_view3;

UPDATE customer_view3 SET quantity = 10 WHERE product_id = 6;
