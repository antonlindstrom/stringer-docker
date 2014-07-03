#!/bin/bash

docker build -t antonlindstrom/stringer .
docker run --name stringer_db -d postgres:9.3

sleep 10
export DB_PASSWORD=$(openssl rand -hex 20)

connect='exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -U postgres -c '

# SQL to create user and database
create_user="CREATE USER stringer WITH PASSWORD '$DB_PASSWORD';"
create_db="CREATE DATABASE stringerdb;"
grant_priv="GRANT ALL PRIVILEGES ON DATABASE stringerdb TO stringer;"

docker run --link stringer_db:postgres --rm postgres sh -c "${connect} \"${create_user}\";"
docker run --link stringer_db:postgres --rm postgres sh -c "${connect} \"${create_db}\";"
docker run --link stringer_db:postgres --rm postgres sh -c "${connect} \"${grant_priv}\";"

docker run --name stringer_web \
-e STRINGER_DATABASE_USERNAME="stringer" \
-e STRINGER_DATABASE_PASSWORD="$DB_PASSWORD" \
-e STRINGER_DATABASE="stringerdb" \
-p 5000:5000 -d \
--link stringer_db:postgres antonlindstrom/stringer
