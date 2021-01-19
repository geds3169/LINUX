#! /bin/bash

#############################################
#
# Some function to install Ansible
# By geds3169 - guilhemETkarine@hotmail.fr
#
#############################################

#Only root quand run this script

if [ $UID -ne 0 ] ; then
        echo "You are not root, you cannot use this script"
        exit 1
fi

#############################################

# Menu

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Multiple action"
TITLE="Install Ansible"
MENU="Choose one of the following options:"

OPTIONS=(1 "Option 1"
         2 "Option 2"
         3 "Option 3")
         4 "Option 4")
         5 "Option 5")
         6 "Option 6")
         
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
            echo "install ansible"
            ;;
        2)
            echo "add an user"
            ;;
        3)
            echo "add an user to sudo"
            ;;
        4)
            echo "add an user to sudo"
            ;;
        5)
            echo "create pair key SSH"
            ;;
         6)
            echo "copy-ssh-id"
            ;;
esac

#############################################

function install_ansible()
{
# Welcome
echo "This script install a complète install Ansible"
echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | sudo tee -a /etc/apt/sources.list

echo "Install ansible repository on the sourcelist and GPG key"
#sh -c 'echo "[some repository]" >> /etc/apt/sources.list'
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

echo "Update package"
apt update

echo "Install Ansible"
apt install ansible
echo "end of the installation"
}

function addmyuser()
{
# Add user
echo "create user username :"
sudo adduser myuser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "myuser:password" | sudo chpasswd
echo "Well done! user created"
}

function add_sudo()
{
echo "install sudo to the system"
apt update
apt install sudo
echo "install add user to sudo"
echo "Enter the name of the user to add to sudo :"
read username
usermod -aG sudo $usernmod
echo "groups"
}

function create_sshKey()
{
# Générate pair key SSH
echo "Generate pair key SSH
ssh-keygen -q -t rsa -N '' -f ~/.ssh/kmykey <<< ""$'\n'"y"  2>&1 >/dev/null
$ echo $?
0
}

function copy-ssh-id()
{
echo " Write the name of the user authorized to connect in SSH :"
read user

echo "Write the @IP or FQDN node :"
read server

# Copy SSH key to the node
ssh-copy-id user@"${SERVER}"
}


