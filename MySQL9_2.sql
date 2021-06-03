-- 1
CREATE USER 'shop_read'@'localhost';
GRANT SELECT, SHOW VIEW ON shop.* TO 'shop_read'@'localhost'identified BY '';

CREATE USER 'shop'@'localhost';
GRANT ALL ON shop.* TO 'shop'@'localhost' identified BY '';