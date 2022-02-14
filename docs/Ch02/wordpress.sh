#!/bin/bash

set -e

your_password=$(tr -dc a-z0-9A-Z < /dev/urandom | head -c 8)

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y wordpress php libapache2-mod-php mysql-server php-mysql

cat > /etc/apache2/sites-available/wordpress.conf << EOF
Alias /blog /usr/share/wordpress
<Directory /usr/share/wordpress>
    Options FollowSymLinks
    AllowOverride Limit Options FileInfo
    DirectoryIndex index.php
    Order allow,deny
    Allow from all
</Directory>
<Directory /usr/share/wordpress/wp-content>
    Options FollowSymLinks
    Order allow,deny
    Allow from all
</Directory>
EOF

a2ensite wordpress
a2enmod rewrite
service apache2 reload

echo "Creating database."
mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"

echo "Configurating privileges."
mysql -u root -e "CREATE USER IF NOT EXISTS wordpress@localhost IDENTIFIED BY '${your_password}';"
mysql -u root -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;"
mysql -u root -e "FLUSH PRIVILEGES;"

echo "${your_password}" > /root/mysql_wordpress_password.txt

cat > /etc/wordpress/config-localhost.php << EOF
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', '${your_password}');
define('DB_HOST', 'localhost');
define('DB_COLLATE', 'utf8mb4_general_ci');
define('WP_CONTENT_DIR', '/usr/share/wordpress/wp-content');
?>
EOF

service mysql start
echo "Finished!"
