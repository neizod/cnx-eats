<?php

require 'database.php';

$res = $db->query('
    SELECT name,
           st_asgeojson(the_geom) as geojson
    FROM   restaurants
');

$all = array();
foreach ($res as $row) {
    $obj = json_decode($row['geojson']);
    $obj->name = $row['name'];
    $all[] = $obj;
}

echo json_encode($all);
