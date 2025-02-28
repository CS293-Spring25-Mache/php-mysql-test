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
mkdir -p public
echo "<?php phpinfo(); ?>" > public/index.php
echo "Created/updated public directory with phpinfo page"

# Set proper permissions
chown -R www-data:www-data /workspace
chmod -R 755 /workspace

# Ensure Apache is running
service apache2 restart

echo "Setup completed!"