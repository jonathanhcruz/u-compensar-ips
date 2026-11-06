BEGIN;
-- se inserta un registro nuevo
INSERT INTO USER_LOGIN (username, password, id_role) VALUES
    ('test_jmcruz', 'qwertyqwerty', (SELECT id FROM ROLE_USER WHERE name = 'Médico'));

-- ver que se realizaron los registros
select ul.username from user_login ul where ul.username = 'test_jmcruz';

ROLLBACK;

-- ver que ya no estan los registros y que el rollback funciono. 
select ul.username from user_login ul where ul.username = 'test_jmcruz';
