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

    private function cond($cond, $val) {
        $this->sql .= ' '.$cond;
        if (array_key_exists('val', get_defined_vars())) {
            $this->binding[] = $val;
        }
        return $this;
    }

    private function get() {
        $res = $this->db->prepare($this->sql);
        $res->execute($this->binding);
        foreach ($res as $row) {
            if (isset($row['weight']) and $row['weight'] == 0) continue;
            $obj = json_decode($row['geojson']);
            $obj->gid = $row['gid'];
            $obj->name = $row['name'];
            $obj->coords = $obj->coordinates; unset($obj->coordinates);
            $obj->weight = $row['weight'];
            $ret[] = $obj;
        }
        $this->init_sql();
        return $ret ?: array();
    }

    public function all() {
        return $this->get();
    }

    public function name_like($name) {
        return $this->cond('WHERE name ILIKE ?', "%$name%")->get();
    }

    public function in_range($lower, $upper) {
        return $this->cond('WHERE weight >= ?', 100 * $lower ?: -100)
                    ->cond('AND   weight <= ?', 100 * $upper ?: +100)
                    ->cond('ORDER BY weight DESC')
                    ->get();
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


if (isset($_GET['namelike'])) {
    exit(json_encode($obj->name_like($_GET['namelike'])));
} else if (isset($_GET['lower']) or isset($_GET['upper'])) {
    exit(json_encode($obj->in_range($_GET['lower'], $_GET['upper'])));
} else {
    exit(json_encode($obj->all()));
}
