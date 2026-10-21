/*
* Login
*/
CREATE TABLE ROLE_USER (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE PERMISSION (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE ROLE_PERMISSION (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_role INT NOT NULL,
    id_permission INT NOT NULL,

    CONSTRAINT fk_id_role
        FOREIGN KEY (id_role)
        REFERENCES ROLE_USER(id),

    CONSTRAINT fk_id_permission
        FOREIGN KEY (id_permission)
        REFERENCES PERMISSION(id),

    CONSTRAINT uq_permission_role
        UNIQUE (id_role, id_permission)
);

CREATE TABLE USER_LOGIN (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(225) NOT NULL,
    id_role INT NOT NULL,

    CONSTRAINT fk_id_role
        FOREIGN KEY (id_role)
        REFERENCES ROLE_USER(id)
);


/*
* Paciente
*/
CREATE TABLE SERVICES (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(254) NOT NULL
);

CREATE TABLE MEDICAL_PLAN (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(254) NOT NULL
);

CREATE TABLE COVERAGE (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_medical_plan INT NOT NULL,
    id_service INT NOT NULL,

    CONSTRAINT fk_medical_plan
        FOREIGN KEY (id_medical_plan)
        REFERENCES MEDICAL_PLAN(id),

    CONSTRAINT fk_services
        FOREIGN KEY (id_service)
        REFERENCES SERVICES(id),

    CONSTRAINT uq_services_plan
        UNIQUE (id_medical_plan, id_service)
);

CREATE TABLE PATIENT (
    id VARCHAR(20) PRIMARY KEY , 
    name VARCHAR(50) NOT NULL,
    date_birth DATE NOT NULL,
    gender VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(254) NOT NULL,
    address VARCHAR(254) NOT NULL,
    id_medical_plan INT NOT NULL,
    id_user_login INT UNIQUE NOT NULL,

    CONSTRAINT fk_medical_plan
        FOREIGN KEY (id_medical_plan)
        REFERENCES  MEDICAL_PLAN(id),

    CONSTRAINT fk_user_login
        FOREIGN KEY (id_user_login)
        REFERENCES USER_LOGIN(id)
);


/*
* Empleado
*/
CREATE TABLE EMPLOYEE (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    date_birth DATE NOT NULL,
    gender VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(254) NOT NULL,
    address VARCHAR(254) NOT NULL,
    id_user_login INT UNIQUE NOT NULL,
    CONSTRAINT fk_user_login
        FOREIGN KEY (id_user_login)
        REFERENCES USER_LOGIN(id)
);

CREATE TABLE SPECIALTY (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(254) NOT NULL
);

CREATE TABLE DOCTOR (
    id_employee VARCHAR(20) PRIMARY KEY,
    professional_license VARCHAR(100) UNIQUE NOT NULL,
    id_specialty INT,

    CONSTRAINT fk_id_employee
        FOREIGN KEY (id_employee)
        REFERENCES EMPLOYEE(id),
    
    CONSTRAINT fk_id_specialty
        FOREIGN KEY (id_specialty)
        REFERENCES SPECIALTY
);


/*
* citas 
*/
CREATE TABLE SITE (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(254) NOT NULL,
    address VARCHAR(254) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

CREATE TABLE OFFICE (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(254) NOT NULL,
    floor VARCHAR(3) NOT NULL,
    id_side INT NOT NULL,

    CONSTRAINT fk_id_side
        FOREIGN KEY (id_side)
        REFERENCES SITE(id)
);

CREATE TABLE APPOIMENT (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_appointment DATE NOT NULL,
    hour_appointment TIME NOT NULL,
    status VARCHAR(30) NOT NULL,
    id_patient VARCHAR(20) NOT NULL,
    id_doctor VARCHAR(20) NOT NULL,
    id_office INT NOT NULL,

    CONSTRAINT fk_id_patient
        FOREIGN KEY (id_patient)
        REFERENCES PATIENT(id),

    CONSTRAINT fk_id_doctor
        FOREIGN KEY (id_doctor)
        REFERENCES DOCTOR(id_employee),

    CONSTRAINT fk_id_office
        FOREIGN KEY (id_office)
        REFERENCES OFFICE(id),

    CONSTRAINT uq_date_doctor
        UNIQUE (id_doctor, date_appointment, hour_appointment)
);


/*
* historial
*/
CREATE TABLE HISTORY (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    blood_type VARCHAR(5) NOT NULL,
    alergy VARCHAR(254) NOT NULL,
    family_history VARCHAR(254) NOT NULL,
    id_patient VARCHAR(20) UNIQUE NOT NULL,

    CONSTRAINT fk_id_patient
        FOREIGN KEY (id_patient)
        REFERENCES PATIENT(id)
);

CREATE TABLE HISTORY_ENTRY (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reason TEXT NOT NULL,
    description TEXT NOT NULL,
    id_history INT NOT NULL,
    id_appointment INT UNIQUE NOT NULL,


    CONSTRAINT fk_id_history
        FOREIGN KEY (id_history)
        REFERENCES HISTORY(id),

    CONSTRAINT fk_id_appointment
        FOREIGN KEY (id_appointment)
        REFERENCES APPOIMENT(id)
);

CREATE TABLE MEDICAL_ORDER (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    instructions TEXT NOT NULL,
    id_history_entry INT NOT NULL,

    CONSTRAINT fk_id_history_entry
        FOREIGN KEY (id_history_entry)
        REFERENCES HISTORY_ENTRY(id)

);

CREATE TABLE MEDICATION (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    presentation VARCHAR(50) NOT NULL,
    concentration VARCHAR(50) NOT NULL
);

CREATE TABLE ORDER_DETAIL (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dose VARCHAR(255) NOT NULL,
    frecuency VARCHAR(255) NOT NULL,
    duration VARCHAR(255) NOT NULL,
    id_medical_order INT NOT NULL,
    id_medication INT NOT NULL,

    CONSTRAINT fk_id_medical_order
        FOREIGN KEY (id_medical_order)
        REFERENCES MEDICAL_ORDER(id),
    
    CONSTRAINT fk_id_medication
        FOREIGN KEY (id_medication)
        REFERENCES MEDICATION(id),

    CONSTRAINT uq_medication_order
        UNIQUE (id_medication, id_medical_order)
);

