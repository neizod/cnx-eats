<?php

require 'database.php';

class Heatmap {

    public function __construct($table) {
        global $db;
        $this->table = $table;
        $this->db = $db;
    }

    public function all($ret=array()) {
        $res = $this->db->query("
            SELECT *,
                   ST_AsGeoJSON(ST_FlipCoordinates(the_geom)) as geojson
            FROM   {$this->table}
        ");
        foreach ($res as $row) {
            if ($row['PNTCNT'] == 0) continue;
            $obj = json_decode($row['geojson']);
            $obj->coords = $obj->coordinates; unset($obj->coordinates);
            $obj->weight = $row['PNTCNT'];
            $ret[] = $obj;
        }
        return $ret;
    }

}

$heatmap = new Heatmap('sample_heat');
echo json_encode($heatmap->all());
