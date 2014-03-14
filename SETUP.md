Setup Script
============

1. Database

PostgreSQL & PostGIS
--------------------

Create new database and user in `psql` by this spec:

    CREATE DATABASE gis; \c gis
    CREATE EXTENSION postgis;
    CREATE EXTENSION fuzzystrmatch;
    CREATE EXTENSION postgis_topology;
    CREATE EXTENSION postgis_tiger_geocoder;

    CREATE USER gman PASSWORD 'whatawonderfulworld!?';
    ALTER DATABASE gis OWNER TO gman;
    GRANT ALL ON DATABASE gis TO gman;
    GRANT ALL ON ALL TABLES IN SCHEMA public TO gman;
    GRANT ALL ON ALL TABLES IN SCHEMA tiger TO gman;

Grant access to database with database's password (not by using linux user).
Edit file `/etc/postgresql/9.3/main/pg_hba.conf` and add this spec:

    local   all             gman                                    md5

Restart database server.

also run this in shell:

    psql -U gman gis -f update-rates.sql
