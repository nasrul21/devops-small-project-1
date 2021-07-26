#!/bin/bash

install_apache() {

	echo "mengupdate repository apt"
	sudo apt-get update
	echo "menginstall apache webserver"
	sudo apt-get -y install apache2
	echo "selesai menginstall apache"

}

install_git() {

        echo "menginstall git"
        sudo apt-get -y install git
        echo "selesai menginstall git"

}

clone_project() {
	echo "clone repository landingpage"
	cd /var/www/html
	rm ./*
	git clone https://github.com/sdcilsy/landing-page.git .
	echo "selesai clone repository"
}

install_apache
install_git
clone_project

exit 0
