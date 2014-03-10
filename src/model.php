<?php

require 'database.php';

class Model {

    public function __construct($table) {
        global $db;
        $this->table = $table;
        $this->db = $db;
    }

    public function all($ret=array()) {
        $res = $this->db->query("
            SELECT name,
                   ST_AsGeoJSON(ST_FlipCoordinates(the_geom)) as geojson
            FROM   {$this->table}
        ");
        foreach ($res as $row) {
            $obj = json_decode($row['geojson']);
            $obj->name = $row['name'];
            $obj->coords = $obj->coordinates; unset($obj->coordinates);
            $ret[] = $obj;
        }
        return $ret;
    }

}

$restaurants = new Model('restaurants');
$obstacles = new Model('obstacles');
