DROP DATABASE IF EXISTS l52;
CREATE DATABASE l52;
USE l52;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` SERIAL PRIMARY KEY,
  `name` VARCHAR(255),
  `created_at` VARCHAR(255),
  `updated_at` VARCHAR(255)
);

INSERT INTO users (name, created_at, updated_at)
VALUES
	('Ivan', '20.10.2017 8:10', '21.10.2017 10:30'),
	('Maria', '23.11.2017 8:10', '25.11.2017 21:30'),
	('Vasiliy', '26.12.2017 8:10', '26.10.2018 20:30'),
	('Miron', '22.01.2017 8:10', '21.11.2018 18:30'),
	('Bogdan', '28.09.2017 8:10', '26.11.2018 10:30');

-- №2
UPDATE users
	SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'),
		updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');

ALTER TABLE users
  MODIFY created_at DATETIME,
  MODIFY updated_at DATETIME;
  
 SELECT * FROM users