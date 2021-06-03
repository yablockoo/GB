USE shop;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
	tablename VARCHAR(255),
	table_id INT,
	name VARCHAR(255),
	created_at DATETIME DEFAULT NOW()
) ENGINE=Archive;

DELIMITER //
CREATE TRIGGER insert_user_log AFTER INSERT ON users
FOR EACH ROW BEGIN 
	INSERT INTO logs (tablename, table_id, name) VALUES('users', NEW.id, NEW.name);
END//

