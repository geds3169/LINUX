#!/bin/bash

########################################
# Custosm Color
########################################
# Color  Variables
green='\e[32m'
blue='\e[34m'
red='\e[31m'
purple='\e[35m'
clear='\e[0m'

#########################################
# fonctions
#########################################
ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

#-------------------

function Create_a_vault(){ 
echo "Your choice is: Create a vault file inside a specific directory"
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
	 echo -e $red "If you have not created the tree structure beforehand, you can use the following script in a new terminal: "$clear
	 echo -e $green "https://raw.githubusercontent.com/geds3169/ANSIBLE/main/builds_the_role_tree.sh " $clear
         echo "Enter the absolute path where the safe will be created exemple: /etc/ansible/roles/mariadb/var/ : "
         read path
         read file
         FullPath = "${path} ${file}"
         sudo ansible-vault create $FullPath
         echo "Task performed, vault is created: $FullPath"
else
 (echo "Goodbye!"; menu)
fi
}

#-------------------

function Add_account(){ 
echo "Your choice is: Add an account to a vault file"
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the path and name of the vault file where the new account will be added."
            echo "Like example: /etc/ansible/roles/mariadb/var/mysql-users.yml : "
            read vault_edit
            sudo ansible-vault edit $vault_edit
            echo "Task performed, the account has been added to the vault $vault_edit "
else
  (echo "Goodbye!"; menu)
fi
}

#-------------------

function Encrypt(){ 
echo "Your choice is: Encrypt a new vault file"
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the path and name of the new vault file need to be encrypted."
            echo "Like exemple: /etc/ansible/roles/mariadb/var/mysql-users.yml : "
            read vault_no_encrypt
            echo "Enter the secret password to this vault file : "
            y -echo
            read password
            stty echo
            sudo ansible-vault encrypt $vault_no_encrypt
            echo "Task performed, vault $vault_no_encrypt is now encrypted"
else
  (echo "Goodbye!"; menu)
fi
}

#-------------------

function Hash(){ 
echo "Your choice is: Retrieve the hash of a specific vault."
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the full path and name of the vault."
            echo "Like example: /etc/ansible/roles/mariadb/var/mysql-users.yml : "
            read vault_key
            cat $vault_key
            printf "Task performed"
else
  (echo "Goodbye!"; menu)
fi
}

#-------------------

function Content(){ 
echo "Your choice is: Show contents of the vault."
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the full path and name of the vault."
            echo "Like example: /etc/ansible/roles/mariadb/var/mysql-users.yml : "
            read vault_view
            sudo ansible-vault view $vault_view
            printf "Task performed"
else
  (echo "Goodbye!"; menu)
fi
}

#-------------------

function ChangeKey(){ 
echo "Your choice is: Change the key vault."
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the full path and name of the vault."
            echo "Like example: /etc/ansible/roles/mariadb/var/mysql-users.yml : "
            read vault_rekey
            ansible-vault rekey $vault_rekey
            echo "Task performed, the key of $vault_rekey has been changed"
else
  (echo "Goodbye!"; menu)
fi
}

#-------------------

function AddConf(){ 
echo "Your choice is: Add vault to the config Ansible."
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "The path of the ansible.cfg file must be specified"
            echo "By default, the location is: /etc/ansible/ansible. cfg"
            echo "Enter the full path : "
            read ansible_config
            echo "The path of the vault file must be specified."
            echo "Enter the full path of the vault :"
            read path_vault
            location = ansible_config; sudo sed -o "/^$location/ c#vault_password_file" $ansible_config
            sudo sed -i '$a vault_password_file = $path_vault' $ansible_config
            echo "Task performed, The configuration file has been modified. The file containing the user identifiers added"
else
  (echo "Goodbye!"; menu)
fi
}

#########################################
# Advertissment
#.########################################

echo " Before using this tool it is necessary to install Ansible."
echo "create the base recommended tree (or at least the folder where the vault will be located)."
echo "To finish if you prefer NANO to VIM, modify the file:"
echo " ~/.bashrc"
echo " Add at the end of the file:"
echo " export EDITOR=nano"
echo " Make sure the config work by typing:"
echo " echo VARIABLE EDITOR"


#########################################
# menu
#.########################################
menu(){
echo -ne "
My First Menu
$(ColorGreen '1)') Create a vault file inside a specific directory
$(ColorGreen '2)') Add an account to a vault file
$(ColorGreen '3)') Encrypt a new vault file 
$(ColorGreen '4)') Retrieve the hash of a specific vault
$(ColorGreen '5)') Show contents of the vault
$(ColorGreen '6)') Change the key vault
$(ColorGreen '7)') Add vault to the config Ansible
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) Create_a_vault ; menu ;;
	        2) Add_account ; menu ;;
	        3) Encrypt ; menu ;;
	        4) Hash ; menu ;;
	        5) Content ; menu ;;
                 6) ChangeKey ; menu ;;
                 7) AddConf ; menu ;;
			0) exit 0 ;;
			*) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}

#########################################
# Call the menu function
#########################################
menu
