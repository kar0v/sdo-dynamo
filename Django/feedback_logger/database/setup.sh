#!/bin/bash
DB_NAME="feedback_db"
DB_USER="psql_admin"
DB_PASSWORD="${DB_SECRET}"
DB_HOST="psql.internal"
DB_PORT="5432"
POSTGRES_PASSWORD="${DB_SECRET}"
POSTGRES_USER="psql_admin"

# Function to execute a PostgreSQL command
execute_psql() {
  PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${POSTGRES_USER}" -d "$2" -c "$1"
}

# Create the user if it does not exist
execute_psql "DO \$\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USER}') THEN CREATE ROLE \"${DB_USER}\" LOGIN PASSWORD '${DB_PASSWORD}'; END IF; END \$\$;"

# Create the database if it does not exist
execute_psql "CREATE DATABASE ${DB_NAME};" postgres > /dev/null 2>&1
# Grant all privileges on the database to the user
execute_psql "GRANT USAGE ON SCHEMA public TO \"${DB_USER}\";" "${DB_NAME}"
execute_psql "GRANT CREATE ON SCHEMA public TO \"${DB_USER}\";" "${DB_NAME}"
execute_psql "GRANT ALL PRIVILEGES ON DATABASE \"${DB_NAME}\" TO \"${DB_USER}\";" "${DB_NAME}"
execute_psql "ALTER SCHEMA public OWNER TO \"${DB_USER}\";" "${DB_NAME}"
execute_psql "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"${DB_USER}\";" "${DB_NAME}"
execute_psql "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"${DB_USER}\";" "${DB_NAME}"
execute_psql "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO \"${DB_USER}\";" "${DB_NAME}"
# Grant privileges on all future objects in the database
execute_psql "ALTER DEFAULT PRIVILEGES FOR ROLE \"${DB_USER}\" IN SCHEMA public GRANT ALL ON TABLES TO \"${DB_USER}\";" "${DB_NAME}"
execute_psql "ALTER DEFAULT PRIVILEGES FOR ROLE \"${DB_USER}\" IN SCHEMA public GRANT ALL ON SEQUENCES TO \"${DB_USER}\";" "${DB_NAME}"
execute_psql "ALTER DEFAULT PRIVILEGES FOR ROLE \"${DB_USER}\" IN SCHEMA public GRANT ALL ON FUNCTIONS TO \"${DB_USER}\";" "${DB_NAME}"

echo "Database '${DB_NAME}' and user '${DB_USER}' setup complete."
PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${POSTGRES_USER}" "${DB_NAME}" -c "SELECT datname FROM pg_database where datname like '${DB_NAME}';"