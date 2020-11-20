#!/bin/bash
#
# Script de instalacion de entorno de produccion para hospedar aplicaciones en NodeJS
# Creado por Gonzalo Fleitas
# NOTA: Este script esta pensado para instalaciones en Centos 7 o posteriores.
#
# ¿Que hace este script?
# Este script instala nginx con la configuracion por defecto para que inicie al arranque,
# y abre en el firewall los puertos 80 y 443.
# Instala NodeJS en el directorio y version que se le configure, y luego instala PM2 mediante NPM.

# Abrir puertos necesarios
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload

# instalacion de repositorio necesario y de nginx
yum -y install epel-release
yum -y update
yum -y install nginx

# Hacemos que nginx arranque al inicio
systemctl enable nginx

# Instalacion de NodeJS
NODE_VERSION='10.15.0'
PATH_INSTALL='/usr/local/include'

yum -y install wget
wget https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz -O $PATH_INSTALL/node-v$NODE_VERSION-linux-x64.tar.gz
tar -xf $PATH_INSTALL/node-v$NODE_VERSION-linux-x64.tar.gz -C $PATH_INSTALL/
rm -f $PATH_INSTALL/node-v$NODE_VERSION-linux-x64.tar.gz
mv $PATH_INSTALL/node-v$NODE_VERSION-linux-x64 $PATH_INSTALL/node-v$NODE_VERSION
ln -s $PATH_INSTALL/node-v$NODE_VERSION/bin/node /usr/bin/
ln -s $PATH_INSTALL/node-v$NODE_VERSION/bin/npm /usr/bin/

# instalacion de PM2
npm install pm2 -g
ln -s $PATH_INSTALL/node-v$NODE_VERSION/lib/node_modules/pm2/bin/pm2 /usr/bin/

# Iniciar PM2 al arranque
# Para eso genero el archivo de inicio en la carpeta de systemd

FILE_SYSTEM="/etc/systemd/system/pm2-root.service"

echo "[Unit]" >> $FILE_SYSTEM
echo "Description=PM2 Process Manager" >> $FILE_SYSTEM
echo "Documentation=https://pm2.keymetrics.io/" >> $FILE_SYSTEM
echo "After=network.target" >> $FILE_SYSTEM
echo "" >> $FILE_SYSTEM
echo "[Service]" >> $FILE_SYSTEM
echo "Type=forking" >> $FILE_SYSTEM
echo "User=root" >> $FILE_SYSTEM
echo "LimitNOFILE=infinity" >> $FILE_SYSTEM
echo "LimitNPROC=infinity" >> $FILE_SYSTEM
echo "LimitCORE=infinity" >> $FILE_SYSTEM
echo "Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:"$PATH_INSTALL"/node-v"$NODE_VERSION"/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin" >> $FILE_SYSTEM
echo "Environment=PM2_HOME=/root/.pm2" >> $FILE_SYSTEM
echo "PIDFile=/root/.pm2/pm2.pid" >> $FILE_SYSTEM
echo "Restart=on-failure" >> $FILE_SYSTEM
echo "" >> $FILE_SYSTEM
echo "ExecStart="$PATH_INSTALL"/node-v"$NODE_VERSION"/lib/node_modules/pm2/bin/pm2 resurrect" >> $FILE_SYSTEM
echo "ExecReload="$PATH_INSTALL"/node-v"$NODE_VERSION"/lib/node_modules/pm2/bin/pm2 reload all" >> $FILE_SYSTEM
echo "ExecStop="$PATH_INSTALL"/node-v"$NODE_VERSION"/lib/node_modules/pm2/bin/pm2 kill" >> $FILE_SYSTEM
echo "" >> $FILE_SYSTEM
echo "[Install]" >> $FILE_SYSTEM
echo "WantedBy=multi-user.target" >> $FILE_SYSTEM

# Ejecuto el comando para arrancar y activar pm2 al inicio
systemctl start pm2-root
systemctl enable pm2-root
systemctl status pm2-root

echo "--------------------------------------------"
echo "FIN DEL PROCESO DE INSTALACION."
echo "--------------------------------------------"
