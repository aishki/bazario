<?php
class Database
{
    private $host = "db.cwrjwdxzomcwmtnuklmi.supabase.co";
    private $db_name = "postgres";
    private $username = "postgres";
    private $password = ""; // Set this in your environment
    private $port = "5432";
    public $conn;

    public function getConnection()
    {
        $this->conn = null;
        try {
            $this->conn = new PDO(
                "pgsql:host=" . $this->host . ";port=" . $this->port . ";dbname=" . $this->db_name . ";sslmode=require",
                $this->username,
                $this->password,
                array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
            );
            $this->conn->exec("set names utf8");
        } catch (PDOException $exception) {
            echo "Connection error: " . $exception->getMessage();
        }
        return $this->conn;
    }
}
