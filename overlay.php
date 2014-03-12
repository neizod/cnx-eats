<?php

require 'database.php';

class Overlay {

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
            if (isset($row['weight']) and $row['weight'] == 0) continue;
            $obj = json_decode($row['geojson']);
            $obj->name = $row['name'];
            $obj->coords = $obj->coordinates; unset($obj->coordinates);
            $obj->weight = $row['weight'];
            $ret[] = $obj;
        }
        return $ret;
    }

}


switch ($_GET['t']) {
    case 'restaurants':
    case 'obstacles':
    case 'universities':
    case 'sample_heat':
    case 'rest_density':
    case 'univ_density':
        $obj = new Overlay($_GET['t']);
        break;
    default:
        die(json_encode("table {$_GET['t']} not exists."));
}

exit(json_encode($obj->all()));
