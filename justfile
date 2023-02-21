DB_NAME := "partitioning-demo"
SCRIPTS := "${PWD}/scripts"

db-create:
  sudo -u postgres createdb {{DB_NAME}} || true
  sudo -u postgres pwd
  psql -U postgres {{DB_NAME}} -f {{SCRIPTS}}/create-structure.sql

db-insert:
  psql -U postgres {{DB_NAME}} -f {{SCRIPTS}}/insert-data.sql

psql:
  psql -U postgres {{DB_NAME}}

db-drop:
  sudo -u postgres dropdb {{DB_NAME}}
