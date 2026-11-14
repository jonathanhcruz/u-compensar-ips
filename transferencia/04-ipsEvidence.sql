-- Insertar paciente (trigger 1)
CALL insert_patient('ptest', 'qwerty', '1099999999', 'Mario Prueba', '1995-06-20', 'Masculino', '3005556677',
    'mario.prueba@mail.com', 'Calle 10 # 5-20, Bogotá', 'Plan Plus', 'O+', 'Ninguna', 'Ninguno');

-- Actualizar paciente (trigger 2)
CALL proc_update_patient('1099999999', '3119998877', 'mario.nuevo@mail.com', 'Carrera 7 # 80-10, Bogotá', 'Plan Premium');

-- Consultas
SELECT * FROM fn_get_patient_by_id('1099999999');
SELECT * FROM fn_get_patient_by_id('000');
SELECT * FROM fn_search_patient_by_name('mar');
SELECT * FROM fn_list_patients();
SELECT fn_count_patients();
SELECT * FROM fn_appointments_by_date_range('2026-09-01', '2026-09-30');
SELECT fn_total_cost('2026-01-01', '2026-12-31');
SELECT * FROM fn_average_cost_by_specialty();
SELECT * FROM fn_appointment_report();

-- Validar si se puede agendar
CALL proc_validate_appointment('1099999999', '52222333', CURRENT_DATE + 30, '10:00');

-- Insertar cita (triggers 7 y 4)
INSERT INTO APPOIMENT (date_appointment, hour_appointment, status, cost, id_patient, id_doctor, id_office)
VALUES (CURRENT_DATE + 30, '09:00', 'programada', 45000, '1099999999', '79111222', 1);

-- Trigger 7: debe fallar por fecha pasada
INSERT INTO APPOIMENT (date_appointment, hour_appointment, status, cost, id_patient, id_doctor, id_office)
VALUES ('2025-01-01', '09:00', 'programada', 45000, '1099999999', '79111222', 1);

-- Modificar cita (triggers 8 y 5)
UPDATE APPOIMENT SET hour_appointment = '11:00' WHERE id_patient = '1099999999';

-- Trigger 8: debe fallar porque la cita está completada
UPDATE APPOIMENT SET status = 'programada' WHERE id = 1;

-- Eliminar cita (trigger 6) y paciente (trigger 3)
DELETE FROM APPOIMENT WHERE id_patient = '1099999999';
CALL proc_delete_patient('1099999999');

-- Auditoría
SELECT * FROM AUDIT ORDER BY id;
