CREATE OR REPLACE FUNCTION fn_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_record_id VARCHAR;
    v_old       JSONB;
    v_new       JSONB;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- en un INSERT solo existe NEW
        v_record_id := NEW.id::VARCHAR;
        v_new       := to_jsonb(NEW);

    ELSIF TG_OP = 'UPDATE' THEN
        -- en un UPDATE existen OLD (antes) y NEW (después)
        v_record_id := NEW.id::VARCHAR;
        v_old       := to_jsonb(OLD);
        v_new       := to_jsonb(NEW);

    ELSIF TG_OP = 'DELETE' THEN
        -- en un DELETE solo existe OLD
        v_record_id := OLD.id::VARCHAR;
        v_old       := to_jsonb(OLD);
    END IF;

    INSERT INTO AUDIT (table_name, operation, record_id, old_data, new_data)
    VALUES (TG_TABLE_NAME, TG_OP, v_record_id, v_old, v_new);

    RETURN NULL;
END;
$$;


-- auditoría tabla principal: PATIENT

-- trigger 1
DROP TRIGGER IF EXISTS trg_patient_insert ON PATIENT;
CREATE TRIGGER trg_patient_insert
AFTER INSERT ON PATIENT
FOR EACH ROW
EXECUTE FUNCTION fn_audit();

-- trigger 2
DROP TRIGGER IF EXISTS trg_patient_update ON PATIENT;
CREATE TRIGGER trg_patient_update
AFTER UPDATE ON PATIENT
FOR EACH ROW
EXECUTE FUNCTION fn_audit();

-- trigger 3
DROP TRIGGER IF EXISTS trg_patient_delete ON PATIENT;
CREATE TRIGGER trg_patient_delete
AFTER DELETE ON PATIENT
FOR EACH ROW
EXECUTE FUNCTION fn_audit();


-- auditoría tabla transaccional: APPOIMENT

-- trigger 4
DROP TRIGGER IF EXISTS trg_appointment_insert ON APPOIMENT;
CREATE TRIGGER trg_appointment_insert
AFTER INSERT ON APPOIMENT
FOR EACH ROW
EXECUTE FUNCTION fn_audit();

-- trigger 5
DROP TRIGGER IF EXISTS trg_appointment_update ON APPOIMENT;
CREATE TRIGGER trg_appointment_update
AFTER UPDATE ON APPOIMENT
FOR EACH ROW
EXECUTE FUNCTION fn_audit();

-- trigger 6
DROP TRIGGER IF EXISTS trg_appointment_delete ON APPOIMENT;
CREATE TRIGGER trg_appointment_delete
AFTER DELETE ON APPOIMENT
FOR EACH ROW
EXECUTE FUNCTION fn_audit();


-- validaciones en APPOIMENT

-- trigger 7: BEFORE INSERT (fecha pasada, status no permitido)
CREATE OR REPLACE FUNCTION fn_validate_appoiment_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.date_appointment < CURRENT_DATE THEN
        RAISE EXCEPTION 'la fecha % ya paso', NEW.date_appointment USING ERRCODE = '45000';
    ELSIF NEW.status NOT IN ('programada', 'completada', 'cancelada') THEN
        RAISE EXCEPTION 'el estado % no es valido', NEW.status USING ERRCODE = '45000';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_appoiment_before_insert ON APPOIMENT;
CREATE TRIGGER trg_appoiment_before_insert
BEFORE INSERT ON APPOIMENT
FOR EACH ROW
EXECUTE FUNCTION fn_validate_appoiment_insert();

-- trigger 8: BEFORE UPDATE (no modificar citas completadas o canceladas)
CREATE OR REPLACE FUNCTION fn_validate_appoiment_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IN ('completada', 'cancelada') THEN
        RAISE EXCEPTION 'la cita % esta % y no se puede modificar', OLD.id, OLD.status USING ERRCODE = '45000';
    ELSIF NEW.status NOT IN ('programada', 'completada', 'cancelada') THEN
        RAISE EXCEPTION 'el estado % no es valido', NEW.status USING ERRCODE = '45000';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_appoiment_before_update ON APPOIMENT;
CREATE TRIGGER trg_appoiment_before_update
BEFORE UPDATE ON APPOIMENT
FOR EACH ROW
EXECUTE FUNCTION fn_validate_appoiment_update();