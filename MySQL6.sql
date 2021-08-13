USE vk;

-- 1
SELECT from_user_id, 
	CONCAT(users.firstname, ' ', users.lastname) AS name, 
	COUNT(*) AS 'message count'
FROM messages
JOIN users ON users.id = masseges.from_user_id
WHERE to_user_id = 1
GROUP BY by from_user_id
ORDER BY count(*) DESC
LIMIT 1;

-- 2
SELECT COUNT(*)
FROM likes
WHERE media_id IN (
	SELECT id 
	FROM media 
	WHERE user_id IN (
		SELECT user_id
		FROM profiles
		WHERE  YEAR(CURDATE()) - YEAR(birthday) < 10
	)
);

-- 3
SELECT  gender, COUNT(*)
FROM likes
JOIN profiles on likes.user_id = profiles.user_id 
GROUPO BY gender;
