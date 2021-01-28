################################################
#                                              #
#          Create vault value.yml              #
#          For ANSIBLE                         #
#                                              #
################################################

#!/bin/sh

echo "Where do you want to create the vault (enter the full path + name.yml) :
read $FULLPATH

echo "Write your text :"
read $some_line

if [ ! -e $FULLPATH ]; then
   echo $some_line > $FULLPATH
then
   echo "echo "The file doesn't exit and will be created with the text!"
else
   echo "The file already exit and we cannot be write it !"
fi

# show result existant file
ls -l $FULLPATH

echo "Read the file content :"
cat $FULLPATH

# Encrypt the yaml file containing the username and associated password 
read -p "Do you want to encrypt this file with the vault command ?  : y/Y/n/N/cancel" CONDITION;
if [ "$CONDITION" == "y/Y" ]; then
   # do something here!
   ansible-vault create $FULLPATH
fi

# show result
echo "Echo work done, here is the return :"
cat $FULLPATH
