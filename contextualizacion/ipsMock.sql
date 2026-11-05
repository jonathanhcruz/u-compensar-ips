INSERT INTO ROLE_USER (name) VALUES
    ('Administrador'),
    ('Médico'),
    ('Recepcionista'),
    ('Enfermero'),
    ('Paciente');

INSERT INTO PERMISSION (name) VALUES
    ('gestionar_usuarios'),
    ('crear_cita'),
    ('cancelar_cita'),
    ('ver_citas'),
    ('ver_historial'),
    ('editar_historial'),
    ('crear_orden_medica');

INSERT INTO ROLE_PERMISSION (id_role, id_permission) VALUES
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
    (2, 4), (2, 5), (2, 6), (2, 7),
    (3, 2), (3, 3), (3, 4),
    (4, 4), (4, 5),
    (5, 2), (5, 3), (5, 4);

INSERT INTO USER_LOGIN (username, password, id_role) VALUES
    ('lmartinez',  '$2b$10$mockhashpaciente0000000000000000000000000000000001', 5),
    ('cgomez',     '$2b$10$mockhashpaciente0000000000000000000000000000000002', 5),
    ('aruiz',      '$2b$10$mockhashpaciente0000000000000000000000000000000003', 5),
    ('jherrera',   '$2b$10$mockhashpaciente0000000000000000000000000000000004', 5),
    ('dcastro',    '$2b$10$mockhashpaciente0000000000000000000000000000000005', 5),
    ('dr.rojas',   '$2b$10$mockhashempleado0000000000000000000000000000000006', 2),
    ('dr.suarez',  '$2b$10$mockhashempleado0000000000000000000000000000000007', 2),
    ('dr.moreno',  '$2b$10$mockhashempleado0000000000000000000000000000000008', 2),
    ('dr.vargas',  '$2b$10$mockhashempleado0000000000000000000000000000000009', 2),
    ('dr.torres',  '$2b$10$mockhashempleado0000000000000000000000000000000010', 2),
    ('mramirez',   '$2b$10$mockhashempleado0000000000000000000000000000000011', 3),
    ('admin',      '$2b$10$mockhashempleado0000000000000000000000000000000012', 1),
    ('pcardenas',  '$2b$10$mockhashempleado0000000000000000000000000000000013', 4);

INSERT INTO SERVICES (name) VALUES
    ('Consulta de medicina general'),
    ('Consulta especializada'),
    ('Laboratorio clínico'),
    ('Radiología'),
    ('Odontología'),
    ('Urgencias');

INSERT INTO MEDICAL_PLAN (name) VALUES
    ('Plan Básico'),
    ('Plan Plus'),
    ('Plan Premium'),
    ('Plan Familiar'),
    ('Plan Empresarial');

INSERT INTO COVERAGE (id_medical_plan, id_service) VALUES
    (1, 1), (1, 3),
    (2, 1), (2, 2), (2, 3),
    (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6),
    (4, 1), (4, 3), (4, 5),
    (5, 1), (5, 2), (5, 3), (5, 4);

INSERT INTO PATIENT (id, name, date_birth, gender, phone, email, address, id_medical_plan, username) VALUES
    ('1012345678', 'Laura Martínez',  '1990-03-15', 'Femenino',  '3001234567', 'laura.martinez@mail.com',  'Calle 45 # 12-30, Bogotá',      1, 'lmartinez'),
    ('1023456789', 'Carlos Gómez',    '1985-07-22', 'Masculino', '3109876543', 'carlos.gomez@mail.com',    'Carrera 7 # 80-15, Bogotá',     2, 'cgomez'),
    ('1034567890', 'Ana Ruiz',        '2001-11-02', 'Femenino',  '3204567890', 'ana.ruiz@mail.com',        'Avenida 68 # 23-40, Bogotá',    3, 'aruiz'),
    ('1045678901', 'Jorge Herrera',   '1972-01-30', 'Masculino', '3157654321', 'jorge.herrera@mail.com',   'Calle 100 # 15-20, Bogotá',     4, 'jherrera'),
    ('1056789012', 'Diana Castro',    '1998-05-09', 'Femenino',  '3012223344', 'diana.castro@mail.com',    'Carrera 50 # 3-25, Bogotá',     5, 'dcastro');

INSERT INTO EMPLOYEE (id, name, date_birth, gender, phone, email, address, username) VALUES
    ('79111222', 'Andrés Rojas',      '1980-04-12', 'Masculino', '3005551001', 'andres.rojas@ips.com',      'Calle 63 # 9-40, Bogotá',      'dr.rojas'),
    ('52222333', 'Paula Suárez',      '1983-09-25', 'Femenino',  '3005551002', 'paula.suarez@ips.com',      'Carrera 15 # 93-10, Bogotá',   'dr.suarez'),
    ('80333444', 'Felipe Moreno',     '1976-12-03', 'Masculino', '3005551003', 'felipe.moreno@ips.com',     'Calle 26 # 69-55, Bogotá',     'dr.moreno'),
    ('52444555', 'Natalia Vargas',    '1988-06-18', 'Femenino',  '3005551004', 'natalia.vargas@ips.com',    'Carrera 11 # 70-22, Bogotá',   'dr.vargas'),
    ('79555666', 'Ricardo Torres',    '1979-02-27', 'Masculino', '3005551005', 'ricardo.torres@ips.com',    'Calle 140 # 19-30, Bogotá',   'dr.torres'),
    ('52666777', 'María Ramírez',     '1995-08-14', 'Femenino',  '3005551006', 'maria.ramirez@ips.com',     'Carrera 30 # 45-12, Bogotá',  'mramirez'),
    ('80777888', 'Sergio López',      '1987-10-05', 'Masculino', '3005551007', 'sergio.lopez@ips.com',      'Calle 72 # 20-18, Bogotá',    'admin'),
    ('52888999', 'Patricia Cárdenas', '1992-03-21', 'Femenino',  '3005551008', 'patricia.cardenas@ips.com', 'Carrera 68 # 1-45, Bogotá',   'pcardenas');

