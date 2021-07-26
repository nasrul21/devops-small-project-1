#!/bin/bash

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
	sudo apt-get -y install php7.4 php7.4-mcrypt php7.4-mysql
	echo "selesai menginstall php"
}

install_git() {
        echo "menginstall git"
        sudo apt-get -y install git
        echo "selesai menginstall git"
}

install_mysql() {
	echo "menginstall mysql"
	debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
	debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
	sudo apt-get install -y mysql-server
	echo "restart service mysql"
	service mysql restart
	echo "selesai menginstall mysql"
}

setup_project() {
	echo "clone repository landingpage"
	cd /var/www/html
	rm ./*
	git clone https://github.com/sdcilsy/sosial-media.git .
	echo "selesai clone repository"
	echo "import database"
	mysql -u root -p$dbpass -e "CREATE DATABASE dbsosmed;"
	mysql -u root -p$dbpass dbsosmed < dump.sql
	echo "selesai import db"

	echo "setup config php project"
	sudo sed -i -e '/$db_pass =/ s/= .*/= "'${dbpass}'";/' config.php
	sudo sed -i -e '/$db_user =/ s/= .*/= "root";/' config.php
	sudo service apache2 restart
	echo "selesai config php project"
}

install_apache
install_php
install_git
install_mysql
setup_project

exit 0
