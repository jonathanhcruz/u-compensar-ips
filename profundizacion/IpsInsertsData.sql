-- creo un usuario 
INSERT INTO USER_LOGIN (username, password, id_role) VALUES
    ('jmcruz', 'qwertyqwerty', 2);

-- insertar un empleado nuevo usadno el id del usuario creado
INSERT INTO EMPLOYEE (id, name, date_birth, gender, phone, email, address, id_user_login) VALUES
    ('98479203', 'Jonathan Henry Marino Cruz', '1995-06-26', 'Masculino', '3223056450', 'jonathan.h.cruz@live.com', 'cra 90# 4-55 Bogota', 'jmcruz');

-- el usuario ya tiene la estructura de doctor por lo que aqui solo creamos su registro de doctor
INSERT INTO DOCTOR (id_employee, professional_license, id_specialty) VALUES 
    ('98479203', 'RM-103928', null);

-- confirmar que se haya registrado la data en las tablas correspondientes
select ul.username from user_login ul where ul.username = 'jmcruz';
select e.id, e.id_user_login, e."name", e.email, e.phone, e.address from employee e where e.id = '98479203';
select d.id_employee  from doctor d where d.id_employee = '98479203';
