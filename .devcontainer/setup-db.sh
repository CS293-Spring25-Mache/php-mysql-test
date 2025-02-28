#!/bin/bash

# Install Apache
sudo apt-get update
sudo apt-get install -y apache2

# Configure Apache
sudo a2enmod rewrite
echo "
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /workspaces/${PWD##*/}/public
    
    <Directory /workspaces/${PWD##*/}/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" | sudo tee /etc/apache2/sites-available/000-default.conf

# Create public directory if it doesn't exist
mkdir -p public

# Create a simple index.php file
echo "<?php phpinfo(); ?>" > public/index.php

# Create a database test file
cat > public/db-test.php << 'EOF'
<?php
$host = 'db';
$dbname = 'studentdb';
$user = 'student';
$pass = 'studentpass';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "<h1>Database Connection Successful!</h1>";
    
    // Test query
    $stmt = $conn->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (empty($tables)) {
        echo "<p>No tables found. Setting up sample tables...</p>";
        
        // Create users table
        $conn->exec("CREATE TABLE users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) NOT NULL UNIQUE,
            email VARCHAR(100) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )");
        
        // Insert sample data
        $conn->exec("INSERT INTO users (username, email) VALUES 
            ('student1', 'student1@example.com'),
            ('student2', 'student2@example.com'),
            ('student3', 'student3@example.com')");
            
        echo "<p>Sample tables created!</p>";
        $tables = $conn->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    }
    
    echo "<h2>Database Tables:</h2>";
    echo "<ul>";
    foreach ($tables as $table) {
        echo "<li>$table</li>";
    }
    echo "</ul>";
    
    // Show sample data from users table if it exists
    if (in_array('users', $tables)) {
        $stmt = $conn->query("SELECT * FROM users");
        echo "<h2>Sample User Data:</h2>";
        echo "<table border='1'><tr><th>ID</th><th>Username</th><th>Email</th><th>Created</th></tr>";
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            echo "<tr>";
            echo "<td>".$row['id']."</td>";
            echo "<td>".$row['username']."</td>";
            echo "<td>".$row['email']."</td>";
            echo "<td>".$row['created_at']."</td>";
            echo "</tr>";
        }
        echo "</table>";
    }
} catch(PDOException $e) {
    echo "<h1>Connection failed:</h1>";
    echo "<p>" . $e->getMessage() . "</p>";
}
EOF

# Wait for MySQL to be ready
echo "Waiting for MySQL to start..."
until mysql -h db -u student -pstudentpass -e "SELECT 1"; do
    sleep 1
done
echo "MySQL started"

# Start Apache
sudo service apache2 start

echo "Setup completed successfully!"
echo "You can now access:"
echo "  - PHP info page: http://localhost/"
echo "  - Database test: http://localhost/db-test.php"