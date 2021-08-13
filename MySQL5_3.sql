DROP DATABASE IF EXISTS l53;
CREATE DATABASE l53;
USE l53;

DROP TABLE IF EXISTS `storehouse_products`;
CREATE TABLE `storehouse_products` (
  `id` SERIAL PRIMARY KEY,
  `quantity` bigint(20) unsigned
);

INSERT INTO storehouse_products (quantity)
VALUES
	(0),
	(2500),
	(0),
	(30),
	(500),
	(1);

SELECT * FROM storehouse_products ORDER BY IF(quantity > 0, 0, 1), quantity;