/* База данных по игре pokemon Go. Данная база состоит из таблиц пользователей, стран, профилей игроков, покедекса, покемонов, дружеских запросов,
 * инвентарей, типов стихий, быстрых атак, спец. атак, спец таблицы коэффициентов покемонов. 
 * Скрипты заполняют данные в таблицы.
 * Вспомогательные триггеры просчитывают значения очков здоровья и силы по сложным формулам.
 * С помощью выборок можно просмотреть список сияющих покемонов, покемонов игрока, списка друзей игрока.
 * А с помощью представлений можно увидеть что лежит в сумках игроков, и просмотреть подробные карточки определенного игрока.
 */

DROP DATABASE IF EXISTS pokemongo;
CREATE DATABASE pokemongo;
USE pokemongo;

-- Создание таблиц
-- пользователи
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    nickname VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
 	password_hash VARCHAR(100) NOT NULL,
	
    INDEX users_nickname_idx(nickname)
) COMMENT 'юзеры';

-- страны
DROP TABLE IF EXISTS countries;
CREATE TABLE countries (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) NOT NULL
)COMMENT 'страны';


DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
	trainer_code BIGINT UNSIGNED NOT NULL UNIQUE,  -- код тренера для дружбы
    gender ENUM('m', 'f', 'other') NOT NULL,
    birthday DATE NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    country TINYINT UNSIGNED,
    team ENUM('Valor', 'Instinct', 'Mystic', 'None') DEFAULT 'None', -- команда тренера
    
    pos_latitude FLOAT( 10, 6 ) NOT NULL,  -- текущая поз. тренера по широте
    pos_longitude FLOAT( 10, 6 ) NOT NULL,  -- текущая поз. тренера по долготе
    
    total_distance INT UNSIGNED DEFAULT 0, -- пройденные км
    total_exp INT UNSIGNED DEFAULT 0,  -- количество опыта
    lvl TINYINT UNSIGNED DEFAULT 1, -- уровень тренера
    stardust INT UNSIGNED DEFAULT 0,  -- количество звездной пыли для улучшения покемонов

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (country) REFERENCES countries(id)
)COMMENT 'профили';


DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    status ENUM('requested', 'approved', 'declined', 'unfriended'),
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id),
    CHECK (initiator_user_id <> target_user_id)
)COMMENT 'запросы в друзья';

-- типы стихий атак и покемонов
DROP TABLE IF EXISTS types;
CREATE TABLE types (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(20) UNIQUE NOT NULL
)COMMENT 'типы покемонов';

-- быстрые атаки
DROP TABLE IF EXISTS fast_moves;
CREATE TABLE fast_moves (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(20) NOT NULL,
	damage TINYINT  UNSIGNED NOT NULL, -- урон
	`type` TINYINT UNSIGNED,  -- тип атаки

	FOREIGN KEY (`type`) REFERENCES types(id)
) COMMENT 'быстрые атаки';

-- спец. атаки
DROP TABLE IF EXISTS charge_moves;
CREATE TABLE charge_moves (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(20) NOT NULL,
	damage TINYINT UNSIGNED NOT NULL,
	`type` TINYINT UNSIGNED,
	
	FOREIGN KEY (`type`) REFERENCES types(id)
) COMMENT 'специальные атаки';


-- Покедекс - справочник покемонов, аналог пользователей
DROP TABLE IF EXISTS pokedex;  
CREATE TABLE pokedex (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- номер в покедексе 
    name VARCHAR(50) NOT NULL,
    description TEXT,
    
    based_attack TINYINT UNSIGNED NOT NULL,  -- базовый показатель атаки
    based_defense TINYINT UNSIGNED NOT NULL, -- базовый показатель защиты
    based_stamina TINYINT UNSIGNED NOT NULL, -- базовый показатель здоровья
    
    first_type TINYINT UNSIGNED NOT NULL,  -- 1 стихия покемона
    second_type TINYINT UNSIGNED, -- 2 стихия  покемона
    
    evolve_to TINYINT UNSIGNED, -- № эволюции покемона приналичии
    evolve_cost INT UNSIGNED, -- стоимость в конфетах эфолюции при наличии
	
    FOREIGN KEY (first_type) REFERENCES types(id),
    FOREIGN KEY (second_type) REFERENCES types(id)
) COMMENT 'покедекс';

-- таблица коэффициентов для расчета боевой силы и очков здоровья покемона
DROP TABLE IF EXISTS cpm;
CREATE TABLE cpm(
	cp_lvl FLOAT( 3, 1 ) UNSIGNED NOT NULL PRIMARY KEY,
	cp_mult FLOAT( 10, 9 ) UNSIGNED NOT NULL
)COMMENT 'коэффициенты для расчеты боевой силы покемона';

-- pokemonss - аналог профилей пользователей
DROP TABLE IF EXISTS pokemons;
CREATE TABLE pokemons (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	pokedex_id INT UNSIGNED NOT NULL,  -- № в покедексе
	master_id BIGINT UNSIGNED NOT NULL,  -- хозяин покемона
	name VARCHAR(50) NOT NULL,  --  кличка покемона
	
	lvl FLOAT( 3, 1 ) UNSIGNED NOT NULL,
	attack_iv TINYINT UNSIGNED NOT NULL,  -- личный показатель атаки
	defense_iv TINYINT UNSIGNED NOT NULL,  -- личный показатель защиты
	stamina_iv TINYINT UNSIGNED NOT NULL,  -- личный показатель здоровья
	hp INT UNSIGNED NOT NULL,  -- очки здоровья
	combat_power INT UNSIGNED NOT NULL,  -- очки силы
	cathed_at DATETIME DEFAULT NOW(),  -- дата поимки
		
	fast_move TINYINT UNSIGNED NOT NULL,  -- № быстрой атаки
	charge_move TINYINT UNSIGNED NOT NULL, -- № спец. атаки
	
	weight INT UNSIGNED NOT NULL,
	height INT UNSIGNED NOT NULL,
	
	shiny BOOL DEFAULT 0,  -- сияющий, аналог альбиноса, редкая спец. расцветка
	lucky BOOL DEFAULT 0,  -- удачливый, прощ прокачивается, получается при трейде
	shadow BOOL DEFAULT 0,  -- теневой, проклятый покемона, хп-, атк +
	
	FOREIGN KEY (fast_move) REFERENCES fast_moves(id),
	FOREIGN KEY (charge_move) REFERENCES charge_moves(id),
	FOREIGN KEY (pokedex_id) REFERENCES pokedex(id),
	FOREIGN KEY (master_id) REFERENCES users(id)
)COMMENT 'покемоны';

