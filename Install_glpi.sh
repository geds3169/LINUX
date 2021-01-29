#!/bin/sh
########################
#                      #
# Install GLPI         #
# Work for Debian 10   #
#                      #
#                      #
#                      #
########################

###############################################
# collect info admin and users and database name
################################################

echo "$Green \n Confirm the NAME of the ROOT :$Color_Off"
read root_name

echo "$Green \n Enter the password of the root to update / install / manage user Mariadb :$Color_Off"
read root_passwd

echo "$Purple \n Enter the NAME of the user who will use phpmyadmin :$Color_Off"
read user_name

echo "$Purple \n Enter the PASSWORD of the user who will use phpmyadmin :$Color_Off"
read user_passwd

echo "$Yellow \n Enter the name of the desired database CMS, exemple 'wordpress' :$Color_Off"
read database_name

id -u $user_name &>/dev/null || useradd $user_name
adduser www-data $user_name

################################################
# Update APT cache and upgrade
################################################
echo "Update and upgrage apt
apt update && apt upgrade -y

################################################
# Install some tools
################################################

apt-get install nano wget curl gnupg dnsutils openssl -y

################################################
# Install Apache
################################################

eecho "Install apache"
apt install apache2 php libapache2-mod-php -y
systemctl start apache2
systemctl enable apache2
if [[ ! "$(systemctl is-active apache2.service )" =~ "active" ]]
then
        echo "Houston, we have a problem, the Apache service doesn't work"
fi
apache2 -v

################################################
# Install dependencies (PHP)
################################################

echo "Install dependencies for GLPI"
apt install php-mysqli php-mbstring php-curl php-gd php-simplexml php-intl php-ldap php-apcu php-xmlrpc php-cas php-zip php-bz2 php-ldap php-imap -y

################################################
# Add rules firewall if exist
################################################

echo "Search for Firewall and create rules if they exist"
/usr/sbin/iptables status >/dev/null 2>&1
if [ $? = 0 ]; then
        echo "Iptable firewall is running, we can create the inbound rules on ports 80 and 443"
        iptables -I INPUT -p tcp --dport 80 -j ACCEPT
        iptables -I INPUT -p tcp --dport 443 -j ACCEPT
else
        echo "Iptable firewall is not running or not installed"
fi

if systemctl status ufw.service >/dev/null; then
        echo "ufw firewall is running, we can create the inbound rule for the protocols HTTP and HTTPS"
        ufw allow http
        ufw allow https
else
        echo "ufw firewall is not running or not installed"
fi

################################################
# Install mariaDB server
################################################

echo "Installing Mariadb and activating the service at startup"
apt install mariadb-server -y
if [[ ! "$(systemctl is-active mariadb.service )" =~ "active" ]]
then
        echo "Houston, we have a problem, MariaDB server is not running"
fi
systemctl start mariadb
systemctl enable mariadb

################################################
# Bypass secure mysql
################################################

echo "Bypass the mysql secure configuration, remove root accounts that are accessible from outside the local host, remove anonymous-user accounts, remove the test database"
set -e
mysql_secure_installation << EOF
n
$root_passwd
$root_passwd
y
y
y
y
y
EOF

###################################################
# Check if user and  database exist if not, create
###################################################

echo "We see if the user, database exists otherwise we create it"
set -e
mysql -u$root_name -p$root_passwd << EOF
CREATE USER IF NOT EXISTS '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
CREATE DATABASE IF NOT EXISTS $database_name;
GRANT ALL PRIVILEGES ON *.* TO '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
GRANT ALL PRIVILEGES ON $database_name.* TO '$user_name'@'localhost';
FLUSH PRIVILEGES;
EOF

###################################################
# Create config to apache website glpi
###################################################

touch /etc/apache2/sites-available/glpi.conf
echo "<Directory /var/www/html/glpi>
Options Indexes FollowSymLinks
AllowOverride All
Require all granted
</Directory>" > /etc/apache2/sites-available/glpi.conf

a2dissite 000-default.conf
a2ensite glpi.conf

###################################################
# Download glpi and install
###################################################
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/9.5.2/glpi-9.5.2.tgz
tar -xvzf glpi-9.5.2.tgz
cp -r glpi/* /var/www/html/


###################################################
# Change owner to /var/www/html
###################################################
chown -R www-data /var/www/html

###################################################
# Restart Apache
###################################################

systemctl restart apache2

echo "And of job now you can run http://localhost/ or http://your_ip or http:domain_name for configuring the GLPI"

exit 0
