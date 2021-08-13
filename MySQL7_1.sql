USE l7;

-- 1
SELECT name
FROM users
JOIN orders 
ON users.id = orders.user_id;

-- 2
SELECT c.name, p.name, p.description, p.price 
FROM catalogs c
JOIN products p 
ON p.catalog_id = c.id;

