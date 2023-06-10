pg_dump -s -h localhost -p 5432 -U postgres -W > ./schema-only.sql
gzip -c ./schema-only.sql > ./schema-only.sql.gz
