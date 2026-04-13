-- Digital Library Audit System
-- Database Roles and Privileges
-- Requirements: 11.4, 11.5

-- Create library_admin role (write + read access)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'library_admin') THEN
        CREATE ROLE library_admin;
    END IF;
END
$$;

-- Create library_reader role (read-only access)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'library_reader') THEN
        CREATE ROLE library_reader;
    END IF;
END
$$;

-- Grant library_admin full DML + SELECT on all three tables
GRANT SELECT, INSERT, UPDATE, DELETE ON Books       TO library_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Students    TO library_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON IssuedBooks TO library_admin;

-- Grant library_reader SELECT only on all three tables
GRANT SELECT ON Books       TO library_reader;
GRANT SELECT ON Students    TO library_reader;
GRANT SELECT ON IssuedBooks TO library_reader;
