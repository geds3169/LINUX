######################
#!/bin/bash
#
# Script by geds3169
# 01/02/2021
# Generate vault file
######################


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

#######################
# Adveritssment
#######################

echo "$Cyan \n This script must be run as root, it requires root identification and the creation of a user who will use phpmyadmin and apache $Color_Off"

###############################
# Check user running the script
###############################

if [ "$(whoami)" != 'root' ]; then
echo "$Red \n You are not root, This script must be run as root $Color_Off"
exit 1;
fi

###############################
# Check user running the script
###############################

echo -e "$Green \n Ce script permet de générer et chiffrer un fichier YAML \ncelui-ci contiendra une variable qui elle même définira un utilisateur ou un password \nles variable seront ensuite appelé dans les playbooks $Color_Off"
sleep 1
echo -e "$Green \n La syntaxe au sein de ce fichier doit être par exemple :$Color_Off"
echo -e " $Purple \n mysl_root_user: 'root'$Color_Off"
echo -e " $Purple \n mysl_root_password: 'rootpassword'$Color_Off"
echo -e ""
echo -e " $Purple \n mysl_toto_user: 'toto'$Color_Off"
echo -e " $Purple \n mysl_root_password: 'totopassword'$Color_Off"

sleep 1

echo -e "$Yellow \n Entrez le chemin en dur ou sera placé le fichier \nExemple: \n/etc/ansible/roles/mariadb/vars/ :$Color_Off"
read path

echo -e "$Cyan \n Entrez à présent le nom du fichier avec sont extension en .yml, qui sera chiffré une fois celui-ci édité par vos soins :$Color_Off"
read file

ansible-vault create $file
