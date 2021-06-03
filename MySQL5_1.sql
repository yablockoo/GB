DROP DATABASE IF EXISTS l41;
CREATE DATABASE l41;
USE l41;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` SERIAL PRIMARY KEY,
  `name` VARCHAR(255),
  `created_at` DATETIME,
  `updated_at` DATETIME
);

INSERT INTO users (name, created_at, updated_at)
VALUES
	('Ivan', NULL, NULL),
	('Maria', NULL, NULL),
	('Vasiliy', NULL, NULL),
	('Miron', NULL, NULL),
	('Bogdan', NULL, NULL);

-- №1
UPDATE users
	SET created_at = now(), updated_at = now();

SELECT * FROM users




