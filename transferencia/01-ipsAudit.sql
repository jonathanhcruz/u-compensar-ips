-- create audit table
CREATE TABLE IF NOT EXISTS AUDIT (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id VARCHAR(100) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    db_user VARCHAR(255) NOT NULL DEFAULT current_user,
    operation_date TIMESTAMP NOT NULL DEFAULT now(),

    CONSTRAINT check_operation
        CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- la auditoría no se puede modificar ni borrar
REVOKE UPDATE, DELETE, TRUNCATE ON AUDIT FROM ips_admin;
