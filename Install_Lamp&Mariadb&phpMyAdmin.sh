#!/bin/sh

#################################################################################################################################
# Bash script to install an AMP stack and PHPMyAdmin plus tweaks. For Debian 10 (buster) based systems.
# Written by @AamnahAkram from http://aamnah.com modified by SCHLOSSER Guilhem geds3169@gmail.com in 2020.
#
# In case of any errors (e.g. MySQL) just re-run the script. Nothing will be re-installed except for the packages with errors.
#
# The installation of PHPMyadmin requires to modify some of the files by hand (this part of code is beyond my skills)
# 1 - go to terminal, sudo nano /usr/share/phpmyadmin/config.inc.php
# 2 - search with CTRL + w and copie / paste: /* Storage database and tables */
# 	  in this section.
#
# 3 - Uncomment each line in this section by removing the slashes at the beginning of each line
#
# Next and last job manually is:
#
# 4 - Scroll down to the bottom of the file and add the following line and copie / paste: $cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';
#	  Don't forget the ";" at the end of the line.
# 5 - Exit and save by pressing CTRL + X, Y, then ENTER.
#
# SOURCE: https://www.digitalocean.com/community/tutorials/how-to-install-phpmyadmin-from-source-debian-10
#
# A big thank you to @AamnahAkram who allowed me to discover even more scripting, and digitalocean.com
#################################################################################################################################

#Define the user
$user
userhome=$(eval echo ~$user)

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

# Update packages and Upgrade system
echo -e "$Green \n Update packages and Upgrade system $Color_Off"
echo -e "$Cyan \n Updating System.. $Color_Off"
apt-get update -y && apt-get upgrade -y

# Clean old version PHP
echo -e "$Cyan \n Clean Old version PHP.. $Color_Off"
apt purge php7.0 libapache2-mod-php7.0
apt purge php7.1 libapache2-mod-php7.1
apt purge php7.2 libapache2-mod-php7.2
apt purge php7.3 libapache2-mod-php7.3

# Install AMP
echo -e "$Green \n Install AMP $Color_Off"
echo -e "$Cyan \n Installing Apache2 $Color_Off"
apt-get install apache2 apache2-utils -y

echo -e "$Cyan \n Installing source PHP from repository SURY"
apt -y install lsb-release apt-transport-https ca-certificates
echo -e "$Cyan \n Install GPG key repository SURY"
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

echo -e "$Cyan \n Add repository"
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

echo -e "$Cyan \n Upate and upgrade sourcelist"
apt-get update && apt-get upgrade -y

echo -e "$Cyan \n Installing PHP & Requirements $Color_Off"
apt-get install -y php7.4 php7.4-cli php7.4-common
apt-get install -y apache2 libapache2-mod-php7.4
apt-get install -y php7.4-fpm
apt-get install -y php7.4-mysql

# Install Mysql or Mariadb server database management system
echo -e "$Green \n Install Mysql or Mariadb server database management system. $Color_Off"
echo -e "$Red If you want to install Mysql you must modify this script and uncomment MySQL and comment out Mariadb $Color_Off"
############ MYSQL ############
#echo -e "$Cyan \n Installing MySQL $Color_Off"
#apt-get install mysql-server mysql-client libmysqlclient15.dev -y
############ Mariadb ##########
echo -e "$Cyan \n Installing Mariadb server and client libmariadbclient-dev $Color_Off"
apt-get install mariadb-server mariadb-client libmariadbclient-dev -y


# Install phpMyadmin
echo -e "$Green \n Download and install PHPMyadmin $Color_Off"
echo -e "$Cyan \n Download phpMyAdmin move /tmp folder en rename $Color_Off"
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.zip -O phpmyadmin.zip
echo -e "$Cyan \n Extract phpMyadmin $Color_Off"
unzip phpmyadmin.zip && mv phpMyAdmin-5.0.2-all-languages phpmyadmin && cp -R phpmyadmin /usr/share/
echo -e "$Cyan \n make a new directory where phpMyAdmin will store its temporary files $Color_Off"
mkdir -p /var/share/phpmyadmin/tmp
echo -e "$Cyan \n Assignment of rights to the owner $Color_Off"
chown -R www-data:www-data /var/share/phpmyadmin
echo -e "$Cyan \n Copy of the initial phpMyadmin configuration file to config.inc.php $Color_Off"
cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
sleep 2
echo -e "$Red \n The script will pause so you can note the url to be able to finish installing phpMyadmin properly $Color_Off"
sleep 5
echo -e "$Red \n At the end of the script a step will remain to be done manually, refer to: $Color_Off"
echo -e "$Red \n https://www.digitalocean.com/community/tutorials/how-to-install-phpmyadmin-from-source-debian-10 $Color_Off"
sleep 20

# Write a passphrase to secure phpMyadmin
echo -e "Red \n For what follows, be sure to record in a notebook the 32 random characters for safety $Color_Off"
Passw_COOKIE_AUTH="In between the single quotes, enter a string of 32 random character : "
read -p "In between the single quotes, enter a string of 32 random character : " Passw_COOKIE_AUTH
echo "In between the single quotes, enter a string of 32 random character : "
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
# user="USER INPUT"
read -p "In between the single quotes, enter a string of 32 random character : " Passw_COOKIE_AUTH
echo "$cfg['blowfish_secret'] = '$Passw_COOKIE_AUTH'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */" >

