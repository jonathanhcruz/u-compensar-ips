/*
* Login
*/

-- Roles en mayúscula
SELECT id, UPPER(name) AS rol
FROM ROLE_USER;

-- Longitud de cada rol
SELECT name, LENGTH(name) AS caracteres
FROM ROLE_USER
ORDER BY caracteres DESC;

-- Permisos en formato título
SELECT INITCAP(REPLACE(name, '_', ' ')) AS permiso
FROM PERMISSION;

-- Permisos por acción
SELECT SPLIT_PART(name, '_', 1) AS accion, COUNT(*) AS total
FROM PERMISSION
GROUP BY accion
ORDER BY total DESC;

-- Permisos por rol
SELECT id_role, COUNT(*) AS total_permisos
FROM ROLE_PERMISSION
GROUP BY id_role
ORDER BY id_role;

-- Permisos de cada rol en una línea
SELECT id_role, STRING_AGG(id_permission::TEXT, ', ' ORDER BY id_permission) AS permisos
FROM ROLE_PERMISSION
GROUP BY id_role
ORDER BY id_role;

-- Usuarios de médicos
SELECT username
FROM USER_LOGIN
WHERE POSITION('.' IN username) > 0;

-- Prefijo del hash
SELECT username, LEFT(password, 7) AS prefijo_hash
FROM USER_LOGIN;


/*
* Paciente
*/

-- Servicios en minúscula
SELECT id, LOWER(name) AS servicio
FROM SERVICES;

-- Servicios de consulta
SELECT name
FROM SERVICES
WHERE name ILIKE '%consulta%';

-- Planes en mayúscula, ordenados
SELECT UPPER(name) AS plan
FROM MEDICAL_PLAN
ORDER BY name;

-- Tipo de plan
SELECT id, REPLACE(name, 'Plan ', '') AS tipo
FROM MEDICAL_PLAN;

-- Servicios cubiertos por plan
SELECT id_medical_plan, COUNT(*) AS servicios_cubiertos
FROM COVERAGE
GROUP BY id_medical_plan
ORDER BY servicios_cubiertos DESC;

-- Planes con 4+ servicios
SELECT id_medical_plan, COUNT(*) AS servicios_cubiertos
FROM COVERAGE
GROUP BY id_medical_plan
HAVING COUNT(*) >= 4;

-- Edad de pacientes
SELECT name, DATE_PART('year', AGE(date_birth)) AS edad
FROM PATIENT
ORDER BY edad DESC;

-- Dominio del correo y teléfono +57
SELECT name, SPLIT_PART(email, '@', 2) AS dominio, CONCAT('+57 ', phone) AS telefono
FROM PATIENT;


/*
* Empleado
*/

-- Fecha de nacimiento DD/MM/YYYY
SELECT name, TO_CHAR(date_birth, 'DD/MM/YYYY') AS fecha_nacimiento
FROM EMPLOYEE;

-- Edad promedio, mínima y máxima
SELECT ROUND(AVG(DATE_PART('year', AGE(date_birth)))::NUMERIC, 1) AS edad_promedio,
       MIN(DATE_PART('year', AGE(date_birth))) AS edad_minima,
       MAX(DATE_PART('year', AGE(date_birth))) AS edad_maxima
FROM EMPLOYEE;

-- Especialidades en mayúscula
SELECT id, UPPER(name) AS especialidad
FROM SPECIALTY;

-- Especialidades terminadas en "logía"
SELECT name
FROM SPECIALTY
WHERE RIGHT(name, 5) = 'logía';

-- Registro médico sin "RM-"
SELECT id_employee, REPLACE(professional_license, 'RM-', '') AS numero_registro
FROM DOCTOR;

-- Especialidad o "Sin especialidad"
SELECT id_employee, COALESCE(id_specialty::TEXT, 'Sin especialidad') AS especialidad
FROM DOCTOR;


/*
* citas
*/

-- Teléfono con formato
SELECT name, CONCAT('(', LEFT(phone, 3), ') ', SUBSTRING(phone FROM 4)) AS telefono
FROM SITE;

-- Ciudad de la sede
SELECT name, TRIM(SPLIT_PART(address, ',', 2)) AS ciudad
FROM SITE;

-- Consultorios por sede
SELECT id_side, COUNT(*) AS total_consultorios
FROM OFFICE
GROUP BY id_side
ORDER BY id_side;

-- Consultorios sobre el piso 1
SELECT name, floor
FROM OFFICE
WHERE CAST(floor AS INT) > 1;

-- Citas por estado
SELECT status, COUNT(*) AS total
FROM APPOIMENT
GROUP BY status;

-- Fecha y hora legibles
SELECT id, TO_CHAR(date_appointment, 'DD/MM/YYYY') AS fecha, TO_CHAR(hour_appointment, 'HH12:MI AM') AS hora
FROM APPOIMENT;


/*
* historial
*/

-- Pacientes por tipo de sangre
SELECT blood_type, COUNT(*) AS total
FROM HISTORY
GROUP BY blood_type;

-- Pacientes con alergias
SELECT id_patient, alergy
FROM HISTORY
WHERE LOWER(alergy) <> 'ninguna conocida';

-- Resumen de la descripción
SELECT id, CONCAT(LEFT(description, 30), '...') AS resumen
FROM HISTORY_ENTRY;

-- Historiales con varias entradas
SELECT id_history, COUNT(*) AS total_entradas
FROM HISTORY_ENTRY
GROUP BY id_history
HAVING COUNT(*) > 1;

-- Longitud de las instrucciones
SELECT id, LENGTH(instructions) AS caracteres
FROM MEDICAL_ORDER
ORDER BY caracteres DESC;

-- Órdenes con control
SELECT id, instructions
FROM MEDICAL_ORDER
WHERE instructions ILIKE '%control%';

-- Nombre completo del medicamento
SELECT CONCAT(name, ' ', concentration, ' (', LOWER(presentation), ')') AS medicamento
FROM MEDICATION;

-- Concentración máxima, mínima y promedio
SELECT MAX(CAST(SPLIT_PART(concentration, ' ', 1) AS INT)) AS maxima_mg,
       MIN(CAST(SPLIT_PART(concentration, ' ', 1) AS INT)) AS minima_mg,
       ROUND(AVG(CAST(SPLIT_PART(concentration, ' ', 1) AS INT)), 2) AS promedio_mg
FROM MEDICATION;

-- Medicamentos por orden
SELECT id_medical_order, COUNT(*) AS total_medicamentos
FROM ORDER_DETAIL
GROUP BY id_medical_order
ORDER BY id_medical_order;

-- Días totales y promedio de tratamiento
SELECT SUM(CAST(SPLIT_PART(duration, ' ', 1) AS INT)) AS dias_totales,
       ROUND(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS INT)), 1) AS dias_promedio
FROM ORDER_DETAIL;

