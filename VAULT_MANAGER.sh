#!/bin/bash


echo "\n Before using this tool it is necessary to modify the file:"
echo "\n ~/.bashrc"
echo "\n Add at the end of the file:"
echo "\n export EDITOR=nano"
echo "\n Make sure the config work by typing:"
echo "\n echo $EDITOR"

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="VAULT MANAGER"
TITLE="Manage your vault in a simplified and efficient way"
MENU="Choose one of the following options:"

OPTIONS=(1 "Create an Ansible vault"
         2 "Add user account to your vault"
         3 "Encrypt your vault")
         4 "Retrieving the Vault Key"
         5 "Consult the contents of the vault"
         6 "Change key of vault"
         7 "Add vault to config")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo "You chose Option 1"
            ;;
        2)
            echo "You chose Option 2"
            ;;
        3)
            echo "You chose Option 3"
            ;;
        4)
            echo "You chose Option 4"
            ;;
        5)
            echo "You chose Option 5"
            ;;
        6)
            echo "You chose Option 6"
            ;;
        7)
            echo "You chose Option 7"
            ;;
            
clear
show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        1) clear;
            option_picked "Option 1 Picked, Create a vault in specific directory";
            echo "Enter the absolute path where the safe will be created (exemple: /etc/ansible/roles/mariadb/var/) : "
            read path
            echo "Enter the name of the file (example: mysql-users.yml) : "
            read file
            FullPath = "${path} ${file}"
            sudo ansible-vault create $FullPath
            printf "Task performed, vault is created in $FullPath";
            show_menu;
        ;;
        2) clear;
            option_picked "Option 2 Picked, Add an account to a vault file";
            echo "Enter the path and name of the vault file where the new account will be added."
            echo "Like (example: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_edit
            sudo ansible-vault edit $vault_edit
            printf "Task performed, the account has been added to the vault $vault_edit ";
            show_menu;
        ;;
        3) clear;
            option_picked "Option 3 Picked, Encrypt a new vault file";
            echo "Enter the path and name of the new vault file need to be encrypted."
            echo "Like (exemple: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_no_encrypt
            echo "Enter the secret password for this vault file : "
            y -echo
            read password
            stty echo
            sudo ansible-vault encrypt $vault_no_encrypt
            printf "Task performed, vault $vault_no_encrypt is now encrypted";
            show_menu;
        ;;
        4) clear;
            option_picked "Option 4 Picked, Retrieve the hash of a specific vault";
            echo "Enter the full path and name of the vault."
            echo "Like (example: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_key
            cat $vault_key
            printf "Task performed";
            show_menu;
        ;;
        5) clear;
            option_picked "Option 5 Picked, Show contents of the vault";
            echo "Enter the full path and name of the vault."
            echo "Like (example: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_view
            sudo ansible-vault view $vault_view
            printf "Task performed";
            show_menu;
        ;;
        6) clear;
            option_picked "Option 6 Picked, Change the key vault";
            echo "Enter the full path and name of the vault."
            echo "Like (example: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_rekey
            ansible-vault rekey $vault_rekey
            printf "Task performed, the key of $vault_rekey has been changed";
            show_menu;
        ;;
        7) clear;
            option_picked "Option 7 Picked, Add vault to the config Ansible";
            echo "The path of the ansible.cfg file must be specified"
            echo "By default, the location is: /etc/ansible/ansible. cfg"
            echo "Enter the full path : "
            read ansible_config
            echo "The path of the vault file must be specified."
            echo "Enter the full path of the vault :"
            read path_vault
            location = ansible_config; sudo sed -o "/^$location/ c#vault_password_file" $ansible_config
            sudo sed -i '$a vault_password_file = $path_vault' $ansible_config
            printf "Task performed, The configuration file has been modified. The file containing the user identifiers added";
            show_menu;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Pick an option from the menu";
            show_menu;
        ;;
      esac
    fi
done
