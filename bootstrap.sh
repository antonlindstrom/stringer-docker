#!/bin/bash

docker build -t stringer .

docker run --name stringer_db -d postgres:9.3

sleep 2

DB_PASSWORD=$(openssl rand -hex 20)

docker run --link stringer_db:postgres --rm postgres sh -c "exec psql -h \"\$POSTGRES_PORT_5432_TCP_ADDR\" -U postgres -c \"CREATE USER stringer WITH PASSWORD '$DB_PASSWORD';\""
docker run --link stringer_db:postgres --rm postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -U postgres -c "CREATE DATABASE stringer_live;"'
docker run --link stringer_db:postgres --rm postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE stringer_live TO stringer;"'

docker run --name stringer_web \
-e STRINGER_DATABASE_USERNAME="stringer" \
-e STRINGER_DATABASE_PASSWORD="$DB_PASSWORD" \
-p 5000:5000 \
--link stringer_db:postgres antonlindstrom/stringer
