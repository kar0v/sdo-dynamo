CREATE DATABASE "feedback_db";

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'psql_admin') THEN
        CREATE ROLE "psql_admin" LOGIN PASSWORD 'verysecurepassword';
    END IF;
END
$$;

\c feedback_db

GRANT USAGE ON SCHEMA public TO "psql_admin";
GRANT CREATE ON SCHEMA public TO "psql_admin";

GRANT ALL PRIVILEGES ON DATABASE "feedback_db" TO "psql_admin";

ALTER SCHEMA public OWNER TO "psql_admin";

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "psql_admin";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "psql_admin";
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO "psql_admin";

ALTER DEFAULT PRIVILEGES FOR ROLE "psql_admin" IN SCHEMA public GRANT ALL ON TABLES TO "psql_admin";
ALTER DEFAULT PRIVILEGES FOR ROLE "psql_admin" IN SCHEMA public GRANT ALL ON SEQUENCES TO "psql_admin";
ALTER DEFAULT PRIVILEGES FOR ROLE "psql_admin" IN SCHEMA public GRANT ALL ON FUNCTIONS TO "psql_admin";
