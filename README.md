# Hello, my name is __Guilhem SCHLOSSER__, I am currently looking for a Company for a work-study program in Master 2 IS management & Cybersecurity.

## I am not a coder by training, if there are errors and there certainly are. Do not hesitate to advise me.

-----------------------------------------------------------------------------------------------------------------

__I am glad that you are interested in my work.__

If you use my codes for your professional tasks, please mention me.

If you are a French company and you appreciate my work, do not hesitate to contact me, even just a thank you, it's nice.

-----------------------------------------------------------------------------------------------------------------

Script developed for Debian and fully operational.

__!! Remember install first dos2unix and convert the file: dos2unix name_of_the_script.sh !!__

-----------------------------------------------------------------------------------------------------------------

* __auto_LAMP_stack.sh__

    This script allows you to directly install a functional APACHE2-based web solution. Interactive the script asks the user to enter information necessary for the creation of the database. The only thing left at the end of the script is to create a configuration for the VirtualHost or modify the default configuration file.

-----------------------------------------------------------------------------------------------------------------


* __auto_LAMP_stack.sh__
    
    This script allows you to directly install a functional NGINX-based web solution. Interactive the script asks the user to enter information necessary for the creation of the database. The only thing left at the end of the script is to create a configuration for the VirtualHost or modify the default configuration file.

-----------------------------------------------------------------------------------------------------------------

* __auto_VSFTPD_server__

    This script installs VSFTPD a small FTP server to use for the Wordpress CMS.

This will be placed in the / var / www / html

-----------------------------------------------------------------------------------------------------------------

* __auto_GLPI.sh__

    This script is used to install a web server (LAMP) and the ITSM GLPI tool, automatically.

GLPI version is 9.5.2

-----------------------------------------------------------------------------------------------------------------

* __cmdnotfound.sh__

    The .bashrc file allows the user to customize their shell. But in the present context it is a question of implementing the paths in order to have access to Linux commands, non-functional on a freshly installed distribution, such as adduser

-----------------------------------------------------------------------------------------------------------------

* __disable_IPv6.sh__

    Disable IPv6 definitively

-----------------------------------------------------------------------------------------------------------------
* __VAULT_MANAGER.sh__

      How to use:

        Start the script in executable mode:
                                                                 chmod + x VAULT_MANAGER.sh

        Select the task to be performed in the menu and answer the questions.

I still recommend the use of the following commands in order to leave no trace in any file or terminal.

            history -c
            history -w

!! Attention these command delete all your history and command used !!

---


To specify the vault password interactively:

                       ansible-playbook site.yml --ask-vault-pass

***

The other method is to create a .txt file, which will then be hidden in a directory:
~ / .file.txt

However, it will be necessary to assign specific permissions to it in order to secure it.

The password must be a string stored on a single line in the file.

***
You can also set the environment ANSIBLE_VAULT_PASSWORD_FILEvariable, for example ANSIBLE_VAULT_PASSWORD_FILE = ~ / .vault_pass.txt, and Ansible will automatically look for the password in this file.

This is something you might want to do if you are using Ansible from a continuous integration system like Jenkins.

***

To have a broader example of the use:

https://docs.ansible.com/ansible/2.8/user_guide/playbooks_vault.html
-----------------------------------------------------------------------------------------------------------------
