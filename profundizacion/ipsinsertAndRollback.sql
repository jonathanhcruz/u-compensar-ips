BEGIN;
-- se inserta un registro nuevo
INSERT INTO USER_LOGIN (username, password, id_role) VALUES
    ('jmcruz', 'qwertyqwerty', (SELECT id FROM ROLE_USER WHERE name = 'Médico'));

-- ver que se realizaron los registros
select ul.username from user_login ul where ul.username = 'jmcruz';

rollback;

-- ver que ya no estan los registros y que el rollback funciono. 
select ul.username from user_login ul where ul.username = 'jmcruz';
select e.id, e.username, e."name", e.email, e.phone, e.address from employee e where e.id = '98479203';
select d.id_employee  from doctor d where d.id_employee = '98479203';
