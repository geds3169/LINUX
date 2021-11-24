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
            option_picked "Option 1 Picked";
            printf "AJOUTER LA COMMANDE";
            show_menu;
        ;;
        2) clear;
            option_picked "Option 2 Picked";
            printf "AJOUTER LA COMMANDE";
            show_menu;
        ;;
        3) clear;
            option_picked "Option 3 Picked";
            printf "AJOUTER LA COMMANDE";
            show_menu;
        ;;
        4) clear;
            option_picked "Option 4 Picked";
            printf "AJOUTER LA COMMANDE";
            show_menu;
        ;;
        5) clear;
            option_picked "Option 5 Picked";
            printf "AJOUTER LA COMMANDE";
            show_menu;
        ;;
        6) clear;
            option_picked "Option 6 Picked";
            printf "AJOUTER LA COMMANDE";
            show_menu;
        ;;
        7) clear;
            option_picked "Option 7 Picked";
            printf "AJOUTER LA COMMANDE";
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
esac
