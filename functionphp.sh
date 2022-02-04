#!/bin/bash

PHP_MIN="php7.4.*"
PHP_MAX="php8.*"

#sleep 5
#clear
echo "Installation de PHP"
# Determine si PHP est installé sur le système, la version minimale requise
if [[  "$(dpkg --get-selections | grep $PHP_MIN || grep $PHP_MAX)" =~ "install" ]]; then
  echo "$PHP est déjà présent sur le systeme"
  # check si la version minimale requise est installé et utilisé
  if [[ "$(dpkg --get-selections | grep "php")" -ge "$PHP" ]]; then
    echo "La version de PHP correspond aux attentes "
  else
    echo "La version de PHP ne répond pas aux attentes"
    echo "L'installation de la nouvelle version requiert l'installation des outils de gestion de certification et des clés de dépôt."
    echo -e "\nSouhaitez-vous procéder à l'installation pour les sources d'installation, PHP et ses modules associés [y/n] ? "
    read q
    if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
      sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 >> tools.log
      echo -e "Ajout du dépôt source PHP\n"
      echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
      echo -e "\nImport de la clé de certification du dépôt"
      wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -
      echo -e "\nMise à jour et indexation du nouveau dépôt"
      sudo apt-get update -y -qq >> update.log
      sudo apt-get install php libapache2-mod-php php-{mysql,intl,curl,json,gd,xml,mbstring,zip,imagick,common,curl,imap,ssh2,xml,apcu,redis,ldap} -y >> update.log
      sudo apt-get install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y >> update.log
      echo -e "\nMise à jour de la version php et modules associé, \nun fichier update.log et tools.log ont été créés ou mis à jour, ils se trouvent dans le répertoire courant.\n"
      echo -e "\nTâche effectué avec succès\n"
      php -v && php -m
    fi
  fi
else
  echo "$PHP n'est pas présent sur le systeme"
fi
