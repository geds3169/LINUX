#!/bin/bash
#
# Auteur : guilhem Schlosser
# Date : Aout 2022
# Nom du fichier: crowdsec_blacklist_IP_management.sh
# Version 1.0.0 :
# title: CrowdSec blacklist IPv4 & IPv6 management
# Permet de:
# - Consulter les blacklists IPv4 et IPv6
# - rechercher si une IPv4 ou IPv6 est présente
# - Ajouter une IP à la blacklist
# - De supprimer une IP de la blacklist
#
################################################

####################  Function echo space line  ############################
# function for add space between echo line, usage echo $"message"
function GET_RECORDS()
{
   echo -e "starting\n the process";
}
###########################################################################

####################    Function searchUnban  #############################
searchUnban (){
	GET_RECORDS()
	backtitle="Search and Unban IP"

	echo $"${backtitle}"	
	echo $"Renseignez l'adresse IPv4 ou IPv6 à rechercher : "
	read ip_search

	if [ "(sudo ipset list crowdsec-blacklists | grep '^ip_search\')" == ${ip_search} ] ||  [ "(sudo ipset list crowdsec-blacklists | grep '^ip_search\')" == ${ip_search} ]; then
			echo $"IP ${ip_search} non présente ... "
	else
			echo $"IP ${ip_search} trouvé !"
		echo $"Voulez-vous débannir cette IP ? [y/n] : "
		read unban
		if [ "${unban}" == "yes" ] || [ "${unban}" == "y" ]; then
			sudo cscli decisions delete --ip "$ipsearch"
			echo $"La tâche a été effectué"
		fi
		echo $"Voulez-vous rechercher une autre IP ? [y/n] : "
		read another
		if [ "${another}" == "yes" ] || [ "${another}" == "y" ]; then
			exec $0
		else
			echo $"Retour au menu principal"
			MENU()
		fi
	fi
}
###########################################################################

####################    Function MENU2  ############################
function MENU2(){
	title="Ban IP"
	sleep 0.2

	echo ${title}
	echo "select the operation ************"
	echo "  1)Ban one IPv4 or IPv6"
	echo "  2)Ban range IPv4"
	echo "  3)Quitter" 

	read n
	case $n in
	  1) echo "Vous avez choisi Option 1 - Ban one IPv4 or IPv6"
		clear
		clear
		GET_RECORDS()
		backtitle="Ban one IPv4 or IPv6"
		echo $"${backtitle}"

		echo $"Renseignez l'adresse IP : "
		read addIP
		echo $"Renseignez la durée du bannissement (1-24 ou plus = mois/année) : "
		read banDuration
		echo $"Renseignez la raison (web bruteforce, Dos, DDoS, MitM, Phishing, Spear phishing) : "
		read reason
		sudo cscli decisions add --ip ${addIP} --duration ${banDuration}h --reason ${reason}
		echo $"Souhaitez vous ajouter une autre IP ? [y/n] : "
		read answer1
		if [ "${answer1}" == "yes" ] || [ "${answer1}" == "y" ]; then 
			$0
		else
			echo $"Retour au sous-menu"
			MENU2()
	  ;;
	  2) echo "Vous avez choisi Option 2 - Ban range IPv4"
		clear
		clear
		GET_RECORDS()
		backtitle="Ban range IPv4"
		echo $"${backtitle}"

		echo $"Renseignez la plage d'adresse IP (range: 1.2.3.0/24) : "
		read rangeIP
		sudo cscli decisions delete --range ${rangeIP}
		echo $"Souhaitez vous ajouter une autre plage IP ? [y/n] : "
		read answer1
		if [ "${answer1}" == "yes" ] || [ "${answer1}" == "y" ]; then 
			$0
		else
			echo $"Retour au sous-menu"
			MENU2()
			
	  ;;
	  3) echo "Vous avez choisi Option 4 - Retour au menu principal"
		MENU()
	  ;;
	  *) echo "Vous avez entrez une valeur incorrecte";;
	esac
	}
####################################################################

####################    Function MENU  #############################

function MENU()
{
title="CrowdSec blacklist IPv4 & IPv6 management"
sleep 0.2

echo ${title}
echo "select the operation ************"
echo "  1)Show blacklist"
echo "  2)Search and Unban IP"
echo "  3)Ban IP"
echo "  4)Quitter" 

read n
case $n in
  1) echo "Vous avez choisi Option 1 - Show blacklist"
	clear
	GET_RECORDS()
	backtitle="Show blacklist"
	echo $"${backtitle}"
	echo $"Voulez-vous afficher la liste des IPv4 blacklistés ? [y/n] : "
	read blacklist4
	if [ "${blacklist4}" == "yes" ] || [ "${blacklist4}" == "y" ]; then
		sudo ipset list crowdsec-blacklists | less
	elif
		echo $"Voulez-vous afficher la liste des IPv6 blacklistés ? [y/n] : "
		read blacklist6
		if [ "${blacklist6}" == "yes" ] || [ "${blacklist6}" == "y" ]; then
			sudo ipset list crowdsec6-blacklists | less
	else
		echo $"Vous n'avez sélectionné aucune option valide"
		echo $"Voulez-vous revenir au menu ? : "
		read back
		if [ "${back}" == "yes" ] || [ "${back}" == "y" ]; then
			MENU()
		fi
	fi

  ;;
  2) echo "Vous avez choisi Option 2 - Search and Unban IP"
	clear
	searchUnban()
  ;;
  3) echo "Vous avez choisi Option 3 - Ban IP(s)"
	clear
	MENU(2)
  ;;
  4) echo "You chose Option 4 - Quit"
	exit 0
  ;;
  *) echo "you entered an invalid option";;
esac
}
####################################################################

####################      SCRIPT     ###############################
#Name of script
$0
#PID Shell script
echo "The script is executed under the PID $$"

# Call menu function
MENU()
####################       End       ###############################
