-- Texto + JOIN

-- Cada paciente con el nombre de su plan médico
SELECT p."name", UPPER(mp."name")
FROM patient p
JOIN medical_plan mp ON p.id_medical_plan = mp.id;

-- Cada usuario con el nombre de su rol
SELECT ul.username, LOWER(ru."name")
FROM user_login ul JOIN role_user ru ON ul.id_role = ru.id;

-- Doctores con su título Dr o Dra según su género y su especialidad
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
SELECT CONCAT(s.name, ' - ', o.name, ' (piso ', o.floor, ')') AS office_location,
       s.address
FROM office o
JOIN site s ON o.id_side = s.id
ORDER BY s.name, o.name;

-- Primer nombre de cada paciente con su tipo de sangre y alergias
SELECT SPLIT_PART(p.name, ' ', 1) AS first_name,
       h.blood_type,
       h.alergy
FROM patient p
JOIN history h ON h.id_patient = p.id;

-- Medicamentos recetados con su presentación completa y la indicación
SELECT m.name || ' ' || m.concentration || ' (' || LOWER(m.presentation) || ')' AS medication,
       od.dose,
       od.frecuency,
       od.duration
FROM order_detail od
JOIN medication m ON m.id = od.id_medication;


-- Fechas + JOIN

-- Edad de cada paciente y su plan médico, de mayor a menor
SELECT p.name,
       EXTRACT(YEAR FROM AGE(p.date_birth))::INT AS age,
       mp.name AS medical_plan
FROM patient p
JOIN medical_plan mp ON mp.id = p.id_medical_plan
ORDER BY age DESC;

-- Citas con fecha y hora en formato legible, paciente y doctor
SELECT TO_CHAR(a.date_appointment, 'DD/MM/YYYY') AS date,
       TO_CHAR(a.hour_appointment, 'HH12:MI AM') AS hour,
       p.name AS patient,
       e.name AS doctor
FROM appoiment a
JOIN patient p  ON p.id = a.id_patient
JOIN employee e ON e.id = a.id_doctor
ORDER BY a.date_appointment, a.hour_appointment;

-- Día de la semana en español de cada cita y la especialidad atendida
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

-- Citas programadas con los días que faltan, positivo, o los días vencidos, negativo
SELECT p.name AS patient,
       e.name AS doctor,
       si.name AS site,
       a.date_appointment,
       a.date_appointment - CURRENT_DATE AS days_left
FROM appoiment a
JOIN patient p  ON p.id = a.id_patient
JOIN employee e ON e.id = a.id_doctor
JOIN office o   ON o.id = a.id_office
JOIN site si    ON si.id = o.id_side
WHERE a.status = 'programada';

-- Días transcurridos desde la última cita de cada paciente
SELECT p.name,
       MAX(a.date_appointment) AS last_appointment,
       CURRENT_DATE - MAX(a.date_appointment) AS days_since
FROM patient p
JOIN appoiment a ON a.id_patient = p.id
GROUP BY p.id, p.name
ORDER BY days_since;

-- Edad del doctor y del paciente en cada cita, y la diferencia de edad entre ambos
SELECT e.name AS doctor,
       EXTRACT(YEAR FROM AGE(e.date_birth))::INT AS doctor_age,
       p.name AS patient,
       EXTRACT(YEAR FROM AGE(p.date_birth))::INT AS patient_age,
       ABS(EXTRACT(YEAR FROM AGE(e.date_birth)) - EXTRACT(YEAR FROM AGE(p.date_birth)))::INT AS age_gap
FROM appoiment a
JOIN employee e ON e.id = a.id_doctor
JOIN patient p  ON p.id = a.id_patient;


-- CASE + JOIN

-- Pacientes clasificados por grupo de edad, con su plan
SELECT p.name,
       CASE
           WHEN AGE(p.date_birth) < INTERVAL '18 years' THEN 'Menor de edad'
           WHEN AGE(p.date_birth) < INTERVAL '60 years' THEN 'Adulto'
           ELSE 'Adulto mayor'
       END AS age_group,
       mp.name AS medical_plan
FROM patient p
JOIN medical_plan mp ON mp.id = p.id_medical_plan;

-- Franja horaria mañana o tarde de cada cita con el doctor y el consultorio
SELECT a.date_appointment,
       a.hour_appointment,
       CASE
           WHEN a.hour_appointment < '12:00' THEN 'Mañana'
           ELSE 'Tarde'
       END AS time_slot,
       e.name AS doctor,
       o.name AS office
FROM appoiment a
JOIN employee e ON e.id = a.id_doctor
JOIN office o   ON o.id = a.id_office;

-- Estado de cada cita en lenguaje para el paciente
SELECT p.name AS patient,
       e.name AS doctor,
       a.date_appointment,
       CASE a.status
           WHEN 'completada' THEN 'Atendida'
           WHEN 'programada' THEN 'Pendiente por atender'
           WHEN 'cancelada'  THEN 'Cancelada'
           ELSE 'Estado desconocido'
       END AS status_description
