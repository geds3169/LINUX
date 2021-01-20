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
         7 "Option 7")
         
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
            echo "Install Ansible"
            ;;
            read install_ansible
        2)
            echo "Add an user"
            ;;
            read addmyuser
        3)
            echo "Add an user to SUDO"
            ;;
            read add_sudo
        4)
            echo "Create pair key SSH"
            ;;
            read create_sshKey
        5)
            echo "Copy SSH ID to the node"
            ;;
        6)
            echo "copy ssh key to user"
            ;;
            read copy-ssh-to-user
        7)
            echo "Install openssh client & server"
            ;;
            read install-openssh
esac
#############################################

# Function

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
apt update -y
apt-get upgrade -y
sudo apt-get install software-properties-common -y
apt install ansible -y
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
apt install sudo -y
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

function copy-ssh-to-user()
{
echo " Copy ssh key to user :"
chmod 700 /home/$USER/.ssh
echo "Copy authorized_keys root to user"
echo "Write the username :"
read user
sudo cp /root/.ssh/authorized_keys /home/$user/.ssh/authorized_keys
echo "change permission of the user to the folder /home/$user.ssh"
chown -R $USER:$USER /home/$user/.ssh
echo "change permission to /home/$user/.ssh/authorized_keys"
chmod 600 /home/$USER/.ssh/authorized_keys
ls -al
echo "Write the the key ID :"
read id
echo "Host *
User $user
IdentityFile /home/$user/id" > /home/$user/.ssh/config
}

function install-openssh()
{
apt update
apt-get ugrade -y
apt-get install openssh-client openssh-server -y
}

#############################################
