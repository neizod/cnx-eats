============================================
Chiang Mai Restaurants for Students Analysis
============================================

GIS Analyse Steps
=================

1. Buffer universities to create students distribution model.

  - Make 3 buffer to simulate bell-curve at sd=[1,2,3].
  - Each buffer distance is increased by 0.0085 (~1km), set seg-approx=9.

2. Each universities buffer do minus to obstacles polygon.
3. Also each universities buffer do minus its campus area.
4. Fill points into each buffer by rates of distributed students.

  - Set CRS of their layers to 4326 to view them correctly.

5. Merge points layer into one layer, a student-model-distribution layer.
6. Buffer restaurants distance of 0.001, fill with check-ins, count in grid.
7. Create polygon vector grid that cover student points, set width=0.005.

  - Also make attr weight of type decimal precision=5, will use later.

8. Count student/restaurant points in grid, compute its weight.
9. Compute student weight minus restaurant weight (database script).


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

Create new database and user in ``psql`` by this spec::

    CREATE DATABASE gis;
    CREATE USER gman PASSWORD 'whatawonderfulworld!?';
    ALTER DATABASE gis OWNER TO gman;

Grant access to database with database's password (not by using linux user).
Edit file ``/etc/postgresql/9.3/main/pg_hba.conf`` and add this spec::

    local   all             gman                                    md5

Restart database server.


Create Empty PostGIS Database
-----------------------------

Reconnect into postgresql w/ new db by command ``psql gis``::

    CREATE EXTENSION postgis;
    CREATE EXTENSION fuzzystrmatch;
    CREATE EXTENSION postgis_topology;
    CREATE EXTENSION postgis_tiger_geocoder;


Populate Database with Provided Data
------------------------------------

Load data tables from dump database::

    psql -U gman gis -f gis-data-dump.sql
