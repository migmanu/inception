#!/bin/bash

# Start the MariaDB service
# This initializes the MariaDB server so that we can execute SQL commands.
service mariadb start

# Execute SQL commands as the root user
# This block creates a database, a user, and sets up necessary privileges.
mariadb -v -u root << EOF
  # Create the database if it doesn't already exist
  CREATE DATABASE IF NOT EXISTS $DB_NAME;

  # Create a new user with the specified username and password if it doesn't already exist
  CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';

  # Grant all privileges on the database to the new user
  GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';

  # Grant all privileges on the database to the root user for remote access
  GRANT ALL PRIVILEGES ON $DB_NAME.* TO 'root'@'%' IDENTIFIED BY '$DB_PASS_ROOT';

  # Set the password for the root user for local access
  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$DB_PASS_ROOT');
EOF

# Wait for a few seconds to ensure all commands are executed
sleep 5

# Stop the MariaDB service
# This stops the MariaDB server after the setup is complete.
service mariadb stop

# Execute any additional commands passed as arguments to the script
# This allows the script to be flexible and execute other commands if needed.
exec $@
