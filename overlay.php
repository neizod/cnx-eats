<?php


$db = new PDO('pgsql:
    dbname   = gis
    port     = 5433
    user     = gman
    password = whatawonderfulworld!?
') or die(json_encode(array('error' => 'could not connect database')));


class Overlay {

    public function __construct($table) {
        global $db;
        $this->table = $table;
        $this->db = $db;
        $this->init_sql();
    }

    private function init_sql() {
        $this->binding = array();
        $this->sql = "
            SELECT *,
                   ST_AsGeoJSON(ST_FlipCoordinates(the_geom)) as geojson
            FROM   {$this->table}
        ";
    }

    public function cond($cond, $val) {
        $this->sql .= ' '.$cond;
        $this->binding[] = $val;
        return $this;
    }

    public function get() {
        $ret = array();
        $res = $this->db->prepare($this->sql);
        $res->execute($this->binding);
        foreach ($res as $row) {
            if (isset($row['weight']) and $row['weight'] == 0) continue;
            $obj = json_decode($row['geojson']);
            $obj->name = $row['name'];
            $obj->coords = $obj->coordinates; unset($obj->coordinates);
            $obj->weight = $row['weight'];
            $ret[] = $obj;
        }
        $this->init_sql();
        return $ret;
    }

    public function all() {
        return $this->get();
    }

    public function search_name($name) {
        return $this->cond('WHERE name ILIKE ?', "%$name%")->get();
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
    case '':
        die(json_encode(array(
            'error' => 'please supply arguments and call with get method.',
            'require_arguments' => array(
                't' => 'table name to query',
            ),
            'optional_arguments' => array(
                'n' => 'search by name',
            ),
        )));
    default:
        die(json_encode(array('error' => "table '{$_GET['t']}' not exists.")));
}

if (!empty($_GET['namelike'])) {
    exit(json_encode($obj->search_name($_GET['namelike'])));
} else {
    exit(json_encode($obj->all()));
}
