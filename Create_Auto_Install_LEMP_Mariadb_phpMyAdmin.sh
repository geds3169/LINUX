#!/bin/sh

##########################################
#
# Script made by Geds3169
#
# 13/09/2021
#
# Install LEMP stack (Nginx, MariaDB, PHP
#
# Work in Debian 10.2.0
#
##########################################

###############################
# Check user running the script
###############################

echo "This script must be run as root, it requires root identification and the creation of a user."

#######################
# Adveritssment
#######################

if [ "$(whoami)" != 'root' ]; then
echo "You are not root, This script must be run as root or sudo user."
exit 1;
fi

################################################
# collect info admin and users and database name
################################################

echo "Confirm the NAME of the ROOT (put: root) :"
read root_name

#Hidden password
echo "Enter the password of the root to update / install / manage user Mariadb :"
stty -echo
read -r root_passwd

stty echo
echo "Enter the NAME of the user who will use phpmyadmin (not the root user) :"
read user_name

echo "Enter the PASSWORD of the user who will use phpmyadmin :"
stty -echo
read user_passwd

stty echo
echo "Enter the name of the desired database CMS, exemple 'wordpress' :"
read database_name

#Add user to group web services if not exist
echo "Add user $user_name to group www-data (group web services)."
id -u $user_name &>/dev/null || useradd $user_name
sudo adduser www-data $user_name

###############
# Update system
###############

echo "Update the system and package."
sudo apt update -y
sudo apt upgrade -y
sudo apt-get install nano wget curl gnupg dnsutils openssl tree -y

#####################
# Install nginx
#####################

#fist we need to stop apache services
sudo apachectl stop

echo "Installing Nginx and activating the service at startup."
sudo apt install nginx -y
sudo systemctl enable nginx
if [[ ! "$(sudo systemctl is-active nginx.service )" =~ "active" ]]
then
        echo "Houston, we have a problem"
fi
echo "Ok nginx is installed and enabled and the version is :"
sudo nginx -v

############################
# Install PHP
############################

echo "Installing PHP 7.3 and dependencies."
sudo apt install php php-cgi php7.3-mysql php-pear php-mbstring php-gettext libapache2-mod-php php-common php-phpseclib php-mysql php-fpm -y

echo "Ok nginx is OK and the version is :"
sudo php --version

echo "If you need another extension do an extension search with this command :"
echo "apt install php7.3-<extension>"


############################
# Add rules firewall if exist
############################


echo "Search for Firewall and create rules if they exist."

#HTTP listening port (default 80)
echo "Enter the listening port of the nginx server in HTTP (default is 80, If you use several servers you will need a Nat rule and therefore another listening port) :"
read HTTP

#HTTPS listening port (default 443)
echo "Enter the listening port of the nginx server in HTTPS (default is 443, If you use several servers you will need a Nat rule and therefore another listening port) :"
read HTTPS

sudo /usr/sbin/iptables status >/dev/null 2>&1
if [ $? = 0 ]; then
        echo "Iptable firewall is running, we can create the inbound rules on ports 80 and 443."
        sudo iptables -I INPUT -p tcp --dport $HTTP -j ACCEPT
        sudo iptables -I INPUT -p tcp --dport $HTTPS -j ACCEPT
else
        echo "Iptable firewall is not running or not installed, We skip this step."
fi

if sudo systemctl status ufw.service >/dev/null; then
        echo "ufw firewall is running, we can create the inbound rule for the protocols HTTP and HTTPS."
        sudo ufw allow $HTTP
        sudo ufw allow $HTTPS
else
        echo "ufw firewall is not running or not installed."
fi

################################
# change www-data to nginx user
################################

echo "Change the owner for the directory web directory."
sudo chown www-data:www-data /var/www/html/ -R

#################
# Install Mariadb
#################

echo "Installing Mariadb and activating the service at startup."
sudo apt install mariadb-server mariadb-client -y
if [[ ! "$(sudo systemctl is-active mariadb.service )" =~ "active" ]]
then
        echo "Houston, we have a problem"
fi
sudo systemctl start mariadb
sudo systemctl enable mariadb


###############################
# Bypass secure mysql
###############################

echo "Bypass the mysql secure configuration, remove root accounts that are accessible from outside the local host, remove anonymous-user accounts, remove the test database."
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

##################################################
# Check if user and  database exist if not, create
##################################################

echo "We see if the user, database exists otherwise we create it"
set -e
mysql -u$root_name -p$root_passwd << EOF
CREATE USER IF NOT EXISTS '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
CREATE DATABASE IF NOT EXISTS $database_name;
GRANT ALL PRIVILEGES ON *.* TO '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
GRANT ALL PRIVILEGES ON $database_name.* TO '$user_name'@'localhost';
FLUSH PRIVILEGES;
EOF

#################################################
# Download phpMyAdmin / create directory / unpack
#################################################

echo "Downloading phpmyadmin lastest package from source and unpackage on the final directory web server."
wget -P Downloads https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir /var/www/html/phpmyadmin
cd Downloads
tar xvf phpMyAdmin-latest-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin

############################################################
# Create a random passphrase, see phpmyadmin blowfish_secret
############################################################

echo "It is required to enter a unique random 32 characters long string to fully use the blowfish algorithm used by phpMyAdmin, \nthus preventing the message ERROR: The configuration file now needs a secret passphrase (blowfish_secret), \n it will be auto generated by openssl." 
randomBlowfishSecret=$(openssl rand -base64 32)
sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret' |" /var/www/html/phpmyadmin/config.sample.inc.php > /var/www/html/phpmyadmin/config.inc.php

######################################
# Change permission of the config file
######################################

echo "We secure the configuration file by changing its rights"
chmod 660 /var/www/html/phpmyadmin/config.inc.php

############################
# Change owner of phpmyadmin
############################

echo "We change the owner phpmyadmin directory"
chown www-data:www-data /var/www/html/phpmyadmin -R

##########################################
# Test the website
###########################################
echo "You can now test your web server, By typing in your browser's search bar :"
echo "http://127.0.0.1:$HTTP or http://127.0.0.1:$HTTPS"
echo "Now configure NAT rule on your firewall"
echo "Protocol TCP - Source Any port Any - Destination WAN Address port 80 or 443"
echo "Redirect target IP the machine which hosts the web server and the chosen port"


##########################################
# Clean directory created during the script
###########################################

echo "Clean up downloaded files and directories created during installation" 
cd ..
rm -R  Downloads

echo "End of the script, now you can configure SSL certificate in nginx if you want, but manually ;)"

################################################################################
# Allows the user time to read the contents of the terminal before cleaning
#################################################################################
read -n 1 -r -s -p "Press any key to continue and clean prompt history for the security and quit the script..."

# this will fire after the key is pressed
echo Clean up the prompt by security"
sudo history -c
sudo history -w
sudo clear
 
echo "Work done, have a nice day"

exit 0;
