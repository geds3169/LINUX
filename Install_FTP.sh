#########################################################
#	Script by geds3169 11/10/2020						#
#	Script install vsftpd a tiny ftp server				#
#	used for the CMS wordpress inside /var/www/html		#
#														#
#########################################################

#############################################
# Variable colors							#
#############################################
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

#############################################
# Update package and system					#
#############################################
echo -e "$Green \n Updating System.. $Color_Off"
apt-get update -y && apt-get upgrade -y

#############################################
#	Installation de vsftpd and openssl		#
#############################################
echo -e "$Green \n Install package server FTP vsftpd and opessl for the security $Color_Off"
apt-get install vsftpd openssl

#############################################
#	Stop service vsftpd						#
#############################################
echo -e "$Green \n Turn off server FTP vsftpd $Color_Off"
service vsftpd stop

#############################################
#	Save and Write config vsftpd server		#
#############################################
echo -e "$Green \n Save initial configuration file vsftpd server FTP in /etc/vsftpd.conf_BACKUP $Color_Off"
cp -i /etc/vsftpd.conf /etc/vsftpd.conf_BACKUP

echo -e "$Green \n Write configuration file vsftpd server FTP $Color_Off"
rm /etc/vsftpd.conf
touch "# Enable only local users, no anonymous
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022

# Allow only our special FTP user
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd.allow_list

# Here's the security trick -- listen only on the local interface to 
# prevent external connections
listen_address=127.0.0.1

# Enable debugging until everything works :)
log_ftp_protocol=YES" >> /etc/vsftpd.conf

#############################################
#	Add the user debian for vsftpd			#
#############################################
echo -e "$Green \n Add the user debian for vsftpd $Color_Off"
useradd ftpsecure -d /var/www -s /usr/sbin/nologin

#########################################################
#	Set a password.										#
#	Since vsftpd is only listening on localhost, the	#
#	security of this password isn't too important.		#
#########################################################
echo -e "$Green \n Create password for users server ftp $Color_Off"
passwd ftpsecure

#############################################
#	Add to the vsftpd allow list			#
#############################################
echo -e "$Green \n Create list users allowed on the server ftp $Color_Off"
echo "ftpsecure" | sudo tee -a /etc/vsftpd.allow_list

#############################################
#	Restart server ftp vsftpd				#
#############################################
echo -e "$Green \n Restart server ftp vsftpd $Color_Off"
service vsftpd start

#############################################################################
#	Set permissions for ftpsecure to access your Web install folder files	#
#############################################################################
echo -e "$Green \n Set permissions for ftpsecure to access your Web install folder files $Color_Off"
setfacl -m u:ftpsecure:r-x /var/www/

#################################################
#	The updater needs access to the root site	#
#################################################
echo -e "$Green \n The updater needs access to the root site $Color_Off"
setfacl -R -m u:ftpsecure:rwx /var/www/html/
setfacl -R -d -m u:ftpsecure:rwx /var/www/html/

#########################################################################################################
#	Tell WordPress or other CMS about your FTP credentials. In /var/www/html/wordpress/wp-config.php	#
#########################################################################################################
echo -e "$Red \n Tell WordPress or other CMS about your FTP credentials. In /var/www/html/MY_WEB_SITE_NAME/wp-config.php $Color_Off"
echo -e "$Red define('FTP_HOST', 'localhost');
echo -e "$Red define('FTP_USER', 'ftpsecure');
echo -e "$Red define('FTP_PASS', '');

echo -e "$Green \n Show last information loged in the vsftpd.log $Color_Off"
tail -f /var/log/vsftpd.log

# You'll be able to tell from the log if there was a permission problem, Disable logging, Remove the line
echo -e "$Cyan You'll be able to tell from the log if there was a permission problem, Disable logging, Remove the line $Color_Off"
echo -e "$Cyan Disable loggin by removing the line log_ftp_protocol=YES in the /etc/vsftpd.conf $Color_Off"

echo -e "$Yellow You're done! $Color_Off"
