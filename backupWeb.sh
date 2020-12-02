#!/bin/bash

# Requerimientos para el correcto funcionamiento:
#00 02 * * * /opt/scriptsDQJ/backupWeb.sh
#mkdir -p /tempBackup/html/
#mkdir -p /RESPALDOS/DIR_WEBS/

dirDestino="/tempBackup/html/"
dirDrive="/RESPALDOS/DIR_WEBS/"
dirMain01="/etc/"
dirMain02="/var/"
Fecha=$(date +"%d%m%Y")
anteAyerFecha=$(date +"%d%m%Y" --date='-2 day')
dirFecha="-"$Fecha".tar.gz"

nameCliente="AQUI EL NOMBRE DEL CLIENTE"
hostCliente="URL DEL HOST"
correoReceptor="EMAIL RECEPTOR DE ALERTAS"

dirHttpd="httpd"
dirHtml="www"

timeInit=$(date +"%T - %d/%m/%Y")

cd $dirMain01
tar -czvf $dirHttpd$dirFecha $dirHttpd
mv $dirHttpd$dirFecha $dirDestino

cd $dirMain02
tar -czvf $dirHtml$dirFecha $dirHtml
mv $dirHtml$dirFecha $dirDestino

cd $dirDestino
mkdir -p pesoBackup
mv $dirHttpd$dirFecha pesoBackup/
mv $dirHtml$dirFecha pesoBackup/
cd pesoBackup/
pesoBK=$(du -hs)
mv $dirHttpd$dirFecha ../
mv $dirHtml$dirFecha ../
cd $dirDestino
mv $dirHttpd$dirFecha $dirDrive
mv $dirHtml$dirFecha $dirDrive
rm -rf pesoBackup/

timeFin=$(date +"%T - %d/%m/%Y")

#cd $dirDestino
cd $dirDrive
rm -rf $dirHttpd"-"$anteAyerFecha".tar.gz"
rm -rf $dirHtml"-"$anteAyerFecha".tar.gz"

### ALERTA POR CORREO
fechaEmail=$(date +"%Y%m%d%H%M%S")
echo -e "    ###  BACKUP DIR_WEB  ###  \n\n - Cliente: " $nameCliente "\n - Host: " $hostCliente "\n - Inicio: " $timeInit "\n - Fin:    " $timeFin "\n - Peso Bakcup: " $pesoBK | mail -s "BACKUP WEB "$fechaEmail $correoReceptor
