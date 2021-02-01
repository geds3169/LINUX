#!/bin/bash


echo -e " Ce script permet de générer et chiffrer un fichier YAML \ncelui-ci contiendra une variable qui elle même définira un utilisateur ou un password \nles variable seront ensuite appelé dans les playbooks"
sleep 1
echo -e " La syntaxe au sein de ce fichier doit être par exemple :"
echo -e " mysl_root_user: 'root'"
echo -e " mysl_root_password: 'rootpassword'"
echo -e ""
echo -e " mysl_toto_user: 'toto'"
echo -e " mysl_root_password: 'totopassword'"

sleep 1

echo -e "Entrez le chemin en dur ou sera placé le fichier \nExemple: \n/etc/ansible/roles/mariadb/vars/ :"
read path

echo -e "Entrez à présent le nom du fichier avec sont extension en .yml, qui sera chiffré une fois celui-ci édité par vos soins :"
read file

ansible-vault create $file