# Verifying install
echo -e "$Cyan \n Verifying installs $Color_Off"
apt-get install apache2 apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-php7.4 php7.4 php7.4-common php7.4-curl php7.4-dev php7.4-gd php7.4-idn php-pear php7.4-imagick php7.4-mcrypt php5-mysql php7.4-ps php7.4-pspell php5-recode php7.4-xsl php7.4-mbstring php7.4-zip php7.4-gd php7.4-cli php7.4-readline php7.4-bz2 php7.4-bcmath php7.4-intl php7.4-json php7.4-fpm mariadb-server mariadb-client libmariadbclient-dev openssl -y

## TWEAKS and Settings
# Permissions
echo -e "Green \n Change folder permission to www-data owner $Color_off"
echo -e "$Cyan \n Permissions for /var/www $Color_Off"
chown -R www-data:www-data /var/www
echo -e "$Green \n Permissions have been set $Color_Off"

# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files

echo -e "$Cyan \n Enabling Modules $Color_Off"
a2enmod rewrite
php7enmod mcryp

echo -e "$Cyan \n Your PHP Version: $Color_Off""
php -v

# We check one last time that everything is up to date
echo -e "$Cyan \n We check one last time that everything is up to date $Color_Off"
apt-get upgrade

# Restart Apache
echo -e "$Cyan \n Restarting Apache $Color_Off"
service apache2 restart

# Configure Mariadb
echo -e "$Green \n Mariadb (sorry i dont know mysql) $Color_Off"
echo -e "$Green \n run the secure script to set root password, remove test database and disable remote root user login $Color_Off"
echo -e "$Green \n Here is how to answer $Color_Off"

sleep 5

echo -e "$Green \n 1 -Enter current password for root (enter for none) $Color_Off"
echo -e "$Green \n 2 - Switch to unix_socket authentication [Y/n] y $Color_Off"
echo -e "$Green \n 3 - Change the root password? [Y/n] y --> And write it on notebook !! $Color_Off"
echo -e "$Green \n 4 - enter new password $Color_Off"
echo -e "$Green \n 5 - Remove anonymous users? [Y/n] y $Color_Off"
echo -e "$Green \n 6 - Disallow root login remotely? [Y/n] y $Color_Off"
echo -e "$Green \n 7 - Remove test database and access to it? [Y/n] y $Color_Off"
echo -e "$Green \n 8 - Reload privilege tables now? [Y/n] y $Color_Off"

sleep 2

echo -e "$Red \n It's your turn [Y/n] y $Color_Off"

sleep 1

mysql_secure_installation

sleep 2

# Create database PHMyadmin
echo -e "$Cyan \n Create an user and a database named: phpyadmin $Color_Off"
set -e

PASS=`pwgen -s 40 1`

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $1;
CREATE USER '$1'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

echo "Mariadb user created."
echo "Username:   $1"
echo "Password:   $PASS"

echo -e "$Red \n remember username and password and database name for phpmyadmin $Color_Off"

sleep 2

echo -e "$Cyan \n Configuring Apache to Serve phpMyAdmin $Color_Off"
echo -e "$Cyan \n Create a file $Color_Off"
touch /etc/apache2/conf-available/phpmyadmin.conf


echo -e "$Cyan \n Write configuration Apache for phpMyAdmin $Color_Off"
echo "# phpMyAdmin default Apache configuration

Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>
    <IfModule mod_php.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>" >> /etc/apache2/conf-available/phpmyadmin.conf

echo -e "$Cyan \n enables the specified configuration $Color_Off"

echo -e "$Cyan \n enable phpmyadmin.conf $Color_Off"
a2enconf phpmyadmin.conf
a2ensite

echo -e "$Cyan \n Restart Apache $Color_Off"
systemctl reload apache2


echo -e "$Cyan \n Securing Your PHPMyadmin see: https://www.digitalocean.com/community/tutorials/how-to-install-phpmyadmin-from-source-debian-10 $Color_Off"

sleep 10

# Create htaccess for PHPMyadmin this file defines very specific rules in a directory (public read rights, etc.)
echo -e "$Cyan \n Create htaccess this file defines very specific rules in a directory (public read rights, etc.) $Color_Off"
echo -e "$Yellow \n create htaccess" >> /usr/share/phpmyadmin/.htaccess

echo -e "$Cyan \n Write config htaccess"
echo -e "AuthType Basic
AuthName "Restricted Files"
AuthUserFile /usr/share/phpmyadmin/.htpasswd
Require valid-user" >> /usr/share/phpmyadmin/.htaccess

echo -e "$Cyan \n PHPMyadmin is now accessible by http://127.0.0.1/phpmyadmin or local_IP / phpmyadmin or public_ip / phpmyadmin $Color_Off"

sleep 2

echo -e "$Red \n You can have more information about htaccess on https://www.digitalocean.com/community/tutorials/how-to-install-phpmyadmin-from-source-debian-10 $Color_Off"

sleep 10

# Default install website
echo -e "$Red \n by default the site will be in /var/www/html/, to have a direct link like www.example.com, it will be necessary to extract the various files specific to your site (template / page html and php in this folder )$Color_Off"
echo -e "$Red \n if your want change the directory https://www.digitalocean.com/community/tutorials/how-to-move-an-apache-web-root-to-a-new-location-on-ubuntu-16-04 $Color_Off" 

sleep 2

# Create PHPINFO
echo -e "$Cyan \n Create PHPINFO, can be viewed on http://127.0.0.1/info.php or local_IP/info.php of the server, or public_IP/info.php $Color_Off"
echo -e "Create info.php inside /var/www/html/"
echo /va/www/html/info.php
echo "<?php phpinfo(); ?>" >> /var/www/html/info.php

echo -e "$Red \n That's all for this script, now all you have to do is place your files (php / html ect ..) in the folder:
/var/www/html/ then go to your PHPmyadmin to create a database and be able to start administering your: Wordress/Joomla or other CMS $Color_Off"
