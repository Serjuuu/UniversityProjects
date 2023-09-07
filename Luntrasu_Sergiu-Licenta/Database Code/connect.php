<?php
// Database credentials
$dbhost = 'localhost';
$dbuser = 'root';
$dbpass = '';
$dbname = 'database';

// Retrieve data from the HTTP request
$temperature = $_POST["temperature"];
$humidity = $_POST["humidity"];
$gas = $_POST["gas"];

// Check if data is not empty or NULL
if ($temperature === null || $humidity === null || $gas === null) {
    die("Error: Invalid data received from Arduino");
}

// Establish a connection to the MySQL database
$conn = new mysqli($dbhost, $dbuser, $dbpass, $dbname);

if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}

// Prepare the SQL statement with placeholders
$sql = "INSERT INTO dht11 (temperature, humidity) VALUES (?, ?)";

// Create a prepared statement
$stmt = $conn->prepare($sql);

if (!$stmt) {
    die("Error in prepared statement: " . $conn->error);
}

// Bind the parameters and execute the statement
$stmt->bind_param("dd", $temperature, $humidity);

if ($stmt->execute()) {
    echo "Data inserted into the database successfully";
} else {
    echo "Error: " . $stmt->error;
}

// Prepare the SQL statement for Gas_info table with placeholders
$sq2 = "INSERT INTO mq2 (gas) VALUES (?)";

// Create a prepared statement for Gas_info table
$stmt2 = $conn->prepare($sq2);

if (!$stmt2) {
    die("Error in prepared statement for Gas_info table: " . $conn->error);
}

// Bind the parameter and execute the statement for Gas_info table
$stmt2->bind_param("d", $gas);

if ($stmt2->execute()) {
    echo "Data inserted into the Gas_info table successfully<br>";
} else {
    echo "Error: " . $stmt2->error;
}

$stmt->close();
$stmt2->close();
$conn->close();
?>