INSERT INTO SPECIALTY (name) VALUES
    ('Medicina General'),
    ('Pediatría'),
    ('Cardiología'),
    ('Dermatología'),
    ('Ginecología');

INSERT INTO DOCTOR (id_employee, professional_license, id_specialty) VALUES
    ('79111222', 'RM-100245', 1),
    ('52222333', 'RM-100378', 2),
    ('80333444', 'RM-100512', 3),
    ('52444555', 'RM-100689', 4),
    ('79555666', 'RM-100734', 5);

INSERT INTO SITE (name, address, phone) VALUES
    ('Sede Calle 13',  'Calle 13 # 65-10, Bogotá',    '6015551000'),
    ('Sede Avenida 68', 'Avenida 68 # 49-20, Bogotá', '6015552000'),
    ('Sede Suba',      'Calle 145 # 91-19, Bogotá',   '6015553000'),
    ('Sede Kennedy',   'Avenida 1 de Mayo # 73-50, Bogotá', '6015554000'),
    ('Sede Chapinero', 'Carrera 13 # 52-25, Bogotá',  '6015555000');

INSERT INTO OFFICE (name, floor, id_side) VALUES
    ('Consultorio 101', '1', 1),
    ('Consultorio 102', '1', 1),
    ('Consultorio 201', '2', 2),
    ('Consultorio 105', '1', 3),
    ('Consultorio 301', '3', 4),
    ('Consultorio 203', '2', 5);

INSERT INTO APPOIMENT (date_appointment, hour_appointment, status, id_patient, id_doctor, id_office) VALUES
    ('2026-09-01', '08:00', 'completada', '1012345678', '79111222', 1),
    ('2026-09-02', '09:30', 'completada', '1023456789', '52222333', 2),
    ('2026-09-03', '10:00', 'completada', '1034567890', '80333444', 3),
    ('2026-09-04', '14:00', 'completada', '1045678901', '52444555', 4),
    ('2026-09-05', '15:30', 'completada', '1056789012', '79555666', 5),
    ('2026-09-10', '08:00', 'completada', '1012345678', '80333444', 3),
    ('2026-11-03', '08:00', 'programada', '1023456789', '79111222', 1),
    ('2026-11-04', '11:00', 'cancelada',  '1034567890', '52222333', 2);

INSERT INTO HISTORY (blood_type, alergy, family_history, id_patient) VALUES
    ('O+',  'Ninguna conocida', 'Padre con hipertensión',          '1012345678'),
    ('A+',  'Penicilina',       'Ninguno relevante',               '1023456789'),
    ('B-',  'Mariscos',         'Madre con diabetes tipo 2',       '1034567890'),
    ('AB+', 'Ninguna conocida', 'Abuelo con enfermedad coronaria', '1045678901'),
    ('O-',  'Ácaros del polvo', 'Ninguno relevante',               '1056789012');

INSERT INTO HISTORY_ENTRY (reason, description, id_history, id_appointment) VALUES
    ('Dolor de cabeza frecuente',  'Cefalea tensional. Se recomienda hidratación y control del estrés.',        1, 1),
    ('Control de crecimiento',     'Paciente en buen estado general. Se solicita examen de sangre de control.', 2, 2),
    ('Palpitaciones',              'Ritmo cardiaco normal en reposo. Se ordena electrocardiograma.',            3, 3),
    ('Brote en la piel',           'Dermatitis alérgica leve en antebrazos.',                                   4, 4),
    ('Control ginecológico anual', 'Examen sin hallazgos anormales.',                                           5, 5),
    ('Seguimiento de presión',     'Presión arterial levemente elevada. Se inicia tratamiento.',                1, 6);

INSERT INTO MEDICAL_ORDER (instructions, id_history_entry) VALUES
    ('Tomar el medicamento después de las comidas.',              1),
    ('Completar el tratamiento aunque desaparezcan los síntomas.', 2),
    ('Volver a control en un mes con el electrocardiograma.',     3),
    ('Evitar contacto con el alérgeno identificado.',             4),
    ('Control en un año.',                                         5),
    ('Medir la presión todos los días y anotarla.',               6);

INSERT INTO MEDICATION (name, presentation, concentration) VALUES
    ('Acetaminofén', 'Tableta',  '500 mg'),
    ('Ibuprofeno',   'Tableta',  '400 mg'),
    ('Amoxicilina',  'Cápsula',  '500 mg'),
    ('Loratadina',   'Tableta',  '10 mg'),
    ('Losartán',     'Tableta',  '50 mg'),
    ('Omeprazol',    'Cápsula',  '20 mg');

INSERT INTO ORDER_DETAIL (dose, frecuency, duration, id_medical_order, id_medication) VALUES
    ('1 tableta',  'Cada 8 horas',  '5 días',  1, 1),
    ('1 cápsula',  'En ayunas',     '5 días',  1, 6),
    ('1 cápsula',  'Cada 8 horas',  '7 días',  2, 3),
    ('1 tableta',  'Cada 24 horas', '30 días', 3, 5),
    ('1 tableta',  'Cada 24 horas', '10 días', 4, 4),
    ('1 tableta',  'Cada 12 horas', '3 días',  5, 2),
    ('1 tableta',  'Cada 24 horas', '90 días', 6, 5);

COMMIT;