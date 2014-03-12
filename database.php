<?php

$db = new PDO('pgsql:
    dbname   = gis
    port     = 5433
    user     = gman
    password = whatawonderfulworld!?
') or die('could not connect database');
