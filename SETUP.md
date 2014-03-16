Requirement
===========

- Apache 2.4
- PHP 5.4
- PostgreSQL 9.3 with contrib package
- PostGIS 2.1


Setup Steps
===========

1. Prepare PostgreSQL Database
2. Create Empty PostGIS Database
3. Populate Database with Provided Data


Prepare PostgreSQL Database
---------------------------

Create new database and user in `psql` by this spec:

    CREATE DATABASE gis;
    CREATE USER gman PASSWORD 'whatawonderfulworld!?';
    ALTER DATABASE gis OWNER TO gman;

Grant access to database with database's password (not by using linux user).
Edit file `/etc/postgresql/9.3/main/pg_hba.conf` and add this spec:

    local   all             gman                                    md5

Restart database server.


Create Empty PostGIS Database
-----------------------------

Reconnect into postgresql w/ new db by command `psql gis`.

    CREATE EXTENSION postgis;
    CREATE EXTENSION fuzzystrmatch;
    CREATE EXTENSION postgis_topology;
    CREATE EXTENSION postgis_tiger_geocoder;


Populate Database with Provided Data
------------------------------------

Load data tables from dump database.

    psql -U gman gis -f gis-data-dump.sql
