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

switch ($_GET['t']) {
    case 'restaurants':
    case 'obstacles':
    case 'universities':
        $obj = new Overlay($_GET['t']);
        break;
    default:
        die(json_encode("table {$_GET['t']} not exists."));
}

exit(json_encode($obj->all()));
