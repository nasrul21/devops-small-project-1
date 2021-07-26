#!/bin/bash

dbuser="root"
dbname="wordpress"
dbpass="root"

install_apache() {
	echo "mengupdate repository apt"
	sudo apt-get update
	echo "menginstall apache webserver"
	sudo apt-get -y install apache2
	echo "selesai menginstall apache"
}

install_php() {
	echo "persiapan setup php"
	sudo apt-get -y install software-properties-common
	sudo add-apt-repository ppa:ondrej/php
	echo "mengupdate ulang repository apt"
	sudo apt-get update
	echo "menginstall php7.4"
	sudo apt-get -y install php7.4 php7.4-mcrypt php7.4-mysql php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml php7.4-xmlrpc php7.4-soap php7.4-intl php7.4-zip
	echo "selesai menginstall php"
}

install_git() {
        echo "menginstall git"
        sudo apt-get -y install git
        echo "selesai menginstall git"
}

install_mysql() {
	echo "menginstall mysql"
	debconf-set-selections <<< "mysql-server mysql-server/root_password password $dbpass"
	debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $dbpass"
	sudo apt-get install -y mysql-server
	echo "restart service mysql"
	service mysql restart
	mysql -u root -p$dbpass -e "CREATE DATABASE $dbname;"
	echo "selesai menginstall mysql"
}

setup_project() {
	echo "setup wordpress"
	cd /tmp
	curl -O https://wordpress.org/latest.tar.gz
	tar xzvf latest.tar.gz
	cd
	touch /tmp/wordpress/.htaccess
	cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
	mkdir /tmp/wordpress/wp-content/upgrade
	mkdir /tmp/wordpress/wp-content/uploads
	rm -rf /var/www/html/*
	sudo cp -a /tmp/wordpress/. /var/www/html
	sudo chown -R www-data:www-data /var/www/html
	sudo chmod 777 /var/www/html/wp-content/uploads

	echo "konfigurasi apache & wordpress"
	config_apache="<Directory /var/www/html/>\nAllowOverride All\n</Directory>\n"

	sudo sed -i -e "/^	DocumentRoot .*/a ${config_apache}\n" /etc/apache2/sites-enabled/000-default.conf

	sed -i -e "s/database_name_here/$dbname/" /var/www/html/wp-config.php
	sed -i -e "s/username_here/$dbuser/" /var/www/html/wp-config.php
	sed -i -e "s/password_here/$dbpass/" /var/www/html/wp-config.php
	echo "selesai konfigurasi apache & wordpress"

	sudo a2enmod rewrite
	sudo service apache2 restart

	echo "setup wordpress selesai"
}

install_apache
install_php
install_git
install_mysql
setup_project

exit 0
