pg_dump -s -h localhost -p 5432 -U postgres -W > ./db/schema-only/schema-only.sql
gzip -c ./db/schema-only/schema-only.sql > ./db/schema-only/schema-only.sql.gz
