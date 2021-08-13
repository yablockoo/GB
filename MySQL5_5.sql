DROP DATABASE IF EXISTS l55;
CREATE DATABASE l55;
USE l55;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` SERIAL PRIMARY KEY,
  `name` VARCHAR(255),
  `birthday` DATE
);

INSERT INTO users (name, birthday)
VALUES
	('Ivan', '2015-11-02'),
	('Maria', '2015-11-03'),
	('Vasiliy', '2015-11-04'),
	('Miron', '2015-11-05'),
	('Bogdan', '2015-11-06'),
	('Boris', '2015-11-07'),
	('Marina', '2015-11-08'),
	('Vasilisa', '2015-11-09'),
	('Miranda', '2015-11-10'),
	('Brotislav', '2015-11-11');


SELECT COUNT(birthday), DAYNAME(DATE_FORMAT(birthday, '2021-%m-%d'))
FROM users
GROUP BY DAYNAME(DATE_FORMAT(birthday, '2021-%m-%d'))