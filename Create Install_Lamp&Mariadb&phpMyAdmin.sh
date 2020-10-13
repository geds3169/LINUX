#!/bin/sh

#################################################
# This script install a complete server Lamp
# apache + mariadb + phpmyadmin
#
# writed by geds3169   guilhemETkarine@hotmail.fr
#
# This not a perfect script but i'm not a coder
#
#################################################

######################
# Check user running the script
######################

if [ "$(whoami)" != 'root' ]; then
echo "You have to execute this script as root user"
exit 1;
fi

######################
# Customize the shell
######################

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan


#####################
# Starting the script
#####################


# Identification
####################

# first step we get the root identification, to install Mariadb. Second step we get the user identification and database name
echo -e "$Cyan \n first step we get the root identification, to install Mariadb $Color_off"
echo -n "Enter the name root user:"
read root

echo -n "Enter the password root user:"
read password

echo -e "$Cyan \n Now we define the user and password of the database (for the website) $Color_off"

echo -n "Enter name of the user:"
read user

echo -n "Enter the password user:"
read pass

echo -n "Enter name of the desired database phpmyadmin:"
read database

# Update packages and Upgrade system
echo -e "$Green \n Update packages and Upgrade system $Color_Off"
echo -e "$Green \n Updating System.. $Color_Off"
apt-get update -y && apt-get upgrade -y

# Clean old version PHP
echo -e "$Cyan \n Clean Old version PHP.. $Color_Off"
apt purge php7.0 libapache2-mod-php7.0 -y
apt purge php7.1 libapache2-mod-php7.1 -y
apt purge php7.2 libapache2-mod-php7.2 -y
apt purge php7.3 libapache2-mod-php7.3 -y

# Install LAMP
echo -e "$Green \n Install LAMP $Color_Off"
apt install apache2 php libapache2-mod-php -y

# Add PHP package from SURY repository
echo -e "$Cyan \n Installing source PHP from repository SURY"
apt -y install lsb-release apt-transport-https ca-certificates
echo -e "$Cyan \n Install GPG key repository SURY"
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo -e "$Cyan \n Add repository"
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
echo -e "$Cyan \n Upate and upgrade sourcelist"
apt update && apt upgrade -y

# Install PHP package
echo -e "$Green \n Installing PHP & Requirements $Color_Off"
apt install -y php7.4 php7.4-cli php7.4-common
apt install -y apache2 libapache2-mod-php7.4
apt install -y php7.4-fpm
apt install -y php7.4-mysql
apt install -y php-curl
apt install -y php-gd
apt install -y php-json
apt install -y php-mbstring
apt install -y php-xml
apt install -y php-zip
apt install -y php-mysql
apt install -y php7.4-gmp


# Install repository and key Mariadb server database management system and client
echo -e "$Green \n Install Mysql or Mariadb server database management system for root user. $Color_Off"
apt-get install software-properties-common -y
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main'
apt update -y
apt install mariadb-server -y
apt install mariadb-client -y
apt install libmariadb-dev -y
apt install libmariadb-dev-compat -y
apt install libmariadbclient18 -y

# Configure Mariadb for root and create the user and database
echo -e "$Green \n Create an user name: $user and a database named: $database , if the database and user exist delete$Color_Off"

# Delete database and user if exist and create again
set -e
mysql -u$root -p$password << EOF
DROP USER IF EXISTS '$user'@'localhost';
DROP DATABASE IF EXISTS $database;
CREATE DATABASE $database;
CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass';
GRANT ALL PRIVILEGES ON $database.* TO '$user'@'localhost' IDENTIFIED BY '$pass';
EOF

echo -e "$Red \n remember: the login is phpmyadmin and the root password to administer phpmyadmin $Color_Off"
echo -e "$Red \n remember: the login $user and password: $pass for administer the database: $database $Color_Off"
sleep 1

# Install phpMyadmin
echo -e "$Yellow \n Download phpMyAdmin and rename, unzip and move to the good directory $Color_Off"
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.zip -O phpmyadmin.zip
echo -e "$Green \n Extract phpMyadmin $Color_Off"
unzip phpmyadmin.zip && mv phpMyAdmin-5.0.2-all-languages phpmyadmin && cp -R phpmyadmin /usr/share/
echo -e "$Green \n make a new directory where phpMyAdmin will store its temporary files $Color_Off"
mkdir -p /var/share/phpmyadmin/tmp
echo -e "$Cyan \n Assignment of rights to the owner $Color_Off"
chown -R www-data:www-data /var/share/phpmyadmin

