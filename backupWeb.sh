#!/bin/bash

# Definición de las ubicaciones de los directorios a respaldar y los destinos de los respaldos.
dirDestino="/tempBackup/html/"
dirDrive="/RESPALDOS/DIR_WEBS/"
dirMain01="/etc/"
dirMain02="/var/"
Fecha=$(date +"%d%m%Y")
anteAyerFecha=$(date +"%d%m%Y" --date='-2 day')
dirFecha="-"$Fecha".tar.gz"

# Información de correo electrónico para el reporte de respaldo.
nameCliente="AQUI EL NOMBRE DEL CLIENTE"
hostCliente="URL DEL HOST"
correoReceptor="EMAIL RECEPTOR DE ALERTAS"

dirHttpd="httpd"
dirHtml="www"

# Nombre del archivo de registro.
LOG_FILE="backup.log"

# Eliminar archivo de registro si existe.
if [ -f "$LOG_FILE" ]; then
    rm "$LOG_FILE"
fi

# Función para realizar un respaldo y moverlo al directorio destino.
backup_dir () {
    local dir=$1
    local backup_name=$2$dirFecha

    cd $dir
    tar -czvf $backup_name $dirHttpd
    mv $backup_name $dirDestino
    echo "[INFO] Respaldo realizado y movido a $dirDestino: $backup_name" | tee -a $LOG_FILE
}

timeInit=$(date +"%T - %d/%m/%Y")

# Respaldo de los directorios.
backup_dir $dirMain01 $dirHttpd
backup_dir $dirMain02 $dirHtml

cd $dirDestino
mkdir -p pesoBackup
mv $dirHttpd$dirFecha pesoBackup/
mv $dirHtml$dirFecha pesoBackup/

cd pesoBackup/
pesoBK=$(du -hs)
echo "[INFO] Peso de los respaldos: $pesoBK" | tee -a $LOG_FILE

mv $dirHttpd$dirFecha ../
mv $dirHtml$dirFecha ../
cd $dirDestino

mv $dirHttpd$dirFecha $dirDrive
mv $dirHtml$dirFecha $dirDrive
echo "[INFO] Los respaldos han sido movidos a $dirDrive" | tee -a $LOG_FILE

rm -rf pesoBackup/
timeFin=$(date +"%T - %d/%m/%Y")

# Borrar respaldos antiguos.
cd $dirDrive
rm -rf $dirHttpd"-"$anteAyerFecha".tar.gz"
rm -rf $dirHtml"-"$anteAyerFecha".tar.gz"
echo "[INFO] Se han eliminado los respaldos antiguos de la fecha: $anteAyerFecha" | tee -a $LOG_FILE

# Enviar alerta por correo.
fechaEmail=$(date +"%Y%m%d%H%M%S")
echo -e "    ###  BACKUP DIR_WEB  ###  \n\n - Cliente: " $nameCliente "\n - Host: " $hostCliente "\n - Inicio: " $timeInit "\n - Fin:    " $timeFin "\n - Peso Bakcup: " $pesoBK | mail -s "BACKUP WEB "$fechaEmail $correoReceptor
echo "[INFO] Se ha enviado un correo a $correoReceptor con los detalles del respaldo." | tee -a $LOG_FILE
