DROP DATABASE IF EXISTS l54;
CREATE DATABASE l54;
USE l54;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` SERIAL PRIMARY KEY,
  `name` VARCHAR(255),
  `age` int(20)
);

INSERT INTO users (name, age)
VALUES
	('Ivan', 25),
	('Maria', 34),
	('Vasiliy', 56),
	('Miron', 78),
	('Bogdan', 12);

SELECT AVG(age) AS "Средний возраст"
FROM users;	