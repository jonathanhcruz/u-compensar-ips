-- Cada paciente con el nombre de su plan médico
CREATE VIEW patient_plan AS
SELECT p."name" AS patient, UPPER(mp."name") AS medical_plan
FROM patient p
JOIN medical_plan mp ON p.id_medical_plan = mp.id;

-- Cada usuario con el nombre de su rol
CREATE VIEW user_role AS
SELECT ul.username, LOWER(ru."name") AS role
FROM user_login ul JOIN role_user ru ON ul.id_role = ru.id;

-- Doctores con su título Dr o Dra según su género y su especialidad
CREATE VIEW doctor_specialty AS
SELECT
	CASE
		WHEN LOWER(e.gender) = 'femenino' THEN  'Dra ' || e."name"
		ELSE 'Dr ' || e."name"
	END AS doctor_name,
	s."name" AS speciality
FROM employee e
JOIN doctor d ON e.id = d.id_employee
JOIN specialty s ON d.id_specialty = s.id;

-- Ubicación completa de cada consultorio: sede, consultorio y piso
CREATE VIEW office_location AS
SELECT CONCAT(s.name, ' - ', o.name, ' (piso ', o.floor, ')') AS office_location,
       s.address
FROM office o
JOIN site s ON o.id_side = s.id
ORDER BY s.name, o.name;

-- Primer nombre de cada paciente con su tipo de sangre y alergias
CREATE VIEW patient_blood AS
SELECT SPLIT_PART(p.name, ' ', 1) AS first_name,
       h.blood_type,
       h.alergy
FROM patient p
JOIN history h ON h.id_patient = p.id;

-- Medicamentos recetados con su presentación completa y la indicación
CREATE VIEW prescribed_medication AS
SELECT m.name || ' ' || m.concentration || ' (' || LOWER(m.presentation) || ')' AS medication,
       od.dose,
       od.frecuency,
       od.duration
FROM order_detail od
JOIN medication m ON m.id = od.id_medication;

-- Edad de cada paciente y su plan médico, de mayor a menor
CREATE VIEW patient_age AS
SELECT p.name,
       EXTRACT(YEAR FROM AGE(p.date_birth))::INT AS age,
       mp.name AS medical_plan
FROM patient p
JOIN medical_plan mp ON mp.id = p.id_medical_plan
ORDER BY age DESC;

-- Citas con fecha y hora en formato legible, paciente y doctor
CREATE VIEW appoiment_schedule AS
SELECT TO_CHAR(a.date_appointment, 'DD/MM/YYYY') AS date,
       TO_CHAR(a.hour_appointment, 'HH12:MI AM') AS hour,
       p.name AS patient,
       e.name AS doctor
FROM appoiment a
JOIN patient p  ON p.id = a.id_patient
JOIN employee e ON e.id = a.id_doctor
ORDER BY a.date_appointment, a.hour_appointment;

-- Día de la semana en español de cada cita y la especialidad atendida
CREATE VIEW appoiment_day AS
SELECT a.date_appointment,
       CASE EXTRACT(ISODOW FROM a.date_appointment)
           WHEN 1 THEN 'Lunes'
           WHEN 2 THEN 'Martes'
           WHEN 3 THEN 'Miércoles'
           WHEN 4 THEN 'Jueves'
           WHEN 5 THEN 'Viernes'
           WHEN 6 THEN 'Sábado'
           ELSE 'Domingo'
       END AS week_day,
       s.name AS specialty
FROM appoiment a
JOIN doctor d    ON d.id_employee = a.id_doctor
JOIN specialty s ON s.id = d.id_specialty
ORDER BY a.date_appointment;

-- Resumen por sede: total de citas, completadas, programadas y canceladas
CREATE VIEW site_summary AS
SELECT si.name AS site,
       COUNT(a.id) AS total,
       COUNT(a.id) FILTER (WHERE a.status = 'completada') AS completed,
       COUNT(a.id) FILTER (WHERE a.status = 'programada') AS scheduled,
       COUNT(a.id) FILTER (WHERE a.status = 'cancelada')  AS cancelled
FROM site si
LEFT JOIN office o    ON o.id_side = si.id
LEFT JOIN appoiment a ON a.id_office = o.id
GROUP BY si.name
ORDER BY total DESC;
