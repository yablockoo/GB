USE shop;
-- 1
START TRANSACTION;

INSERT INTO sample.users
	SELECT * FROM shop.users
		WHERE id = 1;

DELETE  FROM shop.users 
	WHERE id = 1;

COMMIT;

-- 2
DROP VIEW IF EXISTS v_name;
CREATE VIEW v_name AS
	SELECT p.name AS 'модель', c.name AS 'категория' 
	FROM products AS p
	JOIN
		catalogs AS c
	ON p.catalog_id= c.id;

SELECT * FROM v_name;
