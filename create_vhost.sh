#!/bin/bash

# Asegurarse de que existan estos 2 directorios
PATH_APACHE_CONF="/etc/httpd/vhosts/"
DOCUMENT_ROOT="/var/www/sites/"

# Grupo perteneciente a apache
GROUP=apache

USERNAME=$1
DOMAIN=$2
DIRECTORY=$DOCUMENT_ROOT$DOMAIN

if [ $# -ne 2 ]; then
	echo "-------------------------------------------------------------------"
	echo "ERROR DE PARAMETROS: "
	echo ""
	echo -e "\t - Primer parametro debe ser el usuario"
	echo -e "\t - Segundo parametro debe ser el dominio o subdominio"
	echo "-------------------------------------------------------------------"
	exit
fi

# Agrego el usuario para la carpeta del virtualhost
useradd $USERNAME -g $GROUP -d $DIRECTORY -s /sbin/nologin
# Seteo todos los permisos para propietario y grupo
chmod 770 $DIRECTORY
echo "Usuario "$USERNAME "creado."

# Creo subcarpetas necesarias para el servidor web
mkdir $DIRECTORY"/html"
mkdir $DIRECTORY"/logs"
chown $USERNAME:$GROUP $DIRECTORY"/html"
chown $USERNAME:$GROUP $DIRECTORY"/logs"

chmod 770 $DIRECTORY"/html"
chmod 770 $DIRECTORY"/logs"
echo "Carpetas para el servidor creadas."

# Creo archivo de configuracion para host virtual de apache
echo "<VirtualHost *:80>" >> $PATH_APACHE_CONF$DOMAIN".conf"
echo "	ServerName $DOMAIN" >> $PATH_APACHE_CONF$DOMAIN".conf"
#echo "	ServerAlias www.test.com" >> $PATH_APACHE_CONF$DOMAIN".conf"
echo "	DocumentRoot $DIRECTORY/html" >> $PATH_APACHE_CONF$DOMAIN".conf"
echo "	ErrorLog $DIRECTORY/logs/error_log" >> $PATH_APACHE_CONF$DOMAIN".conf"
echo "	CustomLog $DIRECTORY/logs/access_log combined" >> $PATH_APACHE_CONF$DOMAIN".conf"
echo "</VirtualHost>" >> $PATH_APACHE_CONF$DOMAIN".conf"
