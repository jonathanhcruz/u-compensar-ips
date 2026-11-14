CREATE OR REPLACE PROCEDURE insert_patient(
    -- login
    p_username        VARCHAR,
    p_password        VARCHAR,
    -- paciente
    p_id              VARCHAR,
    p_name            VARCHAR,
    p_date_birth      DATE,
    p_gender          VARCHAR,
    p_phone           VARCHAR,
    p_email           VARCHAR,
    p_address         VARCHAR,
    p_medical_plan    VARCHAR, 
    -- historia clínica
    p_blood_type      VARCHAR,
    p_alergy          VARCHAR,
    p_family_history  VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_role          INT;
    v_id_medical_plan  INT;
BEGIN
    -- buscar el rol de paciente
    SELECT id INTO v_id_role
    FROM ROLE_USER
    WHERE name = 'Paciente';

    IF v_id_role IS NULL THEN
        RAISE EXCEPTION 'No existe el rol Paciente en ROLE_USER';
    END IF;

    -- buscar el plan médico por nombre
    SELECT id INTO v_id_medical_plan
    FROM MEDICAL_PLAN
    WHERE name = p_medical_plan;

    IF v_id_medical_plan IS NULL THEN
        RAISE EXCEPTION 'El plan médico "%" no existe', p_medical_plan;
    END IF;

    -- validar que el paciente y el usuario no estén registrados
    IF EXISTS (SELECT 1 FROM PATIENT WHERE id = p_id) THEN
        RAISE EXCEPTION 'Ya existe un paciente con el documento %', p_id;
    END IF;

    -- validar que el usuario no estén registrados
    IF EXISTS (SELECT 1 FROM USER_LOGIN WHERE username = p_username) THEN
        RAISE EXCEPTION 'El usuario "%" ya está en uso', p_username;
    END IF;

    -- 1. login
    INSERT INTO USER_LOGIN (username, password, id_role)
    VALUES (p_username, p_password, v_id_role);

    -- 2. paciente
    INSERT INTO PATIENT (id, name, date_birth, gender, phone, email, address, id_medical_plan, username)
    VALUES (p_id, p_name, p_date_birth, p_gender, p_phone, p_email, p_address, v_id_medical_plan, p_username);

    -- 3. historia clínica
    INSERT INTO HISTORY (blood_type, alergy, family_history, id_patient)
    VALUES (p_blood_type, p_alergy, p_family_history, p_id);

    RAISE NOTICE 'Paciente % (%) registrado correctamente', p_name, p_id;
END;
$$;

-- Actualizar un registro (validar que el id exista)

CREATE OR REPLACE PROCEDURE proc_update_patient (
    p_id              VARCHAR,
    p_phone           VARCHAR,
    p_email           VARCHAR,
    p_address         VARCHAR,
    p_medical_plan    VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_medical_plan  INT;
BEGIN
    -- validar que el paciente exista
    IF NOT EXISTS (SELECT 1 FROM PATIENT WHERE id = p_id) THEN
        RAISE EXCEPTION 'el paciente % no existe', p_id;
    END IF;

    -- buscar el plan médico por nombre
    SELECT id INTO v_id_medical_plan
    FROM MEDICAL_PLAN
    WHERE name = p_medical_plan;

    IF v_id_medical_plan IS NULL THEN
        RAISE EXCEPTION 'el plan médico "%" no existe', p_medical_plan;
    END IF;

    UPDATE PATIENT
    SET phone = p_phone,
        email = p_email,
        address = p_address,
        id_medical_plan = v_id_medical_plan
    WHERE id = p_id;

    RAISE NOTICE 'paciente % actualizado correctamente', p_id;
END;
$$;


-- Eliminar un paciente sin citas ni entradas en su historia clínica
CREATE OR REPLACE PROCEDURE proc_delete_patient (
    p_id  VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_username  VARCHAR;
BEGIN
    -- validar que el paciente exista
    SELECT username INTO v_username
    FROM PATIENT
    WHERE id = p_id;

    IF v_username IS NULL THEN
        RAISE EXCEPTION 'el paciente % no existe', p_id;
    END IF;

    -- validar que no tenga citas
    IF EXISTS (SELECT 1 FROM APPOIMENT WHERE id_patient = p_id) THEN
        RAISE EXCEPTION 'el paciente % tiene citas registradas y no se puede eliminar', p_id;
    END IF;

    -- validar que su historia clínica no tenga entradas
    IF EXISTS (
        SELECT 1
        FROM HISTORY_ENTRY
        JOIN HISTORY ON history.id = history_entry.id_history
        WHERE history.id_patient = p_id
    ) THEN
        RAISE EXCEPTION 'el paciente % tiene entradas en su historia clínica y no se puede eliminar', p_id;
    END IF;

    -- borrar en orden inverso a las llaves foráneas
    DELETE FROM HISTORY WHERE id_patient = p_id;
    DELETE FROM PATIENT WHERE id = p_id;
    DELETE FROM USER_LOGIN WHERE username = v_username;

    RAISE NOTICE 'paciente % eliminado correctamente', p_id;
END;
$$;


-- Consultas: son FUNCTION porque un PROCEDURE no devuelve filas

-- Consultar por identificador (mensaje si no existe)
CREATE OR REPLACE FUNCTION fn_get_patient_by_id (
    p_id  VARCHAR
)
RETURNS TABLE (
    patient_id    VARCHAR,
    patient_name  VARCHAR,
    date_birth    DATE,
    gender        VARCHAR,
    phone         VARCHAR,
    email         VARCHAR,
    address       VARCHAR,
    plan_name     VARCHAR,
    username      VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT patient.id, patient.name, patient.date_birth, patient.gender, patient.phone, patient.email, patient.address, medical_plan.name, patient.username
    FROM PATIENT
    JOIN MEDICAL_PLAN ON medical_plan.id = patient.id_medical_plan
    WHERE patient.id = p_id;

    -- FOUND queda en FALSE si el RETURN QUERY no devolvió filas
    IF NOT FOUND THEN
        RAISE NOTICE 'no existe un paciente con el documento %', p_id;
    END IF;
END;
$$;

-- Buscar por nombre con LIKE (palabra completa o parcial, sin importar mayúsculas)
CREATE OR REPLACE FUNCTION fn_search_patient_by_name (
    p_text  VARCHAR
)
RETURNS TABLE (
    patient_id    VARCHAR,
    patient_name  VARCHAR,
    phone         VARCHAR,
    email         VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT patient.id, patient.name, patient.phone, patient.email
    FROM PATIENT
    WHERE LOWER(patient.name) LIKE '%' || LOWER(p_text) || '%'
    ORDER BY patient.name;

    IF NOT FOUND THEN
        RAISE NOTICE 'no hay pacientes cuyo nombre contenga "%"', p_text;
    END IF;
END;
$$;

-- Listar todos ordenados alfabéticamente
CREATE OR REPLACE FUNCTION fn_list_patients ()
RETURNS TABLE (
    patient_id    VARCHAR,
    patient_name  VARCHAR,
    date_birth    DATE,
    phone         VARCHAR,
    email         VARCHAR,
    plan_name     VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT patient.id, patient.name, patient.date_birth, patient.phone, patient.email, medical_plan.name
    FROM PATIENT
    JOIN MEDICAL_PLAN ON medical_plan.id = patient.id_medical_plan
    ORDER BY patient.name ASC;
END;
$$;

-- Contar registros con COUNT
CREATE OR REPLACE FUNCTION fn_count_patients ()
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_total  INT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM PATIENT;

    RETURN v_total;
END;
$$;

-- Citas por rango de fechas
CREATE OR REPLACE FUNCTION fn_appointments_by_date_range (
    p_start  DATE,
    p_end    DATE
)
RETURNS TABLE (
    appointment_id    INT,
    date_appointment  DATE,
    hour_appointment  TIME,
    status            VARCHAR,
    cost              NUMERIC,
    patient_name      VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_start > p_end THEN
        RAISE EXCEPTION 'la fecha inicial % es mayor que la fecha final %', p_start, p_end;
    END IF;

    RETURN QUERY
    SELECT appointment.id, appointment.date_appointment, appointment.hour_appointment, appointment.status, appointment.cost, patient.name
    FROM APPOIMENT appointment
    JOIN PATIENT ON patient.id = appointment.id_patient
    WHERE appointment.date_appointment BETWEEN p_start AND p_end
    ORDER BY appointment.date_appointment, appointment.hour_appointment;

    IF NOT FOUND THEN
        RAISE NOTICE 'no hay citas entre % y %', p_start, p_end;
    END IF;
END;
$$;


-- Cálculos, reporte y regla de negocio

-- Total facturado (SUM) de citas completadas en un rango de fechas
CREATE OR REPLACE FUNCTION fn_total_cost (
    p_start  DATE,
    p_end    DATE
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total  NUMERIC;
BEGIN
    IF p_start > p_end THEN
        RAISE EXCEPTION 'la fecha inicial % es mayor que la fecha final %', p_start, p_end;
    END IF;

    -- COALESCE: si no hay citas, SUM devuelve NULL y lo convertimos en 0
    SELECT COALESCE(SUM(appointment.cost), 0) INTO v_total
    FROM APPOIMENT appointment
    WHERE appointment.status = 'completada'
      AND appointment.date_appointment BETWEEN p_start AND p_end;

    RETURN v_total;
END;
$$;

-- Costo promedio (AVG) de las citas por especialidad
CREATE OR REPLACE FUNCTION fn_average_cost_by_specialty ()
RETURNS TABLE (
    specialty_name VARCHAR,
    appointments  BIGINT,
    average_cost  NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT specialty.name, COUNT(appointment.id), ROUND(AVG(appointment.cost), 2)
    FROM APPOIMENT appointment
    JOIN DOCTOR ON doctor.id_employee = appointment.id_doctor
    JOIN SPECIALTY ON specialty.id = doctor.id_specialty
    GROUP BY specialty.name
    ORDER BY specialty.name;
END;
$$;

-- Reporte de citas con nombres (JOIN de 7 tablas)
CREATE OR REPLACE FUNCTION fn_appointment_report ()
RETURNS TABLE (
    appointment_id    INT,
    date_appointment  DATE,
    hour_appointment  TIME,
    status            VARCHAR,
    cost              NUMERIC,
    patient_name      VARCHAR,
    doctor_name       VARCHAR,
    specialty_name    VARCHAR,
    office_name       VARCHAR,
    site_name         VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT appointment.id, appointment.date_appointment, appointment.hour_appointment, appointment.status, appointment.cost,
           patient.name, employee.name, specialty.name, office.name, site.name
    FROM APPOIMENT appointment
    JOIN PATIENT ON patient.id = appointment.id_patient
    JOIN DOCTOR ON doctor.id_employee = appointment.id_doctor
    JOIN EMPLOYEE ON employee.id = doctor.id_employee
    JOIN SPECIALTY ON specialty.id = doctor.id_specialty
    JOIN OFFICE ON office.id = appointment.id_office
    JOIN SITE ON site.id = office.id_side
    ORDER BY appointment.date_appointment, appointment.hour_appointment;
END;
$$;

-- Validar si un paciente puede agendar cita con un médico
CREATE OR REPLACE PROCEDURE proc_validate_appointment (
    p_id_patient  VARCHAR,
    p_id_doctor   VARCHAR,
    p_date        DATE,
    p_hour        TIME
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_patient_exists  INT;
    v_doctor_exists   INT;
    v_doctor_busy     INT;
    v_scheduled       INT;
    v_max_scheduled   CONSTANT INT := 3;
BEGIN
    SELECT COUNT(*) INTO v_patient_exists
    FROM PATIENT
    WHERE id = p_id_patient;

    SELECT COUNT(*) INTO v_doctor_exists
    FROM DOCTOR
    WHERE id_employee = p_id_doctor;

    SELECT COUNT(*) INTO v_doctor_busy
    FROM APPOIMENT
    WHERE id_doctor = p_id_doctor
      AND date_appointment = p_date
      AND hour_appointment = p_hour
      AND status <> 'cancelada';

    SELECT COUNT(*) INTO v_scheduled
    FROM APPOIMENT
    WHERE id_patient = p_id_patient
      AND status = 'programada';

    IF v_patient_exists = 0 THEN
        RAISE NOTICE 'NO PERMITIDO: el paciente % no existe', p_id_patient;
    ELSIF v_doctor_exists = 0 THEN
        RAISE NOTICE 'NO PERMITIDO: el médico % no existe', p_id_doctor;
    ELSIF p_date < CURRENT_DATE THEN
        RAISE NOTICE 'NO PERMITIDO: la fecha % ya pasó', p_date;
    ELSIF v_doctor_busy > 0 THEN
        RAISE NOTICE 'NO PERMITIDO: el médico % ya tiene una cita el % a las %', p_id_doctor, p_date, p_hour;
    ELSIF v_scheduled >= v_max_scheduled THEN
        RAISE NOTICE 'NO PERMITIDO: el paciente % ya tiene % citas programadas (máximo %)', p_id_patient, v_scheduled, v_max_scheduled;
    ELSE
        RAISE NOTICE 'PERMITIDO: el paciente % puede agendar con el médico % el % a las %', p_id_patient, p_id_doctor, p_date, p_hour;
    END IF;
END;
$$;
