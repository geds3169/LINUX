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

cho -e "Default \e[41m \n This script must be run as root, it requires root identification and the creation of a user."

#######################
# Adveritssment
#######################

if [ "$(whoami)" != 'root' ]; then
echo -e "Default \e[101m \n You are not root, This script must be run as root or sudo user."
exit 1;
fi

################################################
# collect info admin and users and database name
################################################

echo -e "Default \e[104m \n Confirm the NAME of the ROOT (put: root) :"
read root_name

#Hidden password
echo -e -p "Default \e[104m \n Enter the password of the root to update / install / manage user Mariadb :"
read root_passwd

echo "Default \e[104m \n Enter the NAME of the user who will use phpmyadmin (not the root user) :"
read user_name

echo "$Default \e[104m \n Enter the PASSWORD of the user who will use phpmyadmin :"
read user_passwd

echo -e "Default \e[43m \n Enter the name of the desired database CMS, exemple 'wordpress' :"
read database_name

#Add user to group web services if not exist
echo -e "Default \e[42m \n Add user $user_name to group www-data (group web services)."
id -u $user_name &>/dev/null || useradd $user_name
sudo adduser www-data $user_name

###############
# Update system
###############

echo -e "Default \e[43m Update the system and package."
sudo apt update -y
sudo apt upgrade -y
sudo apt-get install nano wget curl gnupg dnsutils openssl tree -y

#####################
# Install nginx
#####################

echo -e "Default \e[45m \n Installing Apache and activating the service at startup."
sudo apt install nginx -y
sudo systemctl status nginx
sudo systemctl enable nginx
if [[ ! "$(systemctl is-active nginx.service )" =~ "active" ]]
then
        echo -e "Default \e[104m \n Houston, we have a problem"
fi
echo -e "Default \e[42m \n Ok nginx is OK and the version is :"
sudo nginx -v

############################
# Install PHP
############################

echo -e "Default \e[45m \n Installing PHP 7.3 and dependencies."
sudo apt install php php-cgi php7.3-mysql php-pear php-mbstring php-gettext libapache2-mod-php php-common php-phpseclib php-mysql php-fpm -y

echo -e "Default \e[42m \n Ok nginx is OK and the version is :"
sudo php --version

echo -e "Default \e[42m \n If you need another extension do an extension search with this command :"
echo -e "\e[38;5;82m \n apt install php7.3-<extension>"


############################
# Add rules firewall if exist
############################


echo -e "Default \e[45m \n Search for Firewall and create rules if they exist."

#HTTP listening port (default 80)
echo -e "Default \e[104m \n Enter the listening port of the nginx server in HTTP (default is 80, If you use several servers you will need a Nat rule and therefore another listening port) :"
read HTTP

#HTTPS listening port (default 443)
echo -e "Default \e[104m \n Enter the listening port of the nginx server in HTTPS (default is 443, If you use several servers you will need a Nat rule and therefore another listening port) :"
read HTTPS

sudo /usr/sbin/iptables status >/dev/null 2>&1
if [ $? = 0 ]; then
        echo -e "Default \e[42m \n Iptable firewall is running, we can create the inbound rules on ports 80 and 443."
        sudo iptables -I INPUT -p tcp --dport $HTTP -j ACCEPT
        sudo iptables -I INPUT -p tcp --dport $HTTPS -j ACCEPT
else
        echo -e "Default \e[104mLight \n Iptable firewall is not running or not installed, We skip this step."
fi

if sudo systemctl status ufw.service >/dev/null; then
        echo -e "Default \e[42m \n ufw firewall is running, we can create the inbound rule for the protocols HTTP and HTTPS."
        sudo ufw allow http
        sudo ufw allow https
else
        echo -e "Default \e[104m \n ufw firewall is not running or not installed."
fi

################################
# change www-data to nginx user
################################

echo -e "Default \e[92m \n We Change the owner for the directory web directory."
chown www-data:www-data /var/www/html/ -R

#################
# Install Mariadb
#################

echo "$Cyan \n Installing Mariadb and activating the service at startup."
apt install mariadb-server mariadb-client -y
if [[ ! "$(systemctl is-active mariadb.service )" =~ "active" ]]
then
        echo "Houston, we have a problem"
fi
systemctl start mariadb
systemctl enable mariadb

###############################
# Bypass secure mysql
###############################

echo -e "Default \e[42m \n Bypass the mysql secure configuration, remove root accounts that are accessible from outside the local host, remove anonymous-user accounts, remove the test database."
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

echo -e "Default \e[95m \n We see if the user, database exists otherwise we create it"
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

echo -e "Default \e[95m \n Downloading phpmyadmin lastest package from source and unpackage on the final directory web server."
wget -P Downloads https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir /var/www/html/phpmyadmin
cd Downloads
tar xvf phpMyAdmin-latest-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin

############################################################
# Create a random passphrase, see phpmyadmin blowfish_secret
############################################################

echo -e "Default \e[95m \n It is required to enter a unique random 32 characters long string to fully use the blowfish algorithm used by phpMyAdmin, \nthus preventing the message ERROR: The configuration file now needs a secret passphrase (blowfish_secret), \n it will be auto generated by openssl." 
randomBlowfishSecret=$(openssl rand -base64 32)
sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret' |" /var/www/html/phpmyadmin/config.sample.inc.php > /var/www/html/phpmyadmin/config.inc.php

######################################
# Change permission of the config file
######################################

echo -e "Default \e[95m \n We secure the configuration file by changing its rights"
chmod 660 /var/www/html/phpmyadmin/config.inc.php

############################
# Change owner of phpmyadmin
############################

echo -e "Default \e[95m \n We change the owner phpmyadmin directory"
chown www-data:www-data /var/www/html/phpmyadmin -R

##########################################
# Test the website
###########################################
echo -e "Default \e[42m \n You can now test your web server, By typing in your browser's search bar :"
echo -e "Default \e[42m \n http://127.0.0.1:$HTTP or http://127.0.0.1:$HTTPS"
echo -e "Default \e[42m \n Now configure NAT rule on your firewall"
echo -e "Default \e[42m \n Protocol TCP - Source Any port Any - Destination WAN Address port 443 - Redirect target IP the machine which hosts the web server"


##########################################
# Clean directory created during the script
###########################################

echo -e "Default \e[42m \n Clean up downloaded files and directories created during installation" 
cd ..
rm -R  Downloads

echo -e "Default \e[42m \n end of the script, now you can configure SSL certificate in nginx if you want, but manually ;)"



read -n 1 -r -s -p "Press any key to continue and clean prompt history for the security and quit the script..."

# this will fire after the key is pressed
echo -e "Default \e[42m \n Clean up the prompt"
sudo history -c
sudo history -w
sudo clear
 
echo -e "Default \e[34m \n Work done, have a nice day"

exit 0;
