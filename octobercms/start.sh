#!/bin/bash



# Download octobercms if project folder is emtpy
if [ ! "$(ls -A /webapp)" ]; then
	composer create-project october/october /webapp dev-master
	# Disable core update
	sed -i "s/'disableCoreUpdates' => false/'disableCoreUpdates' => true/g" config/cms.php
fi

# Update composer
composer update

# To ensure that mysql is ready for connect
sleep 10s

MYSQL_DB="october"
MYSQL_PASSWORD="october"
MYSQL_USERNAME="october"

# Create db if any
DBEXISTS=$(mysql -hmysql -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" --batch --skip-column-names -e "SHOW DATABASES LIKE '"$MYSQL_DB"';" | grep -q "$MYSQL_DB"; echo "$?")
if [ ! $DBEXISTS -eq 0 ];then
	mysql -hmysql -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USERNAME'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	mysql -hmysql -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE "$MYSQL_DB"; GRANT ALL PRIVILEGES ON "$MYSQL_DB".* TO '$MYSQL_USERNAME'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;"

	# Update db config
	sed -i "s/'localhost'/'mysql'/g" config/database.php
	sed -i "s/=> 'database'/=> '$MYSQL_DB'/g" config/database.php
	sed -i "s/'username'  => 'root'/'username'  => '$MYSQL_USERNAME'/g" config/database.php
	sed -i "s/'password'  => ''/'password'  => '$MYSQL_PASSWORD'/g" config/database.php
fi

php artisan october:up

/etc/init.d/hhvm start
/usr/sbin/nginx