echo -e "$Cyan \n Clean folder removing zip downloaded $Color_Off"
rm -R -f  phpmyadmin
rm -f phpmyadmin.zip

echo -e "$Cyan \n Change name  of the initial phpMyadmin configuration file to config.inc.php and generate random password$Color_Off"
# Write a passphrase to secure phpMyadmin
randomBlowfishSecret=$(openssl rand -base64 32)
sed -e "s|cfg\['blowfish_secret'\] = ''|cfg[blowfish_secret'] = '$randoBlowfishSecret'|" /usr/share/phpmyadmin/config.sample.inc.php

# Verifying install
echo -e "$Green \n Verifying installs and added some package needed for CMS $Color_Off"
apt install php7.4 php7.4-opcache libapache2-mod-php7.4 php7.4-mysql php7.4-curl php7.4-json php7.4-gd  php7.4-intl php7.4-xmlrpc php7.4-mbstring php7.4-xml php7.4-zip php7.4-fpm php7.4-readline -y

## TWEAKS and Settings
# Permissions
echo -e "$Purple \n Change folder permission to www-data owner $Color_off"
echo -e "$Purple \n Permissions for /var/www $Color_Off"
chown -R www-data:www-data /var/www
echo -e "$Green \n Permissions have been set $Color_Off"

# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files

echo -e "$Green \n Enabling Modules $Color_Off"
# rewrite url
echo "LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so" > /etc/apache2/mods-available/rewrite.load
# prevents possible errors due to old installations
/usr/sbin/a2dismod mpm_event
/usr/sbin/a2enmod mpm_prefork

# restart service
systemctl restart apache2

# enable modules
/usr/sbin/a2enmod rewrite
/usr/sbin/a2enmod php7.4

# restart service
service apache2 restart

# We check one last time that everything is up to date
echo -e "$Cyan \n We check one last time that everything is up to date $Color_Off"
apt update && apt upgrade -y

# Restart Apache
echo -e "$Yellow \n Restarting Apache $Color_Off"
/etc/init.d/apache2 restart

# Configure apache
echo -e "$Cyan \n Configuring Apache to Serve phpMyAdmin $Color_Off"

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

echo -e "$Green \n enables the specified configuration $Color_Off"
a2enconf phpmyadmin.conf
/usr/sbin/a2ensite *
/usr/sbin/a2enmod authz_user

echo -e "$Green \n Restart Apache $Color_Off"
systemctl reload apache2


echo -e "$Cyan \n Securing Your PHPMyadmin $Color_off"

# Create htaccess for PHPMyadmin this file defines very specific rules in a directory (public read rights, etc.)
echo -e "$Green \n Create htaccess this file defines very specific rules in a directory (public read rights, etc.) $Color_Off"
echo -e "$Green \n create htaccess $Color_Off"
echo "AuthName 'Acces protégée'
AuthType Basic
AuthUserFile '/var/www/.htpasswd'
Require valid-user"  >> /usr/share/phpmyadmin/.htaccess

echo -e "$Green \n Crypt password in the .htpasswd $Color_Off"
printf "$root:$(openssl passwd -crypt $password)\n" >> /var/www/.htpasswd
printf "$user:$(openssl passwd -crypt $pass)\n" >> /var/www/.htpasswd

echo -e "$Cyan \n Write config htaccess $Color_off"
echo -e "AuthType Basic
AuthName "Restricted Files"
AuthUserFile /usr/share/phpmyadmin/.htpasswd
Require valid-user" >> /usr/share/phpmyadmin/.htaccess

echo -e "$Red \n PHPMyadmin is now accessible by http://127.0.0.1/phpmyadmin or local_IP / phpmyadmin or public_ip / phpmyadmin $Color_Off"

# Create PHPINFO
echo -e "$Cyan \n Create PHPINFO, can be viewed on http://127.0.0.1/info.php or local_IP/info.php of the server, or public_IP/info.php $Color_Off"
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Restart apache
systemctl restart apache2

echo -e "$Purple \n Install done !, now you can install your CMS inside /var/www/html/MyCMS $Color_Off"
xdg-open http://127.0.0.1/
xdg-open http://127.0.0.1/info.php
xdg-open http://127.0.0.1/phpmyadmin




