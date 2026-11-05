/*
* Registra un paciente nuevo con todo lo que necesita para existir en el sistema:
*   1. USER_LOGIN  -> credenciales de acceso con el rol 'Paciente'
*   2. PATIENT     -> datos personales y plan médico
*   3. HISTORY     -> historia clínica inicial (una por paciente)
*
*/
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

    COMMIT;
END;
$$;


/*
* Ejemplo de uso
*/
CALL insert_patient(
    'smendoza', 'qwertyqwerty',
    '1067890123', 'Sofía Mendoza', '1993-08-17', 'Femenino', '3186549870',
    'sofia.mendoza@mail.com', 'Calle 80 # 30-12, Bogotá', 'Plan Plus',
    'A-', 'Ninguna conocida', 'Madre con asma'
);

-- confirmar que se registró en las tres tablas
SELECT ul.username, r.name AS rol, p.id, p.name, mp.name AS plan, h.blood_type, h.alergy
FROM PATIENT p
JOIN USER_LOGIN ul USING (username)
JOIN ROLE_USER r ON r.id = ul.id_role
JOIN MEDICAL_PLAN mp ON mp.id = p.id_medical_plan
JOIN HISTORY h ON h.id_patient = p.id
WHERE p.id = '1067890123';
