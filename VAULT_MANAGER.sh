#!/bin/bash

title="Vault Manager"

echo -n " Before using this tool it is necessary to modify the file:"
echo -n " ~/.bashrc"
echo -n " Add at the end of the file:"
echo -n " export EDITOR=nano"
echo -n " Make sure the config work by typing:"
echo -n " echo $EDITOR"

########################################
# detournement de control-c grace a trap
########################################
trap "echo 'Control-C ne peut être utilisé' ; sleep 1 ; clear ; continue "1 2 3"

#########################################
# fonctions
#########################################
function Create_a_vault(){ 
echo "Your choice is: Create a vault file inside a specific directory"
sleep 1
read -rp "Do you want a demo? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
         echo "Enter the absolute path where the safe will be created (exemple: /etc/ansible/roles/mariadb/var/) : "
         read path
         echo "Enter the name of the file (example: mysql-users.yml) : "
         read file
         FullPath = "${path} ${file}"
         sudo ansible-vault create $FullPath
         echo "Task performed, vault is created: $FullPath"
else
 (echo "Goodbye!"; exit)
fi
}

#-------------------

function Add_account(){ 
echo "Your choice is: Add an account to a vault file"
sleep 1
read -rp "Do you want a demo? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the path and name of the vault file where the new account will be added."
            echo "Like (example: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_edit
            sudo ansible-vault edit $vault_edit
            echo "Task performed, the account has been added to the vault $vault_edit "
else
  (echo "Goodbye!"; exit)
fi
}

#-------------------

function Encrypt(){ 
echo "Your choice is: Encrypt a new vault file"
sleep 1
read -rp "Do you want a demo? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the path and name of the new vault file need to be encrypted."
            echo "Like (exemple: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_no_encrypt
            echo "Enter the secret password to this vault file : "
            y -echo
            read password
            stty echo
            sudo ansible-vault encrypt $vault_no_encrypt
            echo "Task performed, vault $vault_no_encrypt is now encrypted"
else
  (echo "Goodbye!"; exit)
fi
}

#-------------------

function Hash(){ 
echo "Your choice is: Retrieve the hash of a specific vault."
sleep 1
read -rp "Do you want a demo? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the full path and name of the vault."
            echo "Like (example: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_key
            cat $vault_key
            printf "Task performed"
else
  (echo "Goodbye!"; exit)
fi
}

#-------------------

function Content(){ 
echo "Your choice is: Show contents of the vault."
sleep 1
read -rp "Do you want a demo? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the full path and name of the vault."
            echo "Like (example: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_view
            sudo ansible-vault view $vault_view
            printf "Task performed"
else
  (echo "Goodbye!"; exit)
fi
}

#-------------------

function ChangeKey(){ 
echo "Your choice is: Change the key vault."
sleep 1
read -rp "Do you want a demo? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
            echo "Enter the full path and name of the vault."
            echo "Like (example: /etc/ansible/roles/mariadb/var/mysql-users.yml) : "
            read vault_rekey
            ansible-vault rekey $vault_rekey
            echo "Task performed, the key of $vault_rekey has been changed"
else
  (echo "Goodbye!"; exit)
fi
}

#-------------------

function AddConf(){ 
echo "Your choice is: Add vault to the config Ansible."
sleep 1
read -rp "Do you want a demo? [y/n/c] "
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
  (echo "Goodbye!"; exit)
fi
}

#########################################
# menu
#.########################################
PS3="Votre choix : "Choices : "

select item in "- Create a vault inside a specific directory " "- Add an account to a vault file " "- Encrypt a new vault file" "- Retrieve the hash of a specific vault" "- Show contents of the vault" "- Change the key vault" "- Add vault to the config Ansible"
do
echo "Your choice is ..."