FROM appoiment a
JOIN patient p  ON p.id = a.id_patient
JOIN employee e ON e.id = a.id_doctor;

-- Indica si el paciente tiene alergias, Sí o No, según su historia clínica
SELECT p.name,
       h.alergy,
       CASE
           WHEN h.alergy ILIKE 'ninguna%' THEN 'No'
           ELSE 'Sí'
       END AS is_allergic
FROM patient p
JOIN history h ON h.id_patient = p.id;


-- LEFT JOIN + funciones, incluye lo que no tiene relación

-- Cantidad de citas por doctor, incluyendo los que no tienen ninguna
SELECT e.name AS doctor,
       COUNT(a.id) AS total_appointments
FROM doctor d
JOIN employee e       ON e.id = d.id_employee
LEFT JOIN appoiment a ON a.id_doctor = d.id_employee
GROUP BY e.name
ORDER BY total_appointments DESC;

-- Cantidad de doctores por especialidad, con sus nombres, incluyendo especialidades vacías
SELECT s.name AS specialty,
       COUNT(d.id_employee) AS total_doctors,
       COALESCE(STRING_AGG(e.name, ', '), 'Sin doctores') AS doctors
FROM specialty s
LEFT JOIN doctor d   ON d.id_specialty = s.id
LEFT JOIN employee e ON e.id = d.id_employee
GROUP BY s.name;

-- Pacientes que nunca han tenido una cita
SELECT p.id,
       p.name,
       p.email
FROM patient p
LEFT JOIN appoiment a ON a.id_patient = p.id
WHERE a.id IS NULL;

-- Veces que se ha recetado cada medicamento, incluyendo los nunca recetados
SELECT m.name || ' ' || m.concentration AS medication,
       COUNT(od.id) AS times_prescribed
FROM medication m
LEFT JOIN order_detail od ON od.id_medication = m.id
GROUP BY m.id, m.name, m.concentration
ORDER BY times_prescribed DESC;

-- Uso de cada consultorio con su cantidad de citas, incluyendo los no usados
SELECT si.name AS site,
       o.name  AS office,
       COUNT(a.id) AS total_appointments
FROM office o
JOIN site si          ON si.id = o.id_side
LEFT JOIN appoiment a ON a.id_office = o.id
GROUP BY si.name, o.name
ORDER BY total_appointments DESC, si.name;


-- Agregaciones + JOIN

-- Cantidad de citas por especialidad, de mayor a menor
SELECT s.name AS specialty,
       COUNT(a.id) AS total_appointments
FROM appoiment a
JOIN doctor d    ON d.id_employee = a.id_doctor
JOIN specialty s ON s.id = d.id_specialty
GROUP BY s.name
ORDER BY total_appointments DESC;

-- Cantidad de pacientes y edad promedio por plan médico
SELECT mp.name AS medical_plan,
       COUNT(p.id) AS total_patients,
       ROUND(AVG(EXTRACT(YEAR FROM AGE(p.date_birth))), 1) AS average_age
FROM medical_plan mp
LEFT JOIN patient p ON p.id_medical_plan = mp.id
GROUP BY mp.name
ORDER BY total_patients DESC;

-- Resumen por sede: total de citas, completadas, programadas y canceladas
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

-- Servicios cubiertos por cada plan, en una sola línea
SELECT mp.name AS medical_plan,
       COUNT(sv.id) AS total_services,
       STRING_AGG(sv.name, ', ' ORDER BY sv.name) AS services
FROM medical_plan mp
JOIN coverage c  ON c.id_medical_plan = mp.id
JOIN services sv ON sv.id = c.id_service
GROUP BY mp.name;

-- Medicamentos que se le han recetado a cada paciente, en una sola línea
SELECT p.name AS patient,
       STRING_AGG(DISTINCT m.name, ', ') AS medications
FROM patient p
JOIN history h         ON h.id_patient = p.id
JOIN history_entry he  ON he.id_history = h.id
JOIN medical_order mo  ON mo.id_history_entry = he.id
JOIN order_detail od   ON od.id_medical_order = mo.id
JOIN medication m      ON m.id = od.id_medication
GROUP BY p.name;

-- Doctores con más de una cita
SELECT e.name AS doctor,
       COUNT(a.id) AS total_appointments
FROM appoiment a
JOIN employee e ON e.id = a.id_doctor
GROUP BY e.name
HAVING COUNT(a.id) > 1;

-- Primera y última cita de cada paciente y total de citas
SELECT p.name AS patient,
       MIN(a.date_appointment) AS first_appointment,
       MAX(a.date_appointment) AS last_appointment,
       COUNT(a.id) AS total_appointments
FROM patient p
JOIN appoiment a ON a.id_patient = p.id
GROUP BY p.name
ORDER BY total_appointments DESC;
