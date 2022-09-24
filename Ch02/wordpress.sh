#!/bin/bash

set -eu

# Is user root?
if [ "$(id -u)" != "0" ]; then
    echo "本脚本需以 root 身份运行"
    echo "在大多数情况下，可以在你执行脚本的命令前加上 sudo 来以 root 身份运行"
    exit 1
fi

PASSWORD_FILE="/root/mysql_wordpress_password.txt"

echo "安装有关依赖：Wordpress, PHP, MySQL 与 Apache"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y wordpress php libapache2-mod-php mysql-server php-mysql

echo "在 Apache 中添加 Wordpress 站点"
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

echo "在 Apache 中启用 Wordpress 站点与 rewrite 模块，并启动 apache2"
a2ensite wordpress
a2enmod rewrite
service apache2 restart

echo "生成随机数据库密码，并保存至 $PASSWORD_FILE"
DB_PASSWORD=$(tr -dc a-z0-9A-Z < /dev/urandom | head -c 8)
echo "${DB_PASSWORD}" > "$PASSWORD_FILE"

echo "启动并创建 MySQL 数据库 wordpress"
service mysql start
mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"

echo "配置 MySQL 用户 wordpress 相关权限"
mysql -u root -e "CREATE USER IF NOT EXISTS wordpress@localhost IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;"
mysql -u root -e "FLUSH PRIVILEGES;"

echo "配置 Wordpress"
cat > /etc/wordpress/config-localhost.php << EOF
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST', 'localhost');
define('DB_COLLATE', 'utf8mb4_general_ci');
define('WP_CONTENT_DIR', '/usr/share/wordpress/wp-content');
?>
EOF

echo "已完成。使用浏览器打开 http://localhost/blog 以完成最后的配置"