-- Конфеты для прокачки
DROP TABLE IF EXISTS candies;
CREATE TABLE candies(
	user_id BIGINT UNSIGNED NOT NULL,  -- № тренера
	pokedex_id INT UNSIGNED NOT NULL, -- № покемона в покедексе
	candies INT UNSIGNED NOT NULL DEFAULT 0,  -- количество конфет
	
	PRIMARY KEY (user_id, pokedex_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (pokedex_id) REFERENCES pokedex(id)
)COMMENT 'расходный материал для улучшений покемона';

-- инвентарь игрока
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory(
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	potion INT UNSIGNED NOT NULL DEFAULT 0,  -- "лечилки"
	revive INT UNSIGNED NOT NULL DEFAULT 0,  -- "воскрешалки"
	lucky_egg INT UNSIGNED NOT NULL DEFAULT 0, -- усилитель получаемого опыта на час
	raid_pass INT UNSIGNED NOT NULL DEFAULT 0,  -- пропуск на спец. битвы
	pokeball INT UNSIGNED NOT NULL DEFAULT 0,  -- покеболы
	berry INT UNSIGNED NOT NULL DEFAULT 0,  -- ягоды для кормления
	
	FOREIGN KEY (user_id) REFERENCES users(id)
)COMMENT 'инвентарь';

-- покестопы для получения вещей
DROP TABLE IF EXISTS pokestops;
CREATE TABLE pokestops(
	id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	pos_latitude FLOAT( 10, 6 ) NOT NULL,  -- положение по широте
    pos_longitude FLOAT( 10, 6 ) NOT NULL,  -- положение по долготе
    created_at DATETIME DEFAULT NOW() 
) COMMENT 'покестопы';


-- Заполение таблиц
-- http://filldb.info/dummy/
INSERT INTO `users` VALUES 
	(1,'odit','rossie.gusikowski@example.com','ec60e52c07f23a2427ac3c73ba3caebfbc9de71a'),
	(2,'pariatur','rheidenreich@example.com','49d3cad447f227f2eaf7a5e7894aeaa5b66edca2'),
	(3,'enim','king.bernier@example.net','cb7b472603c269219ab51e7ffa03befcfe45c213'),
	(4,'dolores','marcus00@example.net','fce3b8d7c115a6cde20af33f7ab40b4305ed9588'),
	(5,'magni','benton33@example.net','175b14525865598a309a6593eb1598b49f18fe1b'),
	(6,'delectus','bstark@example.com','9a3399c522e2f64d7687c8f19a17dc193a6a3424'),
	(7,'magnam','o\'connell.jerry@example.org','619f4497a9a141097ea1a0bb968e6aa7085173f8'),
	(8,'est','amely.hayes@example.net','af924ecc749f8388855c3a4a6b84f50842749b84'),
	(9,'eveniet','eloise.emmerich@example.net','ad3dc3a0a736cfd8bf5b877a5dd8b5f54aed8980'),
	(10,'et','bailey33@example.net','893636aa7e2ca94f2513179d59d5ce2315d710b4'),
	(11,'dolorem','jessica.rau@example.net','0611b0484bf34eea5eaca2d254bc94d5d5582e22'),
	(12,'rerum','demond49@example.net','f42e6d00c496f4d6ead5f4cae405ffa6b25adc1e'),
	(13,'dolorum','ward.javonte@example.net','d85623dffd0ac7402a98fabb5fbd6d4bdc5dd24a'),
	(14,'sunt','pacocha.marlene@example.org','54704e8f8226e40eb70371f67c40ea1c25efce9b'),
	(15,'blanditiis','davis.jayne@example.net','874990c1bb82276b8aff7d2969f6eb0207fb2700'),
	(16,'vel','grayson41@example.com','5d7a5e580a0fa9e558d60b737bf98ecbf155873c'),
	(17,'consequatur','hand.laverne@example.org','8939aa66f5702f0071ae126be6c40d02fcc2a5f2'),
	(18,'ullam','fahey.brad@example.net','88b041ad03367637949c352ca9d888a828be0435'),
	(19,'commodi','kendall57@example.net','e1e60ba020d05b07e3fe31778daa728ccccbbe56'),
	(20,'sapiente','o\'hara.samanta@example.net','97d201eca731e60a0d3534171b677e60bd38461f');

-- https://www.html-code-generator.com/mysql/country-name-table
INSERT INTO `countries` (`name`, `id`) VALUES ('Afghanistan',1), ('Aland Islands',2), ('Albania',3), ('Algeria',4), ('American Samoa',5), ('Andorra',6), ('Angola',7), ('Anguilla',8), ('Antarctica',9), ('Antigua and Barbuda',10), ('Argentina',11), ('Armenia',12), ('Aruba',13), ('Australia',14), ('Austria',15), ('Azerbaijan',16), ('Bahamas',17), ('Bahrain',18), ('Bangladesh',19), ('Barbados',20), ('Belarus',21), ('Belgium',22), ('Belize',23), ('Benin',24), ('Bermuda',25), ('Bhutan',26), ('Bolivia',27), ('Bonaire, Sint Eustatius and Saba',28), ('Bosnia and Herzegovina',29), ('Botswana',30), ('Bouvet Island',31), ('Brazil',32), ('British Indian Ocean Territory',33), ('Brunei Darussalam',34), ('Bulgaria',35), ('Burkina Faso',36), ('Burundi',37), ('Cambodia',38), ('Cameroon',39), ('Canada',40), ('Cape Verde',41), ('Cayman Islands',42), ('Central African Republic',43), ('Chad',44), ('Chile',45), ('China',46), ('Christmas Island',47), ('Cocos (Keeling) Islands',48), ('Colombia',49), ('Comoros',50), ('Congo',51), ('Congo, Democratic Republic of the Congo',52), ('Cook Islands',53), ('Costa Rica',54), ('Cote D\'Ivoire',55), ('Croatia',56), ('Cuba',57), ('Curacao',58), ('Cyprus',59), ('Czech Republic',60), ('Denmark',61), ('Djibouti',62), ('Dominica',63), ('Dominican Republic',64), ('Ecuador',65), ('Egypt',66), ('El Salvador',67), ('Equatorial Guinea',68), ('Eritrea',69), ('Estonia',70), ('Ethiopia',71), ('Falkland Islands (Malvinas)',72), ('Faroe Islands',73), ('Fiji',74), ('Finland',75), ('France',76), ('French Guiana',77), ('French Polynesia',78), ('French Southern Territories',79), ('Gabon',80), ('Gambia',81), ('Georgia',82), ('Germany',83), ('Ghana',84), ('Gibraltar',85), ('Greece',86), ('Greenland',87), ('Grenada',88), ('Guadeloupe',89), ('Guam',90), ('Guatemala',91), ('Guernsey',92), ('Guinea',93), ('Guinea-Bissau',94), ('Guyana',95), ('Haiti',96), ('Heard Island and Mcdonald Islands',97), ('Holy See (Vatican City State)',98), ('Honduras',99), ('Hong Kong',100), ('Hungary',101), ('Iceland',102), ('India',103), ('Indonesia',104), ('Iran, Islamic Republic of',105), ('Iraq',106), ('Ireland',107), ('Isle of Man',108), ('Israel',109), ('Italy',110), ('Jamaica',111), ('Japan',112), ('Jersey',113), ('Jordan',114), ('Kazakhstan',115), ('Kenya',116), ('Kiribati',117), ('Korea, Democratic People\'s Republic of',118), ('Korea, Republic of',119), ('Kosovo',120), ('Kuwait',121), ('Kyrgyzstan',122), ('Lao People\'s Democratic Republic',123), ('Latvia',124), ('Lebanon',125), ('Lesotho',126), ('Liberia',127), ('Libyan Arab Jamahiriya',128), ('Liechtenstein',129), ('Lithuania',130), ('Luxembourg',131), ('Macao',132), ('Macedonia, the Former Yugoslav Republic of',133), ('Madagascar',134), ('Malawi',135), ('Malaysia',136), ('Maldives',137), ('Mali',138), ('Malta',139), ('Marshall Islands',140), ('Martinique',141), ('Mauritania',142), ('Mauritius',143), ('Mayotte',144), ('Mexico',145), ('Micronesia, Federated States of',146), ('Moldova, Republic of',147), ('Monaco',148), ('Mongolia',149), ('Montenegro',150), ('Montserrat',151), ('Morocco',152), ('Mozambique',153), ('Myanmar',154), ('Namibia',155), ('Nauru',156), ('Nepal',157), ('Netherlands',158), ('Netherlands Antilles',159), ('New Caledonia',160), ('New Zealand',161), ('Nicaragua',162), ('Niger',163), ('Nigeria',164), ('Niue',165), ('Norfolk Island',166), ('Northern Mariana Islands',167), ('Norway',168), ('Oman',169), ('Pakistan',170), ('Palau',171), ('Palestinian Territory, Occupied',172), ('Panama',173), ('Papua New Guinea',174), ('Paraguay',175), ('Peru',176), ('Philippines',177), ('Pitcairn',178), ('Poland',179), ('Portugal',180), ('Puerto Rico',181), ('Qatar',182), ('Reunion',183), ('Romania',184), ('Russian Federation',185), ('Rwanda',186), ('Saint Barthelemy',187), ('Saint Helena',188), ('Saint Kitts and Nevis',189), ('Saint Lucia',190), ('Saint Martin',191), ('Saint Pierre and Miquelon',192), ('Saint Vincent and the Grenadines',193), ('Samoa',194), ('San Marino',195), ('Sao Tome and Principe',196), ('Saudi Arabia',197), ('Senegal',198), ('Serbia',199), ('Serbia and Montenegro',200), ('Seychelles',201), ('Sierra Leone',202), ('Singapore',203), ('Sint Maarten',204), ('Slovakia',205), ('Slovenia',206), ('Solomon Islands',207), ('Somalia',208), ('South Africa',209), ('South Georgia and the South Sandwich Islands',210), ('South Sudan',211), ('Spain',212), ('Sri Lanka',213), ('Sudan',214), ('Suriname',215), ('Svalbard and Jan Mayen',216), ('Swaziland',217), ('Sweden',218), ('Switzerland',219), ('Syrian Arab Republic',220), ('Taiwan, Province of China',221), ('Tajikistan',222), ('Tanzania, United Republic of',223), ('Thailand',224), ('Timor-Leste',225), ('Togo',226), ('Tokelau',227), ('Tonga',228), ('Trinidad and Tobago',229), ('Tunisia',230), ('Turkey',231), ('Turkmenistan',232), ('Turks and Caicos Islands',233), ('Tuvalu',234), ('Uganda',235), ('Ukraine',236), ('United Arab Emirates',237), ('United Kingdom',238), ('United States',239), ('United States Minor Outlying Islands',240), ('Uruguay',241), ('Uzbekistan',242), ('Vanuatu',243), ('Venezuela',244), ('Viet Nam',245), ('Virgin Islands, British',246), ('Virgin Islands, U.s.',247), ('Wallis and Futuna',248), ('Western Sahara',249), ('Yemen',250), ('Zambia',251), ('Zimbabwe',252);


INSERT INTO `profiles` VALUES 
	(1,657948163286, 'other','2003-12-06','1996-11-19 11:45:27',8,'None',89.780594,75.100082,4064,6536,4,7934),
	(2,246985376985,'m','1990-11-03','2008-02-25 16:01:36',1,'Instinct',9.633013,49.422028,5716,16932094,39,474622), 
	(3,857785990647,'other','2004-01-07','2001-09-06 07:39:22',19,'Instinct',39.607849,-164.708801,8285,10293414,37,565197),
	(4,343082251632,'f','2017-10-01','1975-07-10 06:31:16',12,'None',20.002436,113.820297,2396,11256,5,934396),
	(5,686351108644,'m','1982-05-24','1971-05-30 01:58:20',5,'Instinct',89.380829,61.759579,7024,7530512,37,79410),
	(6,889377231989,'f','2021-02-25','1982-10-08 02:50:23',1,'Instinct',61.658993,-7.392141,4793,3561043,33,472317),
	(7,244137734081,'f','1983-04-11','2006-10-17 06:41:01',8,'None',-60.814384,42.584755,9564,250,1,201095),
	(8,830331234866,'other','1985-07-28','2015-09-09 03:02:11',20,'Instinct',-77.315224,-45.365234,7993,3981348,34,613818),
	(9,346578255016,'other','1981-11-12','1975-09-30 11:45:59',2,'Mystic',33.476318,-109.918457,2850,167510,18,409420),
	(10,504412925802,'f','2001-06-11','1990-12-25 13:25:25',4,'Mystic',86.843414,88.209740,4250,790410,25,340396),
	(11,890962384827,'m','1981-02-27','1979-03-20 23:48:43',6,'Valor',-32.196003,152.079468,4589,9663181,38,264632),
	(12,494061843259,'f','1985-08-22','2020-12-26 05:34:39',6,'None',11.415875,13.817608,1234,6196,5,663215),
	(13,370043254224,'other','1988-11-10','1992-02-09 20:39:17',12,'Valor',-83.432640,26.323265,9514,18284665,39,954338),
	(14,388031639019,'f','1993-04-10','2020-03-05 21:22:31',4,'Valor',56.267445,5.919771,9110,20000000,40,336767),
	(15,116457089874,'f','1974-05-14','1996-07-23 07:41:41',12,'Mystic',55.004608,149.374268,1883,1822430,29,723011),
	(16,417066214652,'f','2020-07-16','2007-08-05 18:03:44',4,'Instinct',58.376915,170.962296,1873,14824454,39,868912),
	(17,362516297632,'f','2019-06-26','1991-11-06 05:48:18',1,'Mystic',-20.649855,82.535088,6020,3970220,34,438603),
	(18,841911124531,'other','1980-11-14','1991-09-24 20:25:38',12,'Valor',-88.625458,66.336823,8319,132999,16,580888),
	(19,683815151266,'f','1982-01-04','1983-10-14 21:33:58',9,'None',19.444410,85.808777,9700,15079,16,385923),
	(20,104579635644, 'other','2019-04-10','2019-08-12 08:44:04',2,'Mystic',28.448351,-94.991203,1864,6923545,35,823702);

-- http://filldb.info/dummy/
INSERT INTO `friend_requests` VALUES (14,7,'declined','2001-10-04 22:20:29','1988-07-27 19:04:13'),(19,16,'requested','1999-07-16 22:37:38','1987-09-13 17:15:03'),(6,1,'requested','1984-10-13 10:42:11','2005-07-21 17:34:38'),(12,19,'unfriended','2010-04-25 03:23:55','2018-04-23 21:41:42'),(18,19,'approved','1978-03-10 20:05:01','1995-06-08 01:15:24'),(5,4,'requested','2015-03-15 20:35:07','2008-09-10 21:53:28'),(8,13,'approved','1989-12-21 07:48:31','1976-12-26 19:16:23'),(2,1,'requested','2012-06-08 19:37:11','2003-11-27 10:17:46'),(8,6,'unfriended','1978-07-11 20:31:52','2014-08-15 08:43:00'),(17,16,'unfriended','1975-12-19 07:20:50','1978-01-02 04:18:02'),(12,16,'requested','1980-12-01 20:14:49','2007-07-19 01:39:54'),(3,8,'declined','2001-06-14 00:56:03','1997-06-18 03:04:51'),(5,3,'requested','1972-07-11 04:21:09','2000-03-20 23:05:50'),(9,1,'declined','2015-11-16 12:09:19','2009-10-01 18:15:10'),(20,3,'unfriended','2018-03-24 04:31:25','1985-07-26 21:10:05'),(13,6,'unfriended','1977-01-18 02:39:09','1976-03-08 00:07:11'),(8,20,'unfriended','1988-07-11 23:31:09','1988-01-14 02:28:42'),(7,19,'requested','1986-02-19 20:17:04','1985-11-14 03:35:45'),(8,4,'approved','1979-01-15 15:22:11','2019-08-07 04:02:04'),(4,12,'approved','2011-11-20 23:20:38','1982-05-30 16:04:43'),(14,6,'declined','1999-10-04 06:58:22','1991-07-19 21:01:28'),(19,10,'unfriended','2012-04-17 03:52:23','2016-12-18 13:27:46'),(15,16,'unfriended','1975-06-28 14:57:42','2020-05-04 04:35:38'),(17,5,'requested','2018-04-15 18:51:14','2015-01-10 07:06:48'),(1,3,'unfriended','2009-02-06 17:32:25','2021-02-18 21:41:10'),(15,8,'requested','1990-11-09 18:47:11','1977-08-04 06:57:32'),(19,15,'approved','1970-10-25 09:08:46','1999-06-24 13:08:17'),(15,7,'unfriended','2011-06-29 20:29:44','1972-11-29 09:15:15'),(17,15,'unfriended','1970-12-10 09:46:28','1994-03-05 10:14:22'),(10,3,'declined','2006-08-18 13:40:06','1982-11-06 00:20:32'),(15,10,'requested','1970-08-06 11:11:19','2011-11-23 16:18:27'),(18,17,'declined','1987-01-27 09:55:39','2019-07-13 19:56:18'),(7,1,'approved','1975-11-26 01:33:50','1985-03-03 12:38:51'),(18,6,'approved','2019-05-27 07:36:57','1981-05-02 05:13:38'),(6,5,'unfriended','1979-10-27 11:18:39','1982-05-15 09:23:46'),(5,7,'declined','2016-10-12 11:48:58','1988-09-28 22:39:28'),(13,4,'unfriended','1975-06-20 15:01:20','1970-03-30 20:38:52'),(19,8,'approved','1984-07-24 00:35:08','1998-05-15 17:09:28'),(6,9,'declined','2017-07-06 15:32:51','2002-03-18 14:59:53'),(18,11,'approved','2001-09-09 19:53:09','1985-02-23 09:38:54'),(18,16,'approved','2001-08-21 03:17:31','2017-02-12 23:31:32'),(8,3,'requested','2017-08-30 02:33:08','1995-07-26 19:34:39'),(9,3,'requested','2016-04-15 23:14:31','2012-12-17 22:08:47'),(16,4,'unfriended','2016-01-15 12:32:12','1998-08-19 05:59:16'),(17,13,'declined','2007-12-16 00:45:49','2002-07-11 10:10:31'); 

INSERT INTO `types` VALUES
	(1, 'normal'),
	(2, 'fight'),
	(3, 'flying'),
	(4, 'poison'),
	(5, 'ground'),
	(6, 'rock'),
	(7, 'bug'),
	(8, 'ghost'),
	(9, 'steel'),
	(10, 'fire'),
	(11, 'water'),
	(12, 'grass'),
	(13, 'electra'),
	(14, 'psycho'),
	(15, 'ice'),
	(16, 'dragon'),
	(17, 'dark'),
	(18, 'fairy'),
	(0, 'None');

INSERT INTO `fast_moves` VALUES
	(1, 'Struggle', 35, 1),
	(2, 'Rock Smash', 15, 2),
	(3, 'Gust', 25, 3),
	(4, 'Poison Jab', 10, 4),
	(5, 'Mud Slap', 18, 5),
	(6, 'Smack Down', 16, 6),
	(7, 'Struggle Bug', 15, 7),
	(8, 'Hex', 10, 8),
	(9, 'Iron Tail', 15, 9),
	(10, 'Incinerate', 29, 10),
	(11, 'Waterfall', 16, 11),
	(12, 'Razor Leaf', 13, 12),
	(13, 'Volt Switch', 14, 13),
	(14, 'Confusion', 20, 14),
	(15, 'Ice Shard', 12, 15),
	(16, 'Dragon Tail', 15, 16),
	(17, 'Snarl', 12, 17),
	(18, 'Charm', 20, 18);

INSERT INTO `charge_moves` VALUES
	(1, 'Techno Blast', 120, 1),
	(2, 'Aura Sphere', 90, 2),
	(3, 'Brave Bird', 130, 3),
	(4, 'Gunk Shot', 130, 4),
	(5, 'Precipice Blades', 130, 5),
	(6, 'Stone Edge', 100, 6),
	(7, 'Megahorn', 110, 7),
	(8, 'Shadow Ball', 100, 8),
	(9, 'Doom Desire', 70, 9),
	(10, 'Overheat', 160, 10),
	(11, 'Origin Pulse', 130, 11),
	(12, 'Leaf Storm', 130, 12),
	(13, 'Thunder', 100, 13),
	(14, 'Future Sight', 120, 14),
	(15, 'Blizzard', 130, 15),
	(16, 'Draco Meteor', 150, 16),
	(17, 'Payback', 100, 17),
	(18, 'Play Rough', 90, 18);

INSERT INTO `pokedex` VALUES
	(1, 'Bulbasaur',' A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokémon. ', 49, 49, 45, 12, 4, 2, 25),
	(2, 'Ivysaur', 'When the bulb on its back grows large, it appears to lose the ability to stand on its hind legs. ', 62, 63, 60, 12, 4, 3, 100),
	(3, 'Venusaur', 'The plant blooms when it is absorbing solar energy. It stays on the move to seek sunlight.', 82, 83, 80, 12, 4, NULL, NULL ),
	(4, 'Charmander', 'Obviously prefers hot places. When it rains, steam is said to spout from the tip of its tail.', 52, 43, 39, 10, 19, 5, 25),
	(5, 'Charmeleon', 'When it swings its burning tail, it elevates the temperature to unbearably high levels. ', 64, 58, 58, 10, 19, 6, 100),
	(6, 'Charmander', 'Spits fire that is hot enough to melt boulders. Known to cause forest fires unintentionally. ', 84, 78, 78, 10, 3, NULL, NULL ),
	(7, 'Squirtle', 'After birth, its back swells and hardens into a shell. Powerfully sprays foam from its mouth.', 48, 65, 44, 11, 19, 8, 25),
	(8, 'Wartortle', 'Often hides in water to stalk unwary prey. For swimming fast, it moves its ears to maintain balance.', 63, 80, 59, 11, 19, 9, 100),
	(9, 'Blastoise', 'A brutal Pokémon with pressurized water jets on its shell. They are used for high speed tackles. ', 83, 100, 79, 11, 19, NULL, NULL),
	(10, 'Caterpie', 'Its short feet are tipped with suction pads that enable it to tirelessly climb slopes and walls. ', 30, 35, 45, 7, 19, 11, 25),
	(11, 'Metapod', 'This Pokémon is vulnerable to attack while its shell is soft, exposing its weak and tender body. ', 20, 55, 50, 7, 19, 12, 100),
	(12, 'Butterfree', 'In battle, it flaps its wings at high speed to release highly toxic dust into the air. ', 45, 50, 60, 7, 3, NULL, NULL ),
	(13, 'Weedle', 'Often found in forests, eating leaves. It has a sharp venomous stinger on its head.', 35, 30, 40, 7, 4, 14, 25), 
	(14, 'Kakuna', 'Almost incapable of moving, this POKéMON can only harden its shell to protect itself from predators.', 25, 50, 45, 7, 4, 15, 100), 
	(15, 'Beedrill', 'Flies at high speed and attacks using its large venomous stingers on its forelegs and tail.', 40, 45, 90, 7, 4, NULL, NULL), 
	(16, 'Pidgey', 'A common sight in forests and woods. It flaps its wings at ground level to kick up blinding sand.', 45, 40, 40, 1, 3, 17, 25), 
	(17, 'Pidgeotto', 'Very protective of its sprawling territorial area, this POKéMON will fiercely peck at any intruder.', 60, 55, 63, 1, 3, 18, 100), 
	(18, 'Pidgeot', 'When hunting, it skims the surface of water at high speed to pick off unwary prey such as MAGIKARP.', 80, 75, 83, 1, 3, NULL, NULL), 
	(19, 'Rattata', 'Bites anything when it attacks. Small and very quick, it is a common sight in many places.', 56, 35, 30, 1, 19, 20, 50), 
	(20, 'Raticate', 'It uses its whiskers to maintain its balance. It apparently slows down if they are cut off.',  81, 60, 55, 1, 19, NULL, NULL), 
	(21, 'Spearow', 'Eats bugs in grassy areas. It has to flap its short wings at high speed to stay airborne.', 60, 30, 40, 1, 3, 22, 50), 
	(22, 'Fearow', 'With its huge and magnificent wings, it can keep aloft without ever having to land for rest.', 90, 65, 65, 1, 3, NULL, NULL), 
	(23, 'Ekans', 'Moves silently and stealthily. Eats the eggs of birds, such as PIDGEY and SPEAROW, whole.', 60, 44, 35, 4, 19, 24, 50), 
	(24, 'Abrok', 'It is rumored that the ferocious warning markings on its belly differ from area to area.', 95, 69, 60, 4, 19, NULL, NULL), 
	(25, 'Pikachu', 'When several of these POKéMON gather, their electricity could build and cause lightning storms.', 55, 40, 35, 13, 19, 26, 50), 
	(26, 'Raichu', 'Its long tail serves as a ground to protect itself from its own high voltage power.', 90, 55, 60, 13, 19, NULL, NULL), 
	(27, 'Sandshrew', 'Burrows deep underground in arid locations far from water. It only emerges to hunt for food.', 75, 85, 50, 5, 19, 28, 50), 
	(28, 'Sandslash', 'Curls up into a spiny ball when threatened. It can roll while curled up to attack or escape.', 100, 110, 75, 5, 19, NULL, NULL), 
	(29, 'Nidoran_f', 'Although small, its venomous barbs render this POKéMON dangerous. The female has smaller horns.', 47, 52, 55, 4, 19, 30, 25), 
	(30, 'Nidorina', 'The female’s horn develops slowly. Prefers physical attacks such as clawing and biting.', 62, 67, 70, 4, 19, 31, 100), 
	(31, 'Nidoqueen', 'Its hard scales provide strong protection. It uses its hefty bulk to execute powerful moves.', 92, 87, 90, 4, 5, NULL, NULL), 
	(32, 'Nidoran_m', 'Stiffens its ears to sense danger. The larger its horns, the more powerful its secreted venom.', 57, 40, 46, 4, 19, 33, 25), 
	(33, 'Nidorino', 'An aggressive POKéMON that is quick to attack. The horn on its head secretes a powerful venom.', 72, 57, 61, 4, 19, 34, 100), 
	(34, 'Nidoking', 'It uses its powerful tail in battle to smash, constrict, then break the prey’s bones.', 102, 77, 81, 4, 5, NULL, NULL), 
	(35, 'Clefairy', 'Its magical and cute appeal has many admirers. It is rare and found only in certain areas.', 45, 48, 70, 18, 19, 36, 50), 
	(36, 'Clefable', 'A timid fairy POKéMON that is rarely seen. It will run and hide the moment it senses people.', 70, 73, 95, 18, 19, NULL, NULL), 
	(37, 'Vulpix', 'At the time of birth, it has just one tail. The tail splits from its tip as it grows older.', 41, 40, 38, 10, 19, 38, 50), 
	(38, 'Ninetales', 'Very smart and very vengeful. Grabbing one of its many tails could result in a 1000-year curse.', 76, 75, 73, 1, 19, NULL, NULL),	
	(39, 'Jigglypuff', 'When its huge eyes light up, it sings a mysteriously soothing melody that lulls its enemies to sleep.', 45, 20, 115, 1, 18, 40, 50), 
	(40, 'Wigglytuff', 'e 	The body is soft and rubbery. When angered, it will suck in air and inflate itself to an enormous size.', 70, 45, 140, 1, 18, NULL, NULL),
	(41, 'Zubat', 'Forms colonies in perpetually dark places. Uses ultrasonic waves to identify and approach targets.', 45, 35, 40, 4, 3, 42, 25),
	(42, 'Golbat', 'Once it strikes, it will not stop draining energy from the victim even if it gets too heavy to fly.', 80, 70, 75, 4, 3, NULL, NULL), 
	(43, 'Oddish', 'During the day, it keeps its face buried in the ground. At night, it wanders around sowing its seeds.', 50, 55, 45, 12, 4, 44, 25), 
	(44, 'Gloom', 'The fluid that oozes from its mouth isn’t drool. It is a nectar that is used to attract prey.', 65, 70, 60, 12, 4, 45, 100), 
	(45, 'Vileplume', ' 	The larger its petals, the more toxic pollen it contains. Its big head is heavy and hard to hold up.', 80, 85, 75, 12, 4, NULL, NULL), 
	(46, 'Paras', 'Burrows to suck tree roots. The mushrooms on its back grow by drawing nutrients from the bug host.', 70, 55, 35, 7, 12, 47, 50), 
	(47, 'Parasect', 'A host-parasite pair in which the parasite mushroom has taken over the host bug. Prefers damp places.', 95, 80, 60, 7, 12, NULL, NULL), 
	(48, 'Venonat', 'Lives in the shadows of tall trees where it eats insects. It is attracted by light at night.', 55, 50, 60, 7, 4, 49, 50), 
	(49, 'Venomoth', 'The dust-like scales covering its wings are color coded to indicate the kinds of poison it has.', 65, 60, 70, 7, 4, NULL, NULL), 
	(50, 'Diglett', 'Lives about one yard underground where it feeds on plant roots. It sometimes appears above ground.', 55, 25, 10, 5, 19, 51, 50), 
	(51, 'Digtrio', 'A team of DIGLETT triplets. It triggers huge earthquakes by burrowing 60 miles underground.', 100, 50, 35, 5, 19, NULL, NULL), 
	(52, 'Meowth', 'Adores circular objects. Wanders the streets on a nightly basis to look for dropped loose change.', 45, 35, 40, 1, 19, 53, 50), 
	(53, 'Persian', 'Although its fur has many admirers, it is tough to raise as a pet because of its fickle meanness.', 70, 60, 65, 1, 19, NULL, NULL), 
	(54, 'Psyduck', 'While lulling its enemies with its vacant look, this wily POKéMON will use psychokinetic powers.', 52, 48, 50, 11, 19, 55, 50), 
	(55, 'Golduck', 'Often seen swimming elegantly by lake shores. It is often mistaken for the Japanese monster, Kappa.', 82, 78, 80, 11, 19, NULL, NULL), 
	(56, 'Mankey', 'Extremely quick to anger. It could be docile one moment then thrashing away the next instant.', 80, 35, 40, 2, 19, 57, 50), 
	(57, 'Primeape', 'Always furious and tenacious to boot. It will not abandon chasing its quarry until it is caught.', 105, 60, 65, 2, 19, NULL, NULL), 
	(58, 'Growlithe', 'Very protective of its territory. It will bark and bite to repel intruders from its space.', 70, 45, 55, 10, 19, 59, 50), 
	(59, 'Arcanine', 'A POKéMON that has been admired since the past for its beauty. It runs agilely as if on wings.', 110, 80, 90, 10, 19, NULL, NULL), 
	(60, 'Poliwag', 'Its newly grown legs prevent it from running. It appears to prefer swimming than trying to stand.', 50, 40, 40, 11, 19, 61, 25), 
	(61, 'Poliwhirl', 'Capable of living in or out of water. When out of water, it sweats to keep its body slimy.', 65, 65, 65, 11, 19, 62, 100), 
	(62, 'Poliwrath', 'An adept swimmer at both the front crawl and breast stroke. Easily overtakes the best human swimmers.', 95, 95, 90, 11, 2, NULL, NULL), 
	(63, 'Abra', 'Using its ability to read minds, it will identify impending danger and TELEPORT to safety.', 20, 15, 25, 14, 19, 64, 25), 
	(64, 'Kadabra', 'It emits special alpha waves from its body that induce headaches just by being close by.', 35, 30, 40, 14, 19, 65, 100), 
	(65, 'Alakazam', 'Its brain can outperform a supercomputer. Its intelligence quotient is said to be 5,000.', 50, 45, 55, 14, 19, NULL, NULL), 
	(66, 'Machop', 'Loves to build its muscles. It trains in all styles of martial arts to become even stronger.', 80, 50, 70, 2, 19, 67, 25), 
	(67, 'Machoke', 'Its muscular body is so powerful, it must wear a power save belt to be able to regulate its motions.', 100, 70, 80, 2, 19, 68, 100), 
	(68, 'Machamp', 'Using its heavy muscles, it throws powerful punches that can send the victim clear over the horizon.', 130, 80, 90, 2, 19, NULL, NULL), 
	(69, 'Bellsprout', 'A carnivorous POKéMON that traps and eats bugs. It uses its root feet to soak up needed moisture.', 75, 35, 50, 12, 4, 70, 25), 
	(70, 'Weepinbell', 'It spits out POISONPOWDER to immobilize the enemy and then finishes it with a spray of ACID.', 90, 60, 55, 12, 4, 71, 100), 
	(71, 'Victreebel', 'Said to live in huge colonies deep in jungles, although no one has ever returned from there.', 105, 65, 80, 12, 4, NULL, NULL), 
	(72, 'Tentacool', 'Drifts in shallow seas. Anglers who hook them by accident are often punished by its stinging acid.', 40, 35, 40, 11, 4, 73, 50), 
	(73, 'Tentacruel', 'The tentacles are normally kept short. On hunts, they are extended to ensnare and immobilize prey.', 70, 65, 80, 11, 4, NULL, NULL), 
	(74, 'Geodude', 'Found in fields and mountains. Mistaking them for boulders, people often step or trip on them.', 80, 100, 40, 6, 5, 75, 25), 
	(75, 'Graveler', 'Rolls down slopes to move. It rolls over any obstacle without slowing or changing its direction.', 95, 115, 55, 6, 5, 76, 100), 
	(76, 'Golem', 'Its boulder-like body is extremely hard. It can easily withstand dynamite blasts without damage.', 120, 130, 80, 6, 5, NULL, NULL), 
	(77, 'Ponyta', 'Its hooves are 10 times harder than diamonds. It can trample anything completely flat in little time.', 85, 55, 50, 10, 19, 78, 50), 
	(78, 'Rapidash', 'Very competitive, this POKéMON will chase anything that moves fast in the hopes of racing it.', 100, 70, 65, 10, 19, NULL, NULL), 
	(79, 'Slowpoke', 'Incredibly slow and dopey. It takes 5 seconds for it to feel pain when under attack.', 65, 65, 90, 11, 14, 80, 50), 
	(80, 'Slowbro', 'The SHELLDER that is latched onto SLOWPOKE’s tail is said to feed on the host’s left over scraps.', 75, 110, 95, 11, 14, NULL, NULL), 
	(81, 'Magnemite', 'Uses anti-gravity to stay suspended. Appears without warning and uses THUNDER WAVE and similar moves.', 35, 70, 25, 13, 9, 82, 50), 
	(82, 'Magnetone', 'Formed by several MAGNEMITEs linked together. They frequently appear when sunspots flare up.', 60, 95, 50, 13, 9, NULL, NULL), 
	(83, 'Farfetch\'d', 'The sprig of green onions it holds is its weapon. It is used much like a metal sword.', 90, 55, 52, 1, 3, NULL, NULL), 
	(84, 'Doduo', 'A bird that makes up for its poor flying with its fast foot speed. Leaves giant footprints.', 85, 45, 35, 1, 3, 85, 50), 
	(85, 'Dodrio', 'Uses its three brains to execute complex plans. While two heads sleep, one head stays awake.', 110, 70, 60, 1, 3, NULL, NULL), 
	(86, 'Seel', 'The protruding horn on its head is very hard. It is used for bashing through thick ice.', 45, 55, 65, 11, 19, 87, 50), 
	(87, 'Dewgong', 'Stores thermal energy in its body. Swims at a steady 8 knots even in intensely cold waters.', 70, 80, 90, 11, 15, NULL, NULL), 
	(88, 'Grimer', 'Appears in filthy areas. Thrives by sucking up polluted sludge that is pumped out of factories.', 80, 50, 80, 4, 19, 89, 50), 
	(89, 'Muk', 'Thickly covered with a filthy, vile sludge. It is so toxic, even its footprints contain poison.',  105, 75, 105, 4, 19, NULL, NULL), 
	(90, 'Shelder', 'Its hard shell repels any kind of attack. It is vulnerable only when its shell is open.', 65, 100, 30, 11, 19, 91, 50), 
	(91, 'Cloyster', 'When attacked, it launches its horns in quick volleys. Its innards have never been seen.', 95, 180, 50, 11, 15, NULL, NULL), 
	(92, 'Gastly', 'Almost invisible, this gaseous POKéMON cloaks the target and puts it to sleep without notice.', 35, 30, 30, 8, 4, 93, 25), 
	(93, 'Haunter', 'Because of its ability to slip through block walls, it is said to be from another dimension.', 50, 45, 45, 8, 4, 94, 100), 
	(94, 'Gengar', 'Under a full moon, this POKéMON likes to mimic the shadows of people and laugh at their fright.', 65, 60, 60, 8, 4, NULL, NULL), 
	(95, 'Onix', 'As it grows, the stone portions of its body harden to become similar to a diamond, but colored black.', 45, 160, 35, 5, 11, NULL, NULL), 
	(96, 'Drowze', 'Puts enemies to sleep then eats their dreams. Occasionally gets sick from eating bad dreams.', 48, 45, 60, 14, 19, 97, 50), 
	(97, 'Hypno', 'When it locks eyes with an enemy, it will use a mix of PSI moves such as HYPNOSIS and CONFUSION.', 73, 70, 85, 14, 19, NULL, NULL), 
	(98, 'Krabby', 'Its pincers are not only powerful weapons, they are used for balance when walking sideways.', 105, 90, 30, 11, 19, 99, 50), 
	(99, 'Kingler', 'The large pincer has 10000 hp of crushing power. However, its huge size makes it unwieldy to use.', 130, 115, 55, 11, 19, NULL, NULL), 
	(100, 'Voltorb', 'Usually found in power plants. Easily mistaken for a POKé BALL, they have zapped many people.', 30, 50, 40, 13, 19, 101, 50), 
	(101, 'Electrode', 'It stores electric energy under very high pressure. It often explodes with little or no provocation.', 50, 70, 60, 13, 19, NULL, NULL), 
	(102, 'Exeggcute', 'Often mistaken for eggs. When disturbed, they quickly gather and attack in swarms.', 40, 80, 60, 12, 14, 103, 50), 
	(103, 'Exeggutor', 'Legend has it that on rare occasions, one of its heads will drop off and continue on as an EXEGGCUTE.', 95, 85, 95, 12, 14, NULL, NULL), 
	(104, 'Cubone', 'Because it never removes its skull helmet, no one has ever seen this POKéMON’s real face.', 50, 95, 50, 5, 19, 105, 50), 
	(105, 'Marowak', 'The bone it holds is its key weapon. It throws the bone skillfully like a boomerang to KO targets.', 80, 110, 60, 5, 19, NULL, NULL),
	(106, 'Hitmonlee', 'When in a hurry, its legs lengthen progressively. It runs smoothly with extra long, loping strides.', 120, 53, 50, 2, 19, NULL, NULL), 
	(107, 'Hitmonchan', 'While apparently doing nothing, it fires punches in lightning fast volleys that are impossible to see.', 105, 70, 50, 2, 19, NULL, NULL), 
	(108, 'Lickitung', 'Its tongue can be extended like a chameleon’s. It leaves a tingling sensation when it licks enemies.', 55, 75, 90, 1, 19, NULL, NULL), 
	(109, 'Koffing', 'Because it stores several kinds of toxic gases in its body, it is prone to exploding without warning.', 65, 95, 40, 4, 19, 110, 50), 
	(110, 'Weezing', 'Where two kinds of poison gases meet, 2 KOFFINGs can fuse into a WEEZING over many years.', 90, 120, 65, 4, 19, NULL, NULL), 
	(111, 'Rhyhorn', 'Its massive bones are 1000 times harder than human bones. It can easily knock a trailer flying.', 85, 95, 80, 5, 6, 112, 50), 
	(112, 'Rhydon', 'Protected by an armor-like hide, it is capable of living in molten lava of 3,600 degrees.',  130, 120, 105, 5, 6, NULL, NULL), 
	(113, 'Chansey', 'A rare and elusive POKéMON that is said to bring happiness to those who manage to get it.', 5, 5, 250, 1, 19, NULL, NULL), 
	(114, 'Tangela', 'The whole body is swathed with wide vines that are similar to seaweed. Its vines shake as it walks.', 55, 115, 65, 12, 19, NULL, NULL), 
	(115, 'Kangaskhan', 'The infant rarely ventures out of its mother’s protective pouch until it is 3 years old.', 95, 80, 105, 1, 19, NULL, NULL), 
	(116, 'Horsea', 'Known to shoot down flying bugs with precision blasts of ink from the surface of the water.', 40, 70, 30, 11, 19, 117, 50), 
	(117, 'Seadra', 'Capable of swimming backwards by rapidly flapping its wing-like pectoral fins and stout tail.', 65, 95, 55, 11, 19, NULL, NULL), 
	(118, 'Goldeen', 'Its tail fin billows like an elegant ballroom dress, giving it the nickname of the Water Queen.', 67, 60, 45, 11, 19, 119, 50), 
	(119, 'Seaking', 'In the autumn spawning season, they can be seen swimming powerfully up rivers and creeks.', 92, 65, 80, 11, 19, NULL, NULL), 
	(120, 'Staryu', 'An enigmatic POKéMON that can effortlessly regenerate any appendage it loses in battle.', 45, 55, 30, 11, 19, 121, 50), 
	(121, 'Starme', 'Its central core glows with the seven colors of the rainbow. Some people value the core as a gem.', 75, 85, 60, 11, 14, NULL, NULL), 
	(122, 'Mr.Mime', 'If interrupted while it is miming, it will slap around the offender with its broad hands.', 45, 65, 40, 14, 18, NULL, NULL), 
	(123, 'Scyther', 'With ninja-like agility and speed, it can create the illusion that there is more than one.', 110, 80, 70, 7, 3, NULL, NULL), 
	(124, 'Jynx', 'It seductively wiggles its hips as it walks. It can cause people to dance in unison with it.', 50, 35, 65, 15, 14, NULL, NULL), 
	(125, 'Electabuzz', 'Normally found near power plants, they can wander away and cause major blackouts in cities.', 83, 57, 65, 13, 19, NULL, NULL), 
	(126, 'Magmar', 'Its body always burns with an orange glow that enables it to hide perfectly among flames.', 95, 57, 65, 10, 19, NULL, NULL), 
	(127, 'Pinsir', 'If it fails to crush the victim in its pincers, it will swing it around and toss it hard.', 125, 100, 65, 7, 19, NULL, NULL), 
	(128, 'Tauros', ' When it targets an enemy, it charges furiously while whipping its body with its long tails.', 100, 95, 75, 1, 19, NULL, NULL), 
	(129, 'Magikarp', 'In the distant past, it was somewhat stronger than the horribly weak descendants that exist today.', 10, 55, 20, 11, 19, 130, 400), 
	(130, 'Gyarados', ' 	Rarely seen in the wild. Huge and vicious, it is capable of destroying entire cities in a rage.', 125, 79, 95, 11, 3, NULL, NULL), 
	(131, 'Lapras', 'A POKéMON that has been overhunted almost to extinction. It can ferry people across the water.', 85, 80, 130, 11, 15, NULL, NULL), 
	(132, 'Ditto', 'Capable of copying an enemy’s genetic code to instantly transform itself into a duplicate of the enemy.', 48, 48, 48, 1, 19, NULL, NULL), 
	(133, 'Eevee', 'Its genetic code is irregular. It may mutate if it is exposed to radiation from element STONEs.', 55, 50, 55, 1, 19, NULL, 25), 
	(134, 'Vaporeon', 'Lives close to water. Its long tail is ridged with a fin which is often mistaken for a mermaid’s.', 65, 60, 130, 11, 19, NULL, NULL), 
	(135, 'Jolteon', 'It accumulates negative ions in the atmosphere to blast out 10000-volt lightning bolts.', 65, 60, 65, 13, 19, NULL, NULL), 
	(136, 'Flareon', 'When storing thermal energy in its body, its temperature could soar to over 1600 degrees.', 130, 60, 65, 10, 19, NULL, NULL), 
	(137, 'Porygon', 'A POKéMON that consists entirely of programming code. Capable of moving freely in cyberspace.', 60, 70, 65, 1, 19, NULL, NULL), 
	(138, 'Omanyte', 'Although long extinct, in rare cases, it can be genetically resurrected from fossils.', 40, 100, 65, 6, 11, 139, 50), 
	(139, 'Omastar', 'A prehistoric POKéMON that died out when its heavy shell made it impossible to catch prey.', 60, 125, 70, 6, 11, NULL, NULL), 
	(140, 'Kabuto', 'A POKéMON that was resurrected from a fossil found in what was once the ocean floor eons ago.', 80, 90, 30, 6, 11, 141, 50), 
	(141, 'Kabutops', 'Its sleek shape is perfect for swimming. It slashes prey with its claws and drains the body fluids.', 115, 105, 65, 6, 11, NULL, NULL), 
	(142, 'Aerodactyl', 'A ferocious, prehistoric POKéMON that goes for the enemy’s throat with its serrated saw-like fangs.', 105, 65, 80, 6, 3, NULL, NULL), 
	(143, 'Snorlax', 'Very lazy. Just eats and sleeps. As its rotund bulk builds, it becomes steadily more slothful.', 110, 65, 160, 1, 19, NULL, NULL), 
	(144, 'Articuno', 'A legendary bird POKéMON that is said to appear to doomed people who are lost in icy mountains.', 85, 100, 90, 15, 3, NULL, NULL), 
	(145, 'Zapdos', 'A legendary bird POKéMON that is said to appear from clouds while dropping enormous lightning bolts.', 90, 85, 90, 13, 3, NULL, NULL), 
	(146, 'Moltres', 'Known as the legendary bird of fire. Every flap of its wings creates a dazzling flash of flames.', 100, 90, 90, 10, 3, NULL, NULL), 
	(147, 'Dratini', 'Long considered a mythical POKéMON until recently when a small colony was found living underwater.', 64, 45, 41, 16, 19, 148, 25), 
	(148, 'Dragonair', 'A mystical POKéMON that exudes a gentle aura. Has the ability to change climate conditions.', 84, 65, 61, 16, 19, 149, 100), 
	(149, 'Dragonite', 'An extremely rarely seen marine POKéMON. Its intelligence is said to match that of humans.', 134, 95, 91, 16, 3, NULL, NULL), 
	(150, 'Mewtwo', 'It was created by a scientist after years of horrific gene splicing and DNA engineering experiments.', 110, 90, 106, 14, 19, NULL, NULL), 
	(151, 'Mew', 'So rare that it is still said to be a mirage by many experts. Only a few people have seen it worldwide.', 100, 100, 100, 14, 19, NULL, NULL);

INSERT INTO `cpm` VALUES (1, 0.094), (1.5, 0.135137432), (2, 0.16639787), (2.5, 0.192650919), (3, 0.21573247), (3.5, 0.236572661), (4, 0.25572005), (4.5, 0.273530381), (5, 0.29024988), (5.5, 0.306057377), (6, 0.3210876), (6.5, 0.335445036), (7, 0.34921268), (7.5, 0.362457751), (8, 0.37523559), (8.5, 0.387592406), (9, 0.39956728), (9.5, 0.411193551), (10, 0.42250001), (10.5, 0.432926419), (11, 0.44310755), (11.5, 0.4530599578), (12, 0.46279839), (12.5, 0.472336083), (13, 0.48168495), (13.5, 0.4908558), (14, 0.49985844), (14.5, 0.508701765), (15, 0.51739395), (15.5, 0.525942511), (16, 0.53435433), (16.5, 0.542635767), (17, 0.55079269), (17.5, 0.558830576), (18, 0.56675452), (18.5, 0.574569153), (19, 0.58227891), (19.5, 0.589887917), (20, 0.59740001), (20.5, 0.604818814), (21, 0.61215729), (21.5, 0.619399365), (22, 0.62656713), (22.5, 0.633644533), (23, 0.64065295), (23.5, 0.647576426), (24, 0.65443563), (24.5, 0.661214806), (25, 0.667934), (25.5, 0.674577537), (26, 0.68116492), (26.5, 0.687680648), (27, 0.69414365), (27.5, 0.700538673), (28, 0.70688421), (28.5, 0.713164996), (29, 0.71939909), (29.5, 0.725571552), (30, 0.7317), (30.5, 0.734741009), (31, 0.73776948), (31.5, 0.740785574), (32, 0.74378943), (32.5, 0.746781211), (33, 0.74976104), (33.5, 0.752729087), (34, 0.75568551), (34.5, 0.758630378), (35, 0.76156384), (35.5, 0.764486065), (36, 0.76739717), (36.5, 0.770297266), (37, 0.7731865), (37.5, 0.776064962), (38, 0.77893275), (38.5, 0.781790055), (39, 0.78463697), (39.5, 0.787473578), (40, 0.79030001);

-- триггеры
DELIMITER //
-- триггер вычисления очков здоровья
DROP TRIGGER IF EXISTS hp_calc//
CREATE TRIGGER hp_calc BEFORE INSERT ON pokemons
FOR EACH ROW
BEGIN
	DECLARE base_stm INT;
	DECLARE mult FLOAT( 10, 9 );
	SELECT based_stamina INTO base_stm FROM pokedex WHERE pokedex.id = NEW.pokedex_id;
	SELECT cp_mult INTO mult FROM cpm WHERE cpm.cp_lvl = NEW.lvl;
	SET NEW.hp = FLOOR((base_stm + NEW.stamina_iv) * mult);
END//

-- триггер вычисления очков силы
DROP TRIGGER IF EXISTS cp_calc//
CREATE TRIGGER cp_calc BEFORE INSERT ON pokemons
FOR EACH ROW
BEGIN
	DECLARE base_atk INT;
	DECLARE base_def INT;
	DECLARE base_stm INT;
	DECLARE attack INT;
	DECLARE defense INT;
	DECLARE stamina INT;
	DECLARE tmp_cp INT;
	DECLARE mult FLOAT( 10, 9 );

	SELECT based_attack INTO base_atk FROM pokedex WHERE pokedex.id = NEW.pokedex_id;
	SELECT based_defense INTO base_def FROM pokedex WHERE pokedex.id = NEW.pokedex_id;
	SELECT based_stamina INTO base_stm FROM pokedex WHERE pokedex.id = NEW.pokedex_id;
	SELECT cp_mult INTO mult FROM cpm WHERE cpm.cp_lvl = NEW.lvl;

	SET attack = base_atk + NEW.attack_iv;
	SET defense = base_def + NEW.defense_iv;
	SET stamina = base_stm + NEW.stamina_iv;
	SET tmp_cp = FLOOR(( attack  * POWER(defense, 0.5) * POWER(stamina, 0.5) * POWER(mult, 2) ) / 10 );

	IF (tmp_cp < 10) THEN 
		SET NEW.combat_power = 10;
	ELSE 
		SET NEW.combat_power = tmp_cp;
	END IF;
END//
DELIMITER ;

-- http://filldb.info/dummy/
INSERT INTO `pokemons` VALUES (1,142,1,'eligendi',37.0,9,15,12,0,0,'1976-02-11 19:24:26',1,8,30,138,0,1,0), (2,17,2,'temporibus',14.0,4,4,11,0,0,'1988-06-04 08:11:24',18,17,26,15,1,0,1),(3,20,3,'earum',33.0,5,6,10,0,0,'1975-12-24 01:27:01',7,10,49,63,1,0,0),(4,3,4,'asperiores',37.0,12,6,1,0,0,'1971-08-25 01:44:49',18,3,25,58,1,1,0), (5,91,5,'nemo',28.0,2,15,15,0,0,'1976-05-21 03:51:04',5,6,21,82,1,0,0),(6,103,6,'neque',11.0,5,3,15,0,0,'1978-07-10 22:06:30',16,2,37,144,0,0,1),(7,51,7,'animi',1.0,11,2,13,0,0,'2003-04-29 07:58:12',17,17,30,146,1,1,1),(8,17,8,'neque',15.0,5,6,2,0,0,'2008-07-13 14:16:42',1,2,18,130,1,1,0),(9,23,9,'dolorem',31.0,10,4,14,0,0,'2005-09-27 12:13:11',7,5,40,92,1,0,1),(10,24,10,'id',30.0,7,12,1,0,0,'1989-06-26 02:59:39',3,8,14,124,0,1,1),(11,109,11,'asperiores',3.0,3,7,5,0,0,'2020-08-29 21:38:58',5,4,19,183,0,1,1),(12,107,12,'ut',39.0,6,6,5,0,0,'1996-06-26 13:05:57',5,13,44,52,0,0,0),(13,78,13,'dolorem',5.0,5,3,12,0,0,'1989-08-14 01:42:04',2,2,17,75,1,1,1),(14,134,14,'quas',21.0,2,14,12,0,0,'2020-05-23 02:32:46',14,11,28,83,1,0,1),(15,69,15,'beatae',34.0,1,4,13,0,0,'1976-05-08 07:14:49',8,7,34,113,0,1,0),(16,137,16,'saepe',10.0,2,7,11,0,0,'1974-02-22 05:15:18',9,11,20,135,0,1,1),(17,50,17,'voluptates',33.0,5,12,1,0,0,'1977-06-19 17:19:22',16,13,21,36,1,1,1),(18,132,18,'optio',18.0,5,6,12,0,0,'1985-02-04 20:25:28',17,3,28,19,1,1,1),(19,53,19,'qui',16.0,10,11,10,0,0,'2015-12-06 11:47:33',8,2,27,174,0,1,1),(20,33,20,'iure',40.0,8,11,8,0,0,'1987-12-28 12:30:28',6,12,40,197,0,1,0), (21,29,1,'a',25.0,1,12,3,0,0,'1970-11-24 04:42:44',16,9,38,160,0,1,0),(22,151,2,'quae',39.0,15,13,13,0,0,'1994-08-02 13:32:45',17,11,38,122,0,1,1),(23,70,3,'quia',20.0,8,10,14,0,0,'2016-10-14 08:58:28',8,10,29,184,1,0,1),(24,130,4,'dignissimos',26.0,9,11,8,0,0,'1973-06-25 07:06:39',9,7,46,36,1,0,0),(25,146,5,'vel',23.0,3,15,4,0,0,'1981-04-03 04:57:53',10,13,27,145,1,0,0),(26,143,6,'iusto',17.0,3,5,14,0,0,'1972-08-29 00:23:39',9,4,49,54,0,0,0),(27,140,7,'et',18.0,13,11,10,0,0,'2000-10-05 09:37:36',2,9,20,53,0,1,1),(28,18,8,'impedit',3.0,8,2,9,0,0,'2015-08-24 07:46:43',12,15,27,82,1,0,1),(29,41,9,'doloremque',12.0,6,3,12,0,0,'1985-01-20 17:43:57',3,8,34,142,0,1,1),(30,123,10,'magnam',23.0,8,9,12,0,0,'2016-03-01 22:36:48',11,14,24,80,1,1,1),(31,60,11,'vel',7.0,2,3,15,0,0,'1973-08-08 14:22:09',18,10,16,131,0,1,0),(32,4,12,'odio',32.0,6,10,5,0,0,'2012-03-13 09:33:25',15,1,20,40,1,1,1),(33,118,13,'id',26.0,5,15,1,0,0,'1971-04-28 02:44:36',3,2,44,51,1,0,0),(34,119,14,'perferendis',13.0,4,13,3,0,0,'2019-04-22 01:02:28',15,8,50,181,1,1,0),(35,144,15,'natus',1.0,7,5,5,0,0,'2012-10-16 15:19:06',14,14,12,28,0,0,1),(36,49,16,'qui',1.0,9,1,6,0,0,'2015-01-24 12:49:04',3,1,16,89,0,0,1),(37,125,17,'consequatur',16.0,1,7,9,0,0,'1994-05-18 16:44:20',8,4,25,80,1,0,1),(38,117,18,'sit',19.0,1,10,10,0,0,'1995-09-11 14:53:31',4,3,45,150,0,1,1),(39,116,19,'aspernatur',27.0,14,13,5,0,0,'2007-07-30 18:10:50',6,4,11,24,1,1,1),(40,43,20,'rem',32.0,15,3,12,0,0,'1985-04-11 02:23:15',2,18,14,188,1,0,0),(41,120,1,'labore',34.0,5,1,8,0,0,'2001-03-25 01:41:25',18,7,45,169,1,0,1),(42,33,2,'quibusdam',1.0,14,14,10,0,0,'2015-05-28 02:28:37',11,17,32,73,0,0,1),(43,35,3,'eveniet',34.0,10,2,1,0,0,'1977-01-22 06:08:54',3,8,23,131,1,0,1),(44,105,4,'magni',12.0,10,2,14,0,0,'1997-11-08 16:43:39',7,10,45,36,0,1,0),(45,116,5,'iure',11.0,1,2,13,0,0,'2016-02-23 19:33:50',10,18,19,97,0,0,0),(46,43,6,'quia',28.0,7,5,4,0,0,'2006-06-09 22:49:31',9,10,33,49,0,1,0),(47,26,7,'nihil',38.0,11,12,2,0,0,'1979-02-20 19:05:56',18,10,41,162,0,1,0),(48,21,8,'eos',40.0,6,13,6,0,0,'1985-10-08 21:19:20',7,14,14,191,0,0,0),(49,82,9,'a',38.0,3,13,8,0,0,'1971-11-11 19:29:04',7,7,35,102,0,0,1),(50,56,10,'cum',33.0,3,10,15,0,0,'1970-03-16 15:27:39',13,3,33,34,0,1,1),(51,82,11,'voluptas',2.0,9,2,14,0,0,'1990-09-22 10:45:16',15,1,35,105,1,0,1),(52,101,12,'laudantium',4.0,11,5,13,0,0,'1990-09-26 05:15:03',10,2,27,59,1,1,1),(53,144,13,'amet',9.0,10,2,12,0,0,'1974-07-12 06:05:23',7,5,10,12,1,1,1),(54,46,14,'quisquam',4.0,12,9,14,0,0,'1995-01-09 10:16:10',10,13,27,12,1,1,0),(55,13,15,'minus',40.0,14,15,10,0,0,'1988-08-16 20:18:33',5,11,17,176,0,0,0),(56,97,16,'earum',14.0,4,14,7,0,0,'1997-01-04 09:48:59',12,5,16,189,1,1,1),(57,35,17,'sunt',5.0,7,14,12,0,0,'1981-04-16 11:10:28',11,11,33,113,1,0,1),(58,39,18,'deserunt',18.0,15,4,4,0,0,'1973-12-22 17:01:51',9,11,46,118,1,1,1),(59,142,19,'officia',34.0,11,4,9,0,0,'1970-10-04 16:29:12',6,8,48,15,1,0,1),(60,110,20,'odit',26.0,10,9,15,0,0,'1996-01-15 11:05:35',5,9,49,21,0,0,0),(61,101,1,'illum',26.0,1,15,2,0,0,'2000-04-07 04:59:48',8,17,37,138,1,1,0),(62,92,2,'voluptas',33.0,8,13,8,0,0,'1992-04-19 23:11:45',3,12,26,118,0,0,1),(63,15,3,'sit',9.0,1,6,8,0,0,'2007-06-08 14:52:56',8,3,30,135,1,0,1),(64,127,4,'enim',9.0,3,5,5,0,0,'1987-06-19 17:54:59',6,5,32,34,0,0,1),(65,60,5,'illum',16.0,13,11,6,0,0,'2013-12-22 02:30:53',16,13,30,66,1,1,1),(66,148,6,'laudantium',20.0,13,6,5,0,0,'1973-08-17 06:42:01',11,16,48,31,0,1,0),(67,125,7,'consequatur',31.0,8,5,6,0,0,'2000-07-15 22:19:14',1,13,25,55,0,0,0),(68,102,8,'omnis',15.0,4,11,8,0,0,'1993-01-21 16:15:46',18,12,48,164,1,1,1),(69,55,9,'ab',21.0,4,14,5,0,0,'2009-07-26 10:47:01',2,3,28,180,0,0,1),(70,94,10,'quis',13.0,1,1,15,0,0,'1996-04-27 14:18:14',10,17,39,44,0,1,0),(71,30,11,'veniam',21.0,1,12,14,0,0,'1984-08-15 03:33:10',17,15,35,183,1,1,1),(72,71,12,'eum',2.0,1,5,4,0,0,'1981-11-26 19:55:12',9,9,34,140,0,0,1),(73,60,13,'et',1.0,5,15,10,0,0,'2010-06-03 23:46:46',6,5,38,199,0,0,1),(74,124,14,'omnis',36.0,5,12,9,0,0,'1993-04-05 03:15:49',6,11,23,116,0,1,1),(75,65,15,'laborum',37.0,2,8,7,0,0,'1983-12-02 02:40:36',6,12,31,170,1,1,1),(76,73,16,'nemo',18.0,8,14,11,0,0,'1993-11-27 16:46:45',17,5,30,84,0,0,0),(77,127,17,'qui',33.0,5,13,15,0,0,'2016-06-07 04:01:36',6,7,22,87,0,1,1),(78,16,18,'ut',7.0,3,6,4,0,0,'1971-11-29 18:27:28',17,5,15,59,1,1,1),(79,120,19,'distinctio',29.0,1,4,5,0,0,'1997-08-25 07:20:58',18,12,33,161,1,1,1),(80,143,20,'qui',4.0,1,4,5,0,0,'1990-09-06 04:19:54',17,5,48,116,0,1,1),(81,76,1,'dolorum',13.0,8,12,13,0,0,'2009-04-03 12:34:59',18,1,50,68,0,0,0),(82,117,2,'et',27.0,4,1,4,0,0,'1981-02-13 02:15:15',16,11,11,172,0,1,0),(83,99,3,'perferendis',2.0,8,7,11,0,0,'2009-04-20 18:07:50',2,13,13,134,1,1,1),(84,120,4,'mollitia',26.0,9,3,10,0,0,'1997-08-26 20:02:01',8,12,48,118,0,1,1),(85,18,5,'aperiam',35.0,1,4,12,0,0,'2009-09-11 06:37:34',6,12,26,180,1,0,0),(86,44,6,'eius',23.0,6,14,8,0,0,'2007-11-30 00:25:39',4,7,19,106,1,0,1),(87,141,7,'quas',8.0,13,5,3,0,0,'2014-06-06 19:20:12',1,4,43,36,0,0,0),(88,20,8,'cum',4.0,14,6,15,0,0,'1992-11-18 00:05:27',6,6,29,125,1,1,0),(89,149,9,'ipsa',24.0,15,15,13,0,0,'1976-08-01 14:07:58',17,5,34,110,1,0,0),(90,24,10,'voluptas',26.0,2,11,12,0,0,'1986-10-09 22:04:10',12,11,40,18,0,0,1),(91,22,11,'nostrum',18.0,9,6,4,0,0,'2002-12-16 19:55:06',5,1,33,36,0,0,0),(92,10,12,'laudantium',31.0,2,3,12,0,0,'2013-10-28 18:17:39',15,18,10,158,1,1,1),(93,132,13,'eaque',29.0,10,11,2,0,0,'1981-07-24 12:30:03',6,9,47,114,1,1,1),(94,140,14,'corporis',21.0,1,2,1,0,0,'1994-09-09 02:27:32',4,10,48,100,0,1,1),(95,105,15,'voluptatem',21.0,1,11,12,0,0,'2014-10-18 17:32:07',11,10,22,193,1,1,1),(96,47,16,'ea',14.0,8,3,9,0,0,'1975-08-18 17:17:57',15,2,25,190,1,1,1),(97,131,17,'saepe',21.0,5,2,11,0,0,'1991-12-08 10:38:13',18,16,13,53,0,1,1),(98,52,18,'veritatis',13.0,10,7,5,0,0,'2007-02-18 21:35:17',8,14,47,24,0,0,0),(99,128,19,'eos',3.0,2,3,2,0,0,'2002-08-20 18:26:49',10,10,14,196,1,0,1),(100,98,20,'eligendi',25.0,1,10,1,0,0,'2018-10-09 20:57:53',13,14,47,85,0,0,1);
INSERT INTO `candies` VALUES (1,1,311),(1,2,343),(1,3,480),(1,4,85),(1,5,186),(1,6,200),(1,7,363),(1,8,481),(1,9,37),(1,10,262),(1,11,226),(1,12,211),(1,13,460),(1,14,62),(1,15,449),(1,16,487),(1,17,371),(1,18,265),(1,19,359),(1,20,228),(1,21,200),(1,22,373),(1,23,58),(1,24,28),(1,25,448),(1,26,294),(1,27,453),(1,28,316),(1,29,135),(1,30,277),(1,31,18),(1,32,398),(1,33,287),(1,34,286),(1,35,338),(1,36,167),(1,37,230),(1,38,266),(1,39,451),(1,40,414),(1,41,120),(1,42,381),(1,43,214),(1,44,82),(1,45,165),(1,46,268),(1,47,456),(1,48,34),(1,49,123),(1,50,159),(1,51,28),(1,52,295),(1,53,336),(1,54,29),(1,55,366),(1,56,106),(1,57,358),(1,58,9),(1,59,385),(1,60,462),(1,61,77),(1,62,421),(1,63,304),(1,64,417),(1,65,500),(1,66,248),(1,67,305),(1,68,287),(1,69,394),(1,70,261),(1,71,480),(1,72,426),(1,73,389),(1,74,153),(1,75,0),(1,76,308),(1,77,342),(1,78,43),(1,79,474),(1,80,394),(1,81,175),(1,82,10),(1,83,453),(1,84,331),(1,85,45),(1,86,131),(1,87,350),(1,88,13),(1,89,432),(1,90,101),(1,91,192),(1,92,499),(1,93,145),(1,94,468),(1,95,275),(1,96,339),(1,97,198),(1,98,83),(1,99,227),(1,100,480),(1,101,268),(1,102,162),(1,103,197),(1,104,303),(1,105,398),(1,106,500),(1,107,389),(1,108,414),(1,109,198),(1,110,405),(1,111,418),(1,112,334),(1,113,370),(1,114,386),(1,115,443),(1,116,154),(1,117,246),(1,118,249),(1,119,249),(1,120,309),(1,121,243),(1,122,186),(1,123,197),(1,124,21),(1,125,311),(1,126,446),(1,127,63),(1,128,436),(1,129,385),(1,130,363),(1,131,196),(1,132,76),(1,133,469),(1,134,74),(1,135,414),(1,136,303),(1,137,463),(1,138,387),(1,139,259),(1,140,106),(1,141,337),(1,142,125),(1,143,302),(1,144,309),(1,145,101),(1,146,476),(1,147,201),(1,148,318),(1,149,12),(1,150,56),(1,151,461),(2,1,136),(2,2,176),(2,3,352),(2,4,376),(2,5,353),(2,6,300),(2,7,284),(2,8,280),(2,9,187),(2,10,142),(2,11,363),(2,12,269),(2,13,221),(2,14,44),(2,15,122),(2,16,456),(2,17,65),(2,18,482),(2,19,401),(2,20,448),(2,21,112),(2,22,223),(2,23,26),(2,24,163),(2,25,47),(2,26,168),(2,27,139),(2,28,418),(2,29,311),(2,30,207),(2,31,474),(2,32,56),(2,33,436),(2,34,85),(2,35,39),(2,36,323),(2,37,424),(2,38,403),(2,39,236),(2,40,171),(2,41,179),(2,42,216),(2,43,489),(2,44,155),(2,45,3),(2,46,234),(2,47,148),(2,48,450),(2,49,327),(2,50,233),(2,51,371),(2,52,413),(2,53,146),(2,54,3),(2,55,285),(2,56,109),(2,57,27),(2,58,105),(2,59,283),(2,60,369),(2,61,250),(2,62,178),(2,63,389),(2,64,284),(2,65,18),(2,66,367),(2,67,361),(2,68,448),(2,69,160),(2,70,109),(2,71,175),(2,72,114),(2,73,157),(2,74,346),(2,75,213),(2,76,366),(2,77,184),(2,78,304),(2,79,195),(2,80,92),(2,81,251),(2,82,72),(2,83,361),(2,84,263),(2,85,486),(2,86,69),(2,87,89),(2,88,279),(2,89,214),(2,90,382),(2,91,80),(2,92,335),(2,93,491),(2,94,263),(2,95,152),(2,96,140),(2,97,341),(2,98,480),(2,99,255),(2,100,313),(2,101,460),(2,102,171),(2,103,174),(2,104,477),(2,105,407),(2,106,54),(2,107,222),(2,108,120),(2,109,5),(2,110,24),(2,111,377),(2,112,30),(2,113,181),(2,114,334),(2,115,20),(2,116,433),(2,117,396),(2,118,76),(2,119,407),(2,120,298),(2,121,412),(2,122,455),(2,123,148),(2,124,218),(2,125,114),(2,126,212),(2,127,44),(2,128,145),(2,129,123),(2,130,165),(2,131,431),(2,132,291),(2,133,94),(2,134,14),(2,135,405),(2,136,261),(2,137,95),(2,138,155),(2,139,122),(2,140,332),(2,141,482),(2,142,189),(2,143,399),(2,144,460),(2,145,357),(2,146,383),(2,147,481),(2,148,165),(2,149,312),(2,150,379),(2,151,206),(3,1,38),(3,2,298),(3,3,472),(3,4,425),(3,5,352),(3,6,8),(3,7,424),(3,8,236),(3,9,176),(3,10,98),(3,11,22),(3,12,64),(3,13,366),(3,14,393),(3,15,497),(3,16,374),(3,17,60),(3,18,45),(3,19,339),(3,20,426),(3,21,367),(3,22,112),(3,23,15),(3,24,143),(3,25,279),(3,26,151),(3,27,269),(3,28,321),(3,29,33),(3,30,452),(3,31,50),(3,32,16),(3,33,234),(3,34,278),(3,35,336),(3,36,143),(3,37,258),(3,38,149),(3,39,403),(3,40,372),(3,41,179),(3,42,292),(3,43,194),(3,44,381),(3,45,9),(3,46,73),(3,47,277),(3,48,411),(3,49,407),(3,50,493),(3,51,139),(3,52,461),(3,53,492),(3,54,214),(3,55,392),(3,56,44),(3,57,96),(3,58,360),(3,59,238),(3,60,206),(3,61,295),(3,62,246),(3,63,122),(3,64,240),(3,65,463),(3,66,197),(3,67,182),(3,68,228),(3,69,319),(3,70,336),(3,71,85),(3,72,55),(3,73,96),(3,74,463),(3,75,163),(3,76,378),(3,77,84),(3,78,322),(3,79,487),(3,80,228),(3,81,161),(3,82,355),(3,83,225),(3,84,351),(3,85,25),(3,86,22),(3,87,42),(3,88,26),(3,89,14),(3,90,52),(3,91,307),(3,92,301),(3,93,269),(3,94,221),(3,95,417),(3,96,407),(3,97,284),(3,98,411),(3,99,257),(3,100,378),(3,101,12),(3,102,138),(3,103,267),(3,104,472),(3,105,25),(3,106,40),(3,107,264),(3,108,232),(3,109,65),(3,110,127),(3,111,383),(3,112,380),(3,113,123),(3,114,61),(3,115,173),(3,116,26),(3,117,9),(3,118,322),(3,119,147),(3,120,439),(3,121,214),(3,122,284),(3,123,298),(3,124,354),(3,125,458),(3,126,114),(3,127,25),(3,128,159),(3,129,181),(3,130,92),(3,131,168),(3,132,421),(3,133,238),(3,134,461),(3,135,288),(3,136,77),(3,137,2),(3,138,65),(3,139,481),(3,140,189),(3,141,95),(3,142,159),(3,143,172),(3,144,369),(3,145,137),(3,146,456),(3,147,57),(3,148,344),(3,149,48),(3,150,28),(3,151,397),(4,1,42),(4,2,428),(4,3,75),(4,4,477),(4,5,439),(4,6,391),(4,7,200),(4,8,7),(4,9,74),(4,10,338),(4,11,335),(4,12,296),(4,13,365),(4,14,239),(4,15,72),(4,16,151),(4,17,326),(4,18,284),(4,19,182),(4,20,171),(4,21,494),(4,22,330),(4,23,243),(4,24,2),(4,25,315),(4,26,88),(4,27,313),(4,28,282),(4,29,22),(4,30,70),(4,31,425),(4,32,136),(4,33,264),(4,34,321),(4,35,27),(4,36,437),(4,37,395),(4,38,33),(4,39,479),(4,40,472),(4,41,22),(4,42,209),(4,43,248),(4,44,261),(4,45,138),(4,46,353),(4,47,464),(4,48,404),(4,49,187),(4,50,491),(4,51,320),(4,52,245),(4,53,99),(4,54,297),(4,55,283),(4,56,409),(4,57,17),(4,58,52),(4,59,119),(4,60,241),(4,61,233),(4,62,177),(4,63,244),(4,64,282),(4,65,229),(4,66,156),(4,67,458),(4,68,234),(4,69,225),(4,70,212),(4,71,107),(4,72,162),(4,73,313),(4,74,174),(4,75,183),(4,76,251),(4,77,366),(4,78,357),(4,79,387),(4,80,431),(4,81,353),(4,82,230),(4,83,59),(4,84,216),(4,85,300),(4,86,7),(4,87,454),(4,88,470),(4,89,239),(4,90,90),(4,91,97),(4,92,399),(4,93,475),(4,94,44),(4,95,466),(4,96,426),(4,97,157),(4,98,14),(4,99,402),(4,100,277),(4,101,425),(4,102,413),(4,103,41),(4,104,379),(4,105,124),(4,106,195),(4,107,147),(4,108,346),(4,109,427),(4,110,156),(4,111,133),(4,112,184),(4,113,229),(4,114,305),(4,115,442),(4,116,285),(4,117,313),(4,118,10),(4,119,153),(4,120,382),(4,121,244),(4,122,336),(4,123,198),(4,124,234),(4,125,115),(4,126,475),(4,127,311),(4,128,84),(4,129,198),(4,130,382),(4,131,8),(4,132,20),(4,133,57),(4,134,173),(4,135,472),(4,136,321),(4,137,84),(4,138,343),(4,139,392),(4,140,212),(4,141,412),(4,142,264),(4,143,238),(4,144,303),(4,145,222),(4,146,240),(4,147,472),(4,148,273),(4,149,137),(4,150,128),(4,151,328),(5,1,334),(5,2,336),(5,3,194),(5,4,259),(5,5,85),(5,6,316),(5,7,270),(5,8,117),(5,9,21),(5,10,233),(5,11,84),(5,12,355),(5,13,343),(5,14,55),(5,15,15),(5,16,23),(5,17,86),(5,18,429),(5,19,482),(5,20,366),(5,21,14),(5,22,195),(5,23,143),(5,24,101),(5,25,228),(5,26,399),(5,27,382),(5,28,301),(5,29,472),(5,30,373),(5,31,382),(5,32,308),(5,33,7),(5,34,453),(5,35,292),(5,36,315),(5,37,447),(5,38,64),(5,39,402),(5,40,169),(5,41,102),(5,42,479),(5,43,412),(5,44,3),(5,45,311),(5,46,313),(5,47,498),(5,48,62),(5,49,243),(5,50,54),(5,51,138),(5,52,70),(5,53,101),(5,54,9),(5,55,132),(5,56,279),(5,57,482),(5,58,256),(5,59,341),(5,60,423),(5,61,230),(5,62,126),(5,63,241),(5,64,11),(5,65,200),(5,66,495),(5,67,248),(5,68,342),(5,69,477),(5,70,338),(5,71,382),(5,72,145),(5,73,49),(5,74,27),(5,75,373),(5,76,397),(5,77,81),(5,78,304),(5,79,397),(5,80,417),(5,81,6),(5,82,44),(5,83,485),(5,84,223),(5,85,144),(5,86,429),(5,87,298),(5,88,27),(5,89,464),(5,90,340),(5,91,7),(5,92,379),(5,93,428),(5,94,463),(5,95,263),(5,96,143),(5,97,175),(5,98,261),(5,99,19),(5,100,76),(5,101,79),(5,102,499),(5,103,255),(5,104,38),(5,105,470),(5,106,227),(5,107,214),(5,108,256),(5,109,327),(5,110,499),(5,111,414),(5,112,203),(5,113,260),(5,114,158),(5,115,496),(5,116,355),(5,117,374),(5,118,327),(5,119,316),(5,120,318),(5,121,432),(5,122,94),(5,123,44),(5,124,192),(5,125,10),(5,126,313),(5,127,150),(5,128,372),(5,129,462),(5,130,120),(5,131,358),(5,132,472),(5,133,318),(5,134,423),(5,135,381),(5,136,269),(5,137,136),(5,138,314),(5,139,357),(5,140,211),(5,141,481),(5,142,318),(5,143,397),(5,144,30),(5,145,118),(5,146,473),(5,147,54),(5,148,460),(5,149,303),(5,150,252),(5,151,29),(6,1,41),(6,2,399),(6,3,448),(6,4,248),(6,5,144),(6,6,113),(6,7,183),(6,8,310),(6,9,350),(6,10,167),(6,11,372),(6,12,242),(6,13,246),(6,14,339),(6,15,0),(6,16,211),(6,17,8),(6,18,429),(6,19,161),(6,20,119),(6,21,317),(6,22,160),(6,23,383),(6,24,491),(6,25,136),(6,26,391),(6,27,258),(6,28,45),(6,29,274),(6,30,380),(6,31,422),(6,32,316),(6,33,103),(6,34,264),(6,35,220),(6,36,81),(6,37,443),(6,38,486),(6,39,194),(6,40,341),(6,41,247),(6,42,184),(6,43,317),(6,44,470),(6,45,245),(6,46,419),(6,47,267),(6,48,60),(6,49,6),(6,50,70),(6,51,311),(6,52,181),(6,53,340),(6,54,480),(6,55,472),(6,56,324),(6,57,481),(6,58,108),(6,59,448),(6,60,205),(6,61,294),(6,62,350),(6,63,410),(6,64,249),(6,65,345),(6,66,465),(6,67,103),(6,68,106),(6,69,483),(6,70,254),(6,71,438),(6,72,220),(6,73,51),(6,74,17),(6,75,143),(6,76,66),(6,77,252),(6,78,106),(6,79,28),(6,80,254),(6,81,121),(6,82,251),(6,83,144),(6,84,224),(6,85,194),(6,86,342),(6,87,201),(6,88,32),(6,89,354),(6,90,8),(6,91,420),(6,92,29),(6,93,105),(6,94,251),(6,95,371),(6,96,122),(6,97,93),(6,98,307),(6,99,284),(6,100,496),(6,101,441),(6,102,182),(6,103,422),(6,104,268),(6,105,243),(6,106,6),(6,107,8),(6,108,28),(6,109,129),(6,110,80),(6,111,336),(6,112,192),(6,113,279),(6,114,330),(6,115,500),(6,116,409),(6,117,95),(6,118,281),(6,119,463),(6,120,263),(6,121,496),(6,122,215),(6,123,491),(6,124,207),(6,125,287),(6,126,64),(6,127,278),(6,128,61),(6,129,180),(6,130,23),(6,131,123),(6,132,72),(6,133,122),(6,134,391),(6,135,298),(6,136,293),(6,137,400),(6,138,95),(6,139,342),(6,140,372),(6,141,70),(6,142,408),(6,143,14),(6,144,292),(6,145,190),(6,146,104),(6,147,330),(6,148,211),(6,149,189),(6,150,484),(6,151,195),(7,1,419),(7,2,39),(7,3,244),(7,4,401),(7,5,190),(7,6,154),(7,7,85),(7,8,183),(7,9,201),(7,10,476),(7,11,327),(7,12,319),(7,13,16),(7,14,126),(7,15,486),(7,16,217),(7,17,428),(7,18,150),(7,19,461),(7,20,129),(7,21,229),(7,22,78),(7,23,356),(7,24,68),(7,25,80),(7,26,462),(7,27,65),(7,28,75),(7,29,403),(7,30,45),(7,31,201),(7,32,366),(7,33,49),(7,34,14),(7,35,348),(7,36,469),(7,37,293),(7,38,352),(7,39,208),(7,40,52),(7,41,235),(7,42,60),(7,43,180),(7,44,61),(7,45,45),(7,46,292),(7,47,500),(7,48,258),(7,49,33),(7,50,17),(7,51,168),(7,52,136),(7,53,438),(7,54,476),(7,55,221),(7,56,317),(7,57,389),(7,58,272),(7,59,267),(7,60,277),(7,61,87),(7,62,270),(7,63,439),(7,64,355),(7,65,41),(7,66,73),(7,67,308),(7,68,45),(7,69,125),(7,70,275),(7,71,133),(7,72,202),(7,73,204),(7,74,486),(7,75,270),(7,76,308),(7,77,439),(7,78,148),(7,79,144),(7,80,275),(7,81,147),(7,82,410),(7,83,11),(7,84,420),(7,85,73),(7,86,496),(7,87,216),(7,88,360),(7,89,47),(7,90,266),(7,91,170),(7,92,373),(7,93,3),(7,94,99),(7,95,300),(7,96,472),(7,97,52),(7,98,434),(7,99,348),(7,100,199),(7,101,151),(7,102,475),(7,103,470),(7,104,294),(7,105,281),(7,106,2),(7,107,409),(7,108,52),(7,109,321),(7,110,275),(7,111,194),(7,112,180),(7,113,25),(7,114,251),(7,115,202),(7,116,284),(7,117,477),(7,118,139),(7,119,252),(7,120,50),(7,121,432),(7,122,73),(7,123,96),(7,124,424),(7,125,115),(7,126,365),(7,127,493),(7,128,73),(7,129,304),(7,130,337),(7,131,114),(7,132,293),(7,133,348),(7,134,417),(7,135,134),(7,136,205),(7,137,279),(7,138,399),(7,139,372),(7,140,337),(7,141,194),(7,142,189),(7,143,341),(7,144,253),(7,145,382),(7,146,112),(7,147,273),(7,148,104),(7,149,91),(7,150,388),(7,151,410),(8,1,428),(8,2,80),(8,3,174),(8,4,482),(8,5,24),(8,6,265),(8,7,6),(8,8,117),(8,9,23),(8,10,161),(8,11,159),(8,12,348),(8,13,94),(8,14,472),(8,15,439),(8,16,437),(8,17,387),(8,18,247),(8,19,500),(8,20,374),(8,21,412),(8,22,489),(8,23,218),(8,24,107),(8,25,36),(8,26,263),(8,27,148),(8,28,331),(8,29,347),(8,30,99),(8,31,296),(8,32,389),(8,33,327),(8,34,89),(8,35,328),(8,36,210),(8,37,174),(8,38,382),(8,39,129),(8,40,11),(8,41,35),(8,42,122),(8,43,240),(8,44,40),(8,45,477),(8,46,279),(8,47,8),(8,48,65),(8,49,302),(8,50,434),(8,51,108),(8,52,282),(8,53,499),(8,54,173),(8,55,324),(8,56,208),(8,57,19),(8,58,114),(8,59,379),(8,60,12),(8,61,215),(8,62,179),(8,63,427),(8,64,395),(8,65,460),(8,66,204),(8,67,114),(8,68,93),(8,69,277),(8,70,91),(8,71,85),(8,72,177),(8,73,55),(8,74,29),(8,75,205),(8,76,254),(8,77,379),(8,78,120),(8,79,455),(8,80,203),(8,81,288),(8,82,95),(8,83,431),(8,84,156),(8,85,200),(8,86,356),(8,87,426),(8,88,104),(8,89,350),(8,90,278),(8,91,285),(8,92,373),(8,93,305),(8,94,217),(8,95,440),(8,96,416),(8,97,389),(8,98,404),(8,99,320),(8,100,338),(8,101,386),(8,102,92),(8,103,414),(8,104,83),(8,105,476),(8,106,99),(8,107,280),(8,108,79),(8,109,204),(8,110,108),(8,111,302),(8,112,0),(8,113,259),(8,114,220),(8,115,263),(8,116,77),(8,117,171),(8,118,195),(8,119,344),(8,120,30),(8,121,243),(8,122,300),(8,123,460),(8,124,438),(8,125,27),(8,126,225),(8,127,84),(8,128,308),(8,129,467),(8,130,77),(8,131,248),(8,132,112),(8,133,137),(8,134,460),(8,135,124),(8,136,49),(8,137,114),(8,138,250),(8,139,42),(8,140,306),(8,141,266),(8,142,145),(8,143,57),(8,144,498),(8,145,191),(8,146,61),(8,147,434),(8,148,96),(8,149,440),(8,150,200),(8,151,331),(9,1,375),(9,2,185),(9,3,321),(9,4,290),(9,5,72),(9,6,432),(9,7,11),(9,8,350),(9,9,45),(9,10,30),(9,11,405),(9,12,4),(9,13,489),(9,14,382),(9,15,122),(9,16,57),(9,17,175),(9,18,64),(9,19,387),(9,20,172),(9,21,325),(9,22,232),(9,23,384),(9,24,404),(9,25,231),(9,26,289),(9,27,11),(9,28,355),(9,29,170),(9,30,107),(9,31,327),(9,32,151),(9,33,362),(9,34,430),(9,35,403),(9,36,483),(9,37,222),(9,38,65),(9,39,49),(9,40,349),(9,41,315),(9,42,245),(9,43,160),(9,44,344),(9,45,427),(9,46,370),(9,47,86),(9,48,121),(9,49,21),(9,50,404),(9,51,186),(9,52,363),(9,53,111),(9,54,124),(9,55,277),(9,56,11),(9,57,258),(9,58,428),(9,59,181),(9,60,498),(9,61,157),(9,62,59),(9,63,321),(9,64,242),(9,65,87),(9,66,35),(9,67,22),(9,68,269),(9,69,321),(9,70,201),(9,71,187),(9,72,417),(9,73,26),(9,74,66),(9,75,467),(9,76,226),(9,77,81),(9,78,70),(9,79,402),(9,80,500),(9,81,242),(9,82,362),(9,83,310),(9,84,62),(9,85,288),(9,86,210),(9,87,396),(9,88,187),(9,89,408),(9,90,461),(9,91,172),(9,92,453),(9,93,171),(9,94,471),(9,95,0),(9,96,196),(9,97,118),(9,98,42),(9,99,378),(9,100,226),(9,101,333),(9,102,471),(9,103,482),(9,104,6),(9,105,171),(9,106,357),(9,107,334),(9,108,321),(9,109,121),(9,110,243),(9,111,104),(9,112,361),(9,113,221),(9,114,122),(9,115,255),(9,116,377),(9,117,242),(9,118,418),(9,119,435),(9,120,321),(9,121,169),(9,122,42),(9,123,134),(9,124,353),(9,125,263),(9,126,215),(9,127,238),(9,128,173),(9,129,459),(9,130,450),(9,131,460),(9,132,140),(9,133,185),(9,134,474),(9,135,36),(9,136,28),(9,137,402),(9,138,104),(9,139,417),(9,140,144),(9,141,52),(9,142,453),(9,143,262),(9,144,135),(9,145,453),(9,146,75),(9,147,198),(9,148,235),(9,149,201),(9,150,286),(9,151,366),(10,1,37),(10,2,487),(10,3,277),(10,4,27),(10,5,342),(10,6,240),(10,7,221),(10,8,304),(10,9,131),(10,10,390),(10,11,465),(10,12,194),(10,13,489),(10,14,205),(10,15,437),(10,16,384),(10,17,47),(10,18,366),(10,19,475),(10,20,327),(10,21,114),(10,22,12),(10,23,51),(10,24,85),(10,25,414),(10,26,223),(10,27,309),(10,28,264),(10,29,387),(10,30,381),(10,31,109),(10,32,212),(10,33,379),(10,34,36),(10,35,40),(10,36,102),(10,37,326),(10,38,453),(10,39,108),(10,40,94),(10,41,180),(10,42,434),(10,43,313),(10,44,7),(10,45,79),(10,46,337),(10,47,262),(10,48,241),(10,49,161),(10,50,325),(10,51,393),(10,52,295),(10,53,453),(10,54,9),(10,55,313),(10,56,280),(10,57,484),(10,58,80),(10,59,210),(10,60,298),(10,61,92),(10,62,426),(10,63,133),(10,64,191),(10,65,158),(10,66,279),(10,67,401),(10,68,5),(10,69,276),(10,70,180),(10,71,225),(10,72,100),(10,73,121),(10,74,29),(10,75,18),(10,76,332),(10,77,207),(10,78,436),(10,79,485),(10,80,347),(10,81,52),(10,82,244),(10,83,61),(10,84,425),(10,85,418),(10,86,24),(10,87,406),(10,88,414),(10,89,314),(10,90,391),(10,91,405),(10,92,196),(10,93,469),(10,94,348),(10,95,384),(10,96,295),(10,97,424),(10,98,95),(10,99,250),(10,100,129),(10,101,452),(10,102,34),(10,103,465),(10,104,278),(10,105,181),(10,106,423),(10,107,499),(10,108,416),(10,109,339),(10,110,40),(10,111,429),(10,112,140),(10,113,165),(10,114,247),(10,115,38),(10,116,222),(10,117,451),(10,118,482),(10,119,409),(10,120,230),(10,121,74),(10,122,94),(10,123,446),(10,124,477),(10,125,219),(10,126,323),(10,127,476),(10,128,129),(10,129,497),(10,130,1),(10,131,472),(10,132,287),(10,133,189),(10,134,275),(10,135,370),(10,136,324),(10,137,209),(10,138,278),(10,139,435),(10,140,140),(10,141,391),(10,142,407),(10,143,8),(10,144,92),(10,145,320),(10,146,270),(10,147,177),(10,148,396),(10,149,155),(10,150,33),(10,151,352),(11,1,199),(11,2,209),(11,3,88),(11,4,414),(11,5,394),(11,6,322),(11,7,321),(11,8,400),(11,9,247),(11,10,239),(11,11,225),(11,12,13),(11,13,358),(11,14,393),(11,15,97),(11,16,336),(11,17,16),(11,18,319),(11,19,284),(11,20,148),(11,21,42),(11,22,67),(11,23,431),(11,24,104),(11,25,350),(11,26,488),(11,27,283),(11,28,186),(11,29,244),(11,30,449),(11,31,184),(11,32,188),(11,33,472),(11,34,498),(11,35,441),(11,36,158),(11,37,151),(11,38,486),(11,39,357),(11,40,67),(11,41,178),(11,42,489),(11,43,298),(11,44,393),(11,45,245),(11,46,325),(11,47,457),(11,48,186),(11,49,427),(11,50,484),(11,51,325),(11,52,385),(11,53,246),(11,54,242),(11,55,337),(11,56,193),(11,57,267),(11,58,490),(11,59,244),(11,60,488),(11,61,36),(11,62,83),(11,63,490),(11,64,355),(11,65,38),(11,66,159),(11,67,100),(11,68,254),(11,69,381),(11,70,462),(11,71,240),(11,72,321),(11,73,322),(11,74,86),(11,75,403),(11,76,347),(11,77,46),(11,78,150),(11,79,221),(11,80,297),(11,81,440),(11,82,250),(11,83,311),(11,84,101),(11,85,70),(11,86,341),(11,87,362),(11,88,423),(11,89,449),(11,90,312),(11,91,40),(11,92,257),(11,93,288),(11,94,60),(11,95,51),(11,96,133),(11,97,210),(11,98,317),(11,99,402),(11,100,377),(11,101,164),(11,102,259),(11,103,484),(11,104,270),(11,105,239),(11,106,463),(11,107,143),(11,108,459),(11,109,310),(11,110,330),(11,111,144),(11,112,403),(11,113,452),(11,114,369),(11,115,396),(11,116,31),(11,117,311),(11,118,214),(11,119,216),(11,120,97),(11,121,399),(11,122,124),(11,123,99),(11,124,277),(11,125,320),(11,126,317),(11,127,307),(11,128,415),(11,129,497),(11,130,192),(11,131,423),(11,132,276),(11,133,273),(11,134,174),(11,135,210),(11,136,225),(11,137,440),(11,138,227),(11,139,223),(11,140,458),(11,141,282),(11,142,416),(11,143,456),(11,144,214),(11,145,174),(11,146,53),(11,147,112),(11,148,429),(11,149,123),(11,150,308),(11,151,484),(12,1,224),(12,2,117),(12,3,83),(12,4,59),(12,5,18),(12,6,415),(12,7,40),(12,8,291),(12,9,480),(12,10,495),(12,11,403),(12,12,353),(12,13,146),(12,14,155),(12,15,168),(12,16,20),(12,17,425),(12,18,154),(12,19,122),(12,20,413),(12,21,463),(12,22,10),(12,23,455),(12,24,111),(12,25,13),(12,26,136),(12,27,11),(12,28,205),(12,29,158),(12,30,329),(12,31,441),(12,32,379),(12,33,456),(12,34,478),(12,35,98),(12,36,30),(12,37,323),(12,38,43),(12,39,285),(12,40,317),(12,41,347),(12,42,418),(12,43,259),(12,44,158),(12,45,126),(12,46,374),(12,47,139),(12,48,133),(12,49,484),(12,50,444),(12,51,419),(12,52,180),(12,53,332),(12,54,229),(12,55,316),(12,56,97),(12,57,62),(12,58,258),(12,59,354),(12,60,133),(12,61,407),(12,62,97),(12,63,358),(12,64,380),(12,65,49),(12,66,156),(12,67,9),(12,68,331),(12,69,119),(12,70,358),(12,71,435),(12,72,371),(12,73,307),(12,74,393),(12,75,314),(12,76,90),(12,77,121),(12,78,498),(12,79,239),(12,80,172),(12,81,425),(12,82,164),(12,83,125),(12,84,261),(12,85,168),(12,86,236),(12,87,276),(12,88,254),(12,89,395),(12,90,235),(12,91,342),(12,92,136),(12,93,375),(12,94,93),(12,95,271),(12,96,262),(12,97,158),(12,98,88),(12,99,490),(12,100,230),(12,101,209),(12,102,333),(12,103,451),(12,104,69),(12,105,257),(12,106,380),(12,107,327),(12,108,214),(12,109,365),(12,110,164),(12,111,277),(12,112,392),(12,113,406),(12,114,107),(12,115,114),(12,116,246),(12,117,258),(12,118,310),(12,119,488),(12,120,474),(12,121,28),(12,122,22),(12,123,109),(12,124,427),(12,125,242),(12,126,168),(12,127,274),(12,128,384),(12,129,196),(12,130,357),(12,131,201),(12,132,401),(12,133,310),(12,134,15),(12,135,81),(12,136,1),(12,137,386),(12,138,350),(12,139,286),(12,140,267),(12,141,232),(12,142,189),(12,143,385),(12,144,54),(12,145,186),(12,146,150),(12,147,104),(12,148,114),(12,149,368),(12,150,287),(12,151,75),(13,1,369),(13,2,146),(13,3,187),(13,4,334),(13,5,90),(13,6,313),(13,7,349),(13,8,413),(13,9,230),(13,10,97),(13,11,228),(13,12,324),(13,13,349),(13,14,5),(13,15,111),(13,16,127),(13,17,370),(13,18,398),(13,19,32),(13,20,482),(13,21,284),(13,22,384),(13,23,484),(13,24,175),(13,25,69),(13,26,297),(13,27,300),(13,28,144),(13,29,291),(13,30,390),(13,31,367),(13,32,281),(13,33,360),(13,34,384),(13,35,418),(13,36,101),(13,37,219),(13,38,113),(13,39,274),(13,40,267),(13,41,497),(13,42,204),(13,43,266),(13,44,272),(13,45,216),(13,46,2),(13,47,153),(13,48,15),(13,49,158),(13,50,383),(13,51,441),(13,52,215),(13,53,336),(13,54,457),(13,55,394),(13,56,35),(13,57,24),(13,58,391),(13,59,33),(13,60,309),(13,61,73),(13,62,364),(13,63,333),(13,64,182),(13,65,115),(13,66,221),(13,67,218),(13,68,490),(13,69,393),(13,70,127),(13,71,289),(13,72,331),(13,73,134),(13,74,350),(13,75,47),(13,76,187),(13,77,8),(13,78,249),(13,79,334),(13,80,33),(13,81,133),(13,82,389),(13,83,207),(13,84,342),(13,85,156),(13,86,496),(13,87,284),(13,88,120),(13,89,42),(13,90,10),(13,91,390),(13,92,383),(13,93,138),(13,94,42),(13,95,31),(13,96,211),(13,97,306),(13,98,353),(13,99,452),(13,100,213),(13,101,60),(13,102,80),(13,103,64),(13,104,122),(13,105,27),(13,106,132),(13,107,176),(13,108,188),(13,109,83),(13,110,392),(13,111,276),(13,112,246),(13,113,328),(13,114,122),(13,115,322),(13,116,450),(13,117,432),(13,118,187),(13,119,114),(13,120,201),(13,121,350),(13,122,451),(13,123,144),(13,124,479),(13,125,353),(13,126,406),(13,127,77),(13,128,397),(13,129,85),(13,130,232),(13,131,478),(13,132,445),(13,133,282),(13,134,403),(13,135,143),(13,136,448),(13,137,264),(13,138,79),(13,139,37),(13,140,196),(13,141,155),(13,142,96),(13,143,156),(13,144,427),(13,145,145),(13,146,182),(13,147,40),(13,148,388),(13,149,342),(13,150,82),(13,151,50),(14,1,113),(14,2,463),(14,3,370),(14,4,461),(14,5,447),(14,6,283),(14,7,83),(14,8,342),(14,9,337),(14,10,254),(14,11,497),(14,12,221),(14,13,181),(14,14,299),(14,15,411),(14,16,50),(14,17,219),(14,18,94),(14,19,27),(14,20,453),(14,21,406),(14,22,370),(14,23,54),(14,24,33),(14,25,179),(14,26,338),(14,27,19),(14,28,482),(14,29,145),(14,30,126),(14,31,146),(14,32,36),(14,33,451),(14,34,74),(14,35,105),(14,36,169),(14,37,441),(14,38,396),(14,39,45),(14,40,452),(14,41,193),(14,42,452),(14,43,441),(14,44,217),(14,45,330),(14,46,313),(14,47,365),(14,48,116),(14,49,277),(14,50,456),(14,51,388),(14,52,70),(14,53,0),(14,54,245),(14,55,66),(14,56,28),(14,57,481),(14,58,144),(14,59,219),(14,60,404),(14,61,291),(14,62,74),(14,63,162),(14,64,127),(14,65,243),(14,66,33),(14,67,361),(14,68,441),(14,69,188),(14,70,229),(14,71,137),(14,72,400),(14,73,473),(14,74,16),(14,75,112),(14,76,312),(14,77,416),(14,78,211),(14,79,32),(14,80,332),(14,81,429),(14,82,224),(14,83,70),(14,84,478),(14,85,179),(14,86,379),(14,87,6),(14,88,436),(14,89,60),(14,90,215),(14,91,156),(14,92,53),(14,93,130),(14,94,48),(14,95,409),(14,96,475),(14,97,30),(14,98,382),(14,99,166),(14,100,295),(14,101,54),(14,102,357),(14,103,249),(14,104,65),(14,105,140),(14,106,113),(14,107,71),(14,108,208),(14,109,133),(14,110,169),(14,111,207),(14,112,413),(14,113,219),(14,114,64),(14,115,449),(14,116,81),(14,117,314),(14,118,138),(14,119,282),(14,120,164),(14,121,415),(14,122,325),(14,123,101),(14,124,445),(14,125,305),(14,126,272),(14,127,33),(14,128,238),(14,129,183),(14,130,135),(14,131,171),(14,132,450),(14,133,283),(14,134,348),(14,135,243),(14,136,54),(14,137,14),(14,138,429),(14,139,372),(14,140,214),(14,141,148),(14,142,286),(14,143,180),(14,144,27),(14,145,122),(14,146,52),(14,147,166),(14,148,265),(14,149,411),(14,150,309),(14,151,402),(15,1,320),(15,2,483),(15,3,211),(15,4,63),(15,5,364),(15,6,49),(15,7,445),(15,8,329),(15,9,131),(15,10,169),(15,11,248),(15,12,414),(15,13,16),(15,14,26),(15,15,340),(15,16,484),(15,17,490),(15,18,150),(15,19,401),(15,20,113),(15,21,378),(15,22,3),(15,23,57),(15,24,211),(15,25,169),(15,26,348),(15,27,171),(15,28,17),(15,29,304),(15,30,22),(15,31,2),(15,32,294),(15,33,128),(15,34,351),(15,35,197),(15,36,406),(15,37,351),(15,38,58),(15,39,419),(15,40,312),(15,41,273),(15,42,274),(15,43,167),(15,44,398),(15,45,297),(15,46,424),(15,47,376),(15,48,32),(15,49,94),(15,50,356),(15,51,344),(15,52,77),(15,53,381),(15,54,13),(15,55,87),(15,56,82),(15,57,335),(15,58,2),(15,59,442),(15,60,141),(15,61,11),(15,62,166),(15,63,56),(15,64,124),(15,65,205),(15,66,409),(15,67,456),(15,68,484),(15,69,478),(15,70,70),(15,71,452),(15,72,287),(15,73,46),(15,74,142),(15,75,86),(15,76,456),(15,77,325),(15,78,471),(15,79,258),(15,80,281),(15,81,372),(15,82,392),(15,83,424),(15,84,306),(15,85,419),(15,86,315),(15,87,157),(15,88,396),(15,89,411),(15,90,387),(15,91,164),(15,92,363),(15,93,468),(15,94,443),(15,95,330),(15,96,402),(15,97,368),(15,98,376),(15,99,217),(15,100,95),(15,101,323),(15,102,104),(15,103,69),(15,104,67),(15,105,290),(15,106,83),(15,107,437),(15,108,1),(15,109,442),(15,110,430),(15,111,180),(15,112,498),(15,113,198),(15,114,30),(15,115,357),(15,116,220),(15,117,123),(15,118,21),(15,119,410),(15,120,145),(15,121,345),(15,122,346),(15,123,176),(15,124,230),(15,125,447),(15,126,232),(15,127,421),(15,128,393),(15,129,352),(15,130,332),(15,131,333),(15,132,196),(15,133,45),(15,134,441),(15,135,38),(15,136,452),(15,137,377),(15,138,442),(15,139,317),(15,140,115),(15,141,342),(15,142,281),(15,143,460),(15,144,35),(15,145,125),(15,146,484),(15,147,6),(15,148,486),(15,149,36),(15,150,333),(15,151,422),(16,1,423),(16,2,112),(16,3,200),(16,4,84),(16,5,204),(16,6,365),(16,7,80),(16,8,282),(16,9,270),(16,10,305),(16,11,216),(16,12,265),(16,13,361),(16,14,1),(16,15,179),(16,16,412),(16,17,495),(16,18,31),(16,19,199),(16,20,54),(16,21,462),(16,22,267),(16,23,287),(16,24,233),(16,25,149),(16,26,142),(16,27,231),(16,28,240),(16,29,50),(16,30,59),(16,31,424),(16,32,458),(16,33,382),(16,34,376),(16,35,272),(16,36,376),(16,37,121),(16,38,455),(16,39,362),(16,40,333),(16,41,499),(16,42,297),(16,43,111),(16,44,389),(16,45,172),(16,46,134),(16,47,416),(16,48,236),(16,49,467),(16,50,347),(16,51,190),(16,52,312),(16,53,322),(16,54,205),(16,55,172),(16,56,400),(16,57,37),(16,58,306),(16,59,467),(16,60,415),(16,61,338),(16,62,432),(16,63,89),(16,64,17),(16,65,93),(16,66,127),(16,67,200),(16,68,443),(16,69,416),(16,70,428),(16,71,307),(16,72,4),(16,73,204),(16,74,294),(16,75,88),(16,76,361),(16,77,394),(16,78,419),(16,79,138),(16,80,215),(16,81,303),(16,82,388),(16,83,57),(16,84,372),(16,85,463),(16,86,440),(16,87,415),(16,88,473),(16,89,429),(16,90,354),(16,91,222),(16,92,356),(16,93,46),(16,94,207),(16,95,122),(16,96,345),(16,97,121),(16,98,407),(16,99,380),(16,100,50),(16,101,238),(16,102,394),(16,103,138),(16,104,373),(16,105,164),(16,106,41),(16,107,187),(16,108,62),(16,109,107),(16,110,27),(16,111,498),(16,112,426),(16,113,247),(16,114,40),(16,115,285),(16,116,387),(16,117,35),(16,118,135),(16,119,418),(16,120,314),(16,121,31),(16,122,410),(16,123,129),(16,124,307),(16,125,44),(16,126,338),(16,127,467),(16,128,202),(16,129,38),(16,130,477),(16,131,116),(16,132,69),(16,133,3),(16,134,460),(16,135,132),(16,136,296),(16,137,162),(16,138,9),(16,139,285),(16,140,271),(16,141,347),(16,142,330),(16,143,493),(16,144,16),(16,145,149),(16,146,234),(16,147,429),(16,148,16),(16,149,87),(16,150,76),(16,151,338),(17,1,484),(17,2,239),(17,3,0),(17,4,25),(17,5,372),(17,6,265),(17,7,46),(17,8,349),(17,9,40),(17,10,6),(17,11,455),(17,12,216),(17,13,245),(17,14,156),(17,15,157),(17,16,298),(17,17,350),(17,18,224),(17,19,167),(17,20,15),(17,21,158),(17,22,293),(17,23,135),(17,24,372),(17,25,387),(17,26,474),(17,27,269),(17,28,334),(17,29,381),(17,30,230),(17,31,259),(17,32,391),(17,33,402),(17,34,485),(17,35,34),(17,36,377),(17,37,444),(17,38,17),(17,39,166),(17,40,250),(17,41,174),(17,42,229),(17,43,466),(17,44,294),(17,45,497),(17,46,392),(17,47,120),(17,48,487),(17,49,63),(17,50,184),(17,51,224),(17,52,463),(17,53,276),(17,54,141),(17,55,237),(17,56,136),(17,57,181),(17,58,299),(17,59,198),(17,60,439),(17,61,193),(17,62,355),(17,63,457),(17,64,98),(17,65,154),(17,66,64),(17,67,426),(17,68,142),(17,69,6),(17,70,86),(17,71,10),(17,72,426),(17,73,186),(17,74,355),(17,75,494),(17,76,345),(17,77,283),(17,78,339),(17,79,305),(17,80,7),(17,81,46),(17,82,152),(17,83,359),(17,84,364),(17,85,245),(17,86,117),(17,87,95),(17,88,239),(17,89,296),(17,90,112),(17,91,433),(17,92,308),(17,93,482),(17,94,421),(17,95,205),(17,96,469),(17,97,474),(17,98,39),(17,99,228),(17,100,15),(17,101,449),(17,102,247),(17,103,341),(17,104,219),(17,105,392),(17,106,244),(17,107,55),(17,108,121),(17,109,192),(17,110,48),(17,111,21),(17,112,451),(17,113,122),(17,114,442),(17,115,423),(17,116,28),(17,117,167),(17,118,167),(17,119,193),(17,120,373),(17,121,275),(17,122,143),(17,123,408),(17,124,35),(17,125,104),(17,126,164),(17,127,0),(17,128,21),(17,129,381),(17,130,334),(17,131,281),(17,132,415),(17,133,288),(17,134,25),(17,135,269),(17,136,239),(17,137,215),(17,138,402),(17,139,189),(17,140,444),(17,141,314),(17,142,5),(17,143,280),(17,144,33),(17,145,437),(17,146,19),(17,147,232),(17,148,491),(17,149,214),(17,150,55),(17,151,307),(18,1,114),(18,2,154),(18,3,145),(18,4,261),(18,5,471),(18,6,281),(18,7,448),(18,8,18),(18,9,401),(18,10,304),(18,11,70),(18,12,181),(18,13,470),(18,14,427),(18,15,101),(18,16,214),(18,17,158),(18,18,270),(18,19,120),(18,20,321),(18,21,464),(18,22,422),(18,23,191),(18,24,113),(18,25,68),(18,26,89),(18,27,449),(18,28,232),(18,29,115),(18,30,41),(18,31,186),(18,32,80),(18,33,286),(18,34,455),(18,35,420),(18,36,280),(18,37,455),(18,38,383),(18,39,126),(18,40,92),(18,41,23),(18,42,482),(18,43,0),(18,44,132),(18,45,237),(18,46,225),(18,47,254),(18,48,274),(18,49,362),(18,50,387),(18,51,404),(18,52,425),(18,53,276),(18,54,464),(18,55,20),(18,56,296),(18,57,331),(18,58,141),(18,59,473),(18,60,29),(18,61,432),(18,62,61),(18,63,375),(18,64,18),(18,65,256),(18,66,150),(18,67,91),(18,68,9),(18,69,66),(18,70,185),(18,71,387),(18,72,75),(18,73,377),(18,74,198),(18,75,192),(18,76,247),(18,77,441),(18,78,110),(18,79,69),(18,80,364),(18,81,464),(18,82,356),(18,83,335),(18,84,486),(18,85,224),(18,86,407),(18,87,380),(18,88,125),(18,89,456),(18,90,469),(18,91,401),(18,92,179),(18,93,128),(18,94,374),(18,95,85),(18,96,221),(18,97,66),(18,98,65),(18,99,250),(18,100,109),(18,101,168),(18,102,92),(18,103,227),(18,104,285),(18,105,348),(18,106,303),(18,107,81),(18,108,438),(18,109,68),(18,110,108),(18,111,122),(18,112,135),(18,113,264),(18,114,427),(18,115,470),(18,116,251),(18,117,372),(18,118,24),(18,119,253),(18,120,420),(18,121,286),(18,122,60),(18,123,243),(18,124,495),(18,125,222),(18,126,399),(18,127,496),(18,128,323),(18,129,95),(18,130,247),(18,131,432),(18,132,219),(18,133,409),(18,134,331),(18,135,22),(18,136,100),(18,137,238),(18,138,71),(18,139,401),(18,140,381),(18,141,0),(18,142,284),(18,143,363),(18,144,453),(18,145,500),(18,146,398),(18,147,364),(18,148,383),(18,149,479),(18,150,316),(18,151,204),(19,1,8),(19,2,73),(19,3,0),(19,4,255),(19,5,153),(19,6,70),(19,7,405),(19,8,446),(19,9,405),(19,10,375),(19,11,304),(19,12,423),(19,13,191),(19,14,64),(19,15,317),(19,16,364),(19,17,477),(19,18,346),(19,19,8),(19,20,483),(19,21,295),(19,22,236),(19,23,25),(19,24,497),(19,25,120),(19,26,417),(19,27,120),(19,28,311),(19,29,322),(19,30,285),(19,31,483),(19,32,380),(19,33,433),(19,34,455),(19,35,260),(19,36,191),(19,37,480),(19,38,88),(19,39,432),(19,40,367),(19,41,270),(19,42,70),(19,43,170),(19,44,55),(19,45,29),(19,46,107),(19,47,123),(19,48,370),(19,49,246),(19,50,410),(19,51,337),(19,52,49),(19,53,180),(19,54,432),(19,55,455),(19,56,41),(19,57,442),(19,58,273),(19,59,419),(19,60,160),(19,61,96),(19,62,415),(19,63,203),(19,64,43),(19,65,235),(19,66,199),(19,67,429),(19,68,371),(19,69,39),(19,70,21),(19,71,251),(19,72,314),(19,73,156),(19,74,223),(19,75,316),(19,76,13),(19,77,7),(19,78,497),(19,79,15),(19,80,305),(19,81,442),(19,82,31),(19,83,408),(19,84,89),(19,85,434),(19,86,341),(19,87,116),(19,88,170),(19,89,102),(19,90,55),(19,91,38),(19,92,198),(19,93,28),(19,94,206),(19,95,275),(19,96,144),(19,97,319),(19,98,262),(19,99,234),(19,100,245),(19,101,286),(19,102,53),(19,103,10),(19,104,442),(19,105,493),(19,106,446),(19,107,349),(19,108,249),(19,109,93),(19,110,493),(19,111,255),(19,112,497),(19,113,349),(19,114,217),(19,115,75),(19,116,314),(19,117,140),(19,118,496),(19,119,382),(19,120,491),(19,121,273),(19,122,91),(19,123,68),(19,124,409),(19,125,449),(19,126,432),(19,127,6),(19,128,190),(19,129,320),(19,130,317),(19,131,172),(19,132,313),(19,133,55),(19,134,395),(19,135,489),(19,136,179),(19,137,278),(19,138,75),(19,139,150),(19,140,122),(19,141,301),(19,142,425),(19,143,353),(19,144,117),(19,145,136),(19,146,309),(19,147,385),(19,148,74),(19,149,499),(19,150,286),(19,151,120),(20,1,377),(20,2,154),(20,3,341),(20,4,142),(20,5,478),(20,6,24),(20,7,297),(20,8,337),(20,9,278),(20,10,407),(20,11,34),(20,12,463),(20,13,170),(20,14,259),(20,15,364),(20,16,183),(20,17,152),(20,18,364),(20,19,280),(20,20,309),(20,21,158),(20,22,260),(20,23,6),(20,24,167),(20,25,200),(20,26,296),(20,27,3),(20,28,168),(20,29,155),(20,30,486),(20,31,199),(20,32,332),(20,33,78),(20,34,111),(20,35,110),(20,36,383),(20,37,483),(20,38,178),(20,39,88),(20,40,462),(20,41,484),(20,42,251),(20,43,25),(20,44,185),(20,45,143),(20,46,0),(20,47,51),(20,48,275),(20,49,248),(20,50,110),(20,51,85),(20,52,189),(20,53,271),(20,54,116),(20,55,11),(20,56,9),(20,57,320),(20,58,334),(20,59,404),(20,60,354),(20,61,2),(20,62,113),(20,63,43),(20,64,325),(20,65,336),(20,66,108),(20,67,106),(20,68,271),(20,69,293),(20,70,117),(20,71,247),(20,72,466),(20,73,388),(20,74,82),(20,75,74),(20,76,326),(20,77,458),(20,78,320),(20,79,330),(20,80,343),(20,81,80),(20,82,253),(20,83,62),(20,84,200),(20,85,320),(20,86,180),(20,87,150),(20,88,100),(20,89,331),(20,90,365),(20,91,350),(20,92,468),(20,93,264),(20,94,34),(20,95,287),(20,96,366),(20,97,355),(20,98,330),(20,99,421),(20,100,347),(20,101,184),(20,102,439),(20,103,328),(20,104,285),(20,105,435),(20,106,127),(20,107,104),(20,108,91),(20,109,53),(20,110,13),(20,111,258),(20,112,9),(20,113,373),(20,114,119),(20,115,498),(20,116,154),(20,117,17),(20,118,268),(20,119,376),(20,120,50),(20,121,75),(20,122,414),(20,123,365),(20,124,300),(20,125,168),(20,126,260),(20,127,135),(20,128,31),(20,129,92),(20,130,87),(20,131,384),(20,132,75),(20,133,363),(20,134,395),(20,135,231),(20,136,7),(20,137,123),(20,138,436),(20,139,282),(20,140,229),(20,141,269),(20,142,121),(20,143,449),(20,144,173),(20,145,304),(20,146,119),(20,147,191),(20,148,176),(20,149,305),(20,150,377),(20,151,330);
INSERT INTO `inventory` VALUES (1,56,92,7,4,120,48),(2,61,87,7,9,66,0),(3,99,63,1,4,295,6),(4,60,28,4,7,36,33),(5,52,89,2,6,228,44),(6,34,38,1,5,142,32),(7,47,36,3,9,196,12),(8,72,65,7,9,200,28),(9,46,67,3,3,92,34),(10,45,25,2,0,168,24),(11,13,4,2,8,197,40),(12,39,11,0,10,114,17),(13,55,87,4,6,30,20),(14,69,47,2,9,288,42),(15,70,45,10,5,76,5),(16,12,13,3,7,21,34),(17,22,44,0,2,61,26),(18,4,78,2,10,89,38),(19,1,4,0,6,277,3),(20,84,34,0,1,198,24); 
INSERT INTO `pokestops` VALUES (1,86.030281,99.089569,'1988-02-17 19:57:19'),(2,-89.619034,-10.152203,'2003-05-10 21:05:34'),(3,-39.956364,-42.832207,'1984-03-06 16:46:56'),(4,-52.346714,-11.544442,'2006-10-09 16:16:20'),(5,-4.715214,88.458328,'1986-08-21 04:22:35'),(6,-36.289207,-163.305557,'1985-09-25 04:25:44'),(7,-15.602031,67.377998,'2019-12-10 14:06:22'),(8,-34.201519,133.622482,'2015-01-20 11:14:29'),(9,-6.760847,-67.612968,'2015-10-02 11:43:53'),(10,-3.550547,-59.566566,'1975-12-29 06:48:36'),(11,-15.656240,133.269882,'1982-09-17 18:42:20'),(12,72.126556,-0.794787,'1973-06-29 11:48:00'),(13,-16.112120,-35.821609,'1977-05-16 06:42:48'),(14,-73.021263,23.181198,'1977-03-10 04:55:30'),(15,16.091022,81.266113,'1982-11-24 11:00:41'),(16,3.929885,145.698334,'1985-03-27 05:58:24'),(17,18.038095,56.423244,'1971-03-14 19:38:30'),(18,-72.135490,-100.564522,'1985-06-23 03:28:15'),(19,-75.644928,-121.652565,'1984-10-31 08:27:45'),(20,-6.359090,62.210674,'2002-02-04 10:45:31'),(21,26.206797,-132.922653,'2003-06-29 10:24:27'),(22,10.984603,72.679558,'2014-04-23 23:52:12'),(23,-7.130854,75.849136,'1984-02-22 05:52:41'),(24,-31.574581,-119.784637,'2001-08-03 01:54:45'),(25,24.948540,-84.401245,'2019-03-08 10:46:48'),(26,-21.673294,-19.434156,'1979-05-06 22:41:41'),(27,2.206775,163.832230,'1981-04-28 13:37:50'),(28,-37.003815,-32.127071,'1980-12-21 12:10:19'),(29,65.843910,121.590698,'2020-05-02 03:21:54'),(30,-45.390209,-110.729149,'2015-11-25 22:33:16'),(31,66.201515,-23.624996,'1972-07-03 03:34:32'),(32,-34.471241,61.336918,'2009-10-11 21:06:10'),(33,67.370102,-117.532372,'1973-01-15 09:24:15'),(34,-25.276093,-53.946068,'2004-04-21 22:30:40'),(35,47.598038,160.100021,'2011-06-17 09:47:12'),(36,-0.667223,30.400845,'1982-07-19 06:50:29'),(37,-35.579792,157.321167,'2013-05-03 12:49:18'),(38,89.371582,-20.503880,'1974-06-05 13:18:11'),(39,-30.659307,-148.263351,'1976-05-09 03:24:34'),(40,25.931204,86.670639,'1988-12-12 02:22:24'),(41,62.299973,-178.027557,'1992-01-30 09:22:21'),(42,-56.334770,-146.869919,'1999-08-07 21:38:23'),(43,32.749454,-18.574257,'2016-07-18 04:21:29'),(44,63.802113,-42.393997,'1980-12-27 02:07:09'),(45,74.791527,6.173710,'1999-05-10 20:27:40'),(46,71.479240,-9.686288,'1975-11-24 08:43:58'),(47,-39.002598,137.469559,'2002-10-29 12:38:38'),(48,-63.833572,-31.462776,'2011-04-08 16:09:31'),(49,-1.643405,169.446411,'1991-02-10 07:52:45'),(50,-6.521883,-169.365280,'2000-09-21 08:33:51');   


-- Выборки
-- Все "сияющие" покемоны
SELECT 
	p.name AS 'pet_name', 
	d.name 'species', 
	p.shiny
FROM 
	pokemons p JOIN pokedex d
ON 
	p.shiny = 1
	AND p.pokedex_id = d.id;

-- Все покемоны тренера 5 по боевой силе в порядке возрастания
SELECT 
	nickname AS 'trainer', 
	d.name 'pokemonss', 
	combat_power AS 'CP' 
FROM users u JOIN pokemons p JOIN pokedex d 
ON 
	u.id = p.master_id  
	AND u.id = 5 
	AND p.pokedex_id = d.id
ORDER BY 
	combat_power;

-- Все друзья тренера 18 в алфавитном порядке
SELECT 
	u.nickname AS 'friend', 
	fr.status  AS 'status' 
FROM users u JOIN friend_requests fr 
ON 
	fr.initiator_user_id = 18 
	AND fr.status = 'approved'
	AND u.id = fr.target_user_id 
ORDER BY 
	u.nickname;


-- Представления 
-- Инвентари тренеров
DROP VIEW IF EXISTS bags;
CREATE VIEW bags AS 
	SELECT   
		u.nickname AS 'trainer',
		i.berry AS 'Berries',
		i.lucky_egg AS 'Lucky Eggs',
		i.pokeball AS 'Pokeballs',
		i.potion AS 'Potions',
		i.raid_pass AS 'Raid Pass',
		i.revive AS 'Revives'
	FROM 
		users u JOIN inventory i 
	ON 
		u.id = i.user_id;

-- карточки покемонов тренера 1
DROP VIEW IF EXISTS pokemons_card1;
CREATE VIEW pokemons_card1 AS 
	SELECT 
		u.nickname AS 'Master',
		p.combat_power AS 'CP',
		p.name AS 'pokename',
		d.name AS 'spieces',
		p.hp AS 'HP',
		p.weight AS 'Weight',
		t1.name AS 'type1',
		t2.name AS 'type2',
		p.height AS 'Hight',
		pf.stardust AS 'Stardust',
		c.candies AS 'Candies',
		fm.name AS 'Fast move',
		fm.damage AS 'FM DMG',
		t3.name AS 'FM type',
		cm.name AS 'Charge move',
		cm.damage AS 'CM DMG',
		t4.name AS 'CM type'
	FROM 
		pokemons p JOIN pokedex d JOIN candies c JOIN profiles pf JOIN fast_moves fm JOIN charge_moves cm JOIN types t1 JOIN types t2 JOIN types t3 JOIN types t4 JOIN users u 
	ON
		u.id = 1
		AND c.pokedex_id = p.pokedex_id 
		AND c.user_id = p.master_id  
		AND d.id = p.pokedex_id
		AND u.id = p.master_id 
		AND pf.user_id = u.id
		AND d.first_type = t1.id
		AND d.second_type = t2.id 
		AND fm.id = p.fast_move
		AND fm.`type` = t3.id
		AND cm.id  = p.charge_move
		AND cm.`type` = t4.id;

	
	
	
	
	
	

