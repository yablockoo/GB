SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER //

-- 1
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TINYTEXT 
NOT DETERMINISTIC
BEGIN
	DECLARE h INT;
	SET h = HOUR(NOW());
	CASE 
		WHEN h BETWEEN 6 AND 11 THEN 
			RETURN "Доброе утро!";
		WHEN h BETWEEN 12 AND 17 THEN 
			RETURN "Добрый день!";
		WHEN h BETWEEN 18 AND 23 THEN 
			RETURN "Добрый вечер!";
		WHEN h BETWEEN 24 AND 5 THEN 
			RETURN "Доброй ночи!";
	END CASE;
END;//
SELECT now(), hello ()//

-- 2
DROP TRIGGER IF EXISTS validation//
CREATE TRIGGER validation BEFORE INSERT ON products
FOR EACH ROW BEGIN 
	IF NEW.name IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Name and description are NULL.';
	END IF;
END//

