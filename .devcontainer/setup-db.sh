#!/bin/bash

# Wait for MySQL to be ready
echo "Waiting for MySQL to start..."
COUNTER=0
while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    sleep 1
    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt 30 ]; then
        echo "MySQL did not become available in time"
        exit 1
    fi
done
echo "MySQL started"

# Check if the database exists
DB_EXISTS=$(mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES LIKE '$MYSQL_DATABASE';" | grep "$MYSQL_DATABASE")

if [ -z "$DB_EXISTS" ]; then
    echo "Creating database $MYSQL_DATABASE..."
    mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE $MYSQL_DATABASE;"
    echo "Database created"
fi

# Check if sample data SQL file exists
if [ -f ".devcontainer/sample-data.sql" ]; then
    echo "Loading sample data into database..."
    mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < .devcontainer/sample-data.sql
    echo "Sample data loaded"
fi

# Set up the public directory if it doesn't exist
if [ ! -d "public" ]; then
    mkdir -p public
    echo "Created public directory"
fi

# Create/update index.php if it doesn't exist
if [ ! -f "public/index.php" ]; then
    echo "<?php phpinfo(); ?>" > public/index.php
    echo "Created phpinfo page"
fi

# Create a basic database test file
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
    
    // Fetch some data
    $stmt = $conn->query("SELECT * FROM users LIMIT 5");
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
} catch(PDOException $e) {
    echo "<h1>Connection failed:</h1>";
    echo "<p>" . $e->getMessage() . "</p>";
}
EOF
echo "Created database test file"

# Set proper permissions - CRITICAL STEP
echo "Setting proper permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Restart Apache to apply changes
echo "Restarting Apache..."
service apache2 restart

echo "Setup completed successfully!"