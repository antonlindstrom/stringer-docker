#!/bin/bash

docker build -t antonlindstrom/stringer .
docker run --name stringer_db -d postgres:9.3

sleep 10
export DB_PASSWORD=$(openssl rand -hex 20)

create_user='exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -U postgres -c "CREATE USER stringer WITH PASSWORD'
password="'$DB_PASSWORD';\""
create_database='exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -U postgres -c "CREATE DATABASE stringer_live;"'
grant_privileges='exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE stringer_live TO stringer;"'

docker run --link stringer_db:postgres --rm postgres sh -c "${create_user} ${password}"
docker run --link stringer_db:postgres --rm postgres sh -c $create_database
docker run --link stringer_db:postgres --rm postgres sh -c $grant_privileges

docker run --name stringer_web \
-e STRINGER_DATABASE_USERNAME="stringer" \
-e STRINGER_DATABASE_PASSWORD="$DB_PASSWORD" \
-p 5000:5000 -d \
--link stringer_db:postgres antonlindstrom/stringer
