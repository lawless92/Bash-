#!/bin/bash



# Directorio donde se almacenará el backup y los logs
BACKUP_DIR="$HOME/logs-backup"
mkdir "$BACKUP_DIR"
# Nombre del archivo de backup con la fecha actual
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%F).tar.gz"
# Archivo de registro
LOG_FILE="$BACKUP_DIR/backup.log"

# Mensaje de inicio del backup
echo "Iniciando backup de logs del sistema: $(date)" >> $LOG_FILE

# Crear un archivo temporal para almacenar los logs de las últimas 24 horas
TEMP_LOG_FILE=$(mktemp)
find /var/log -type f -mtime -1 -exec cp {} $TEMP_LOG_FILE \;

# Comprimir los logs en un archivo tar.gz
tar -czf $BACKUP_FILE -C $(dirname $TEMP_LOG_FILE) $(basename $TEMP_LOG_FILE)

# Eliminar el archivo temporal
rm $TEMP_LOG_FILE

# Mensaje de finalización del backup
echo "Backup completado y guardado en $BACKUP_FILE: $(date)" >> $LOG_FILE
echo "----------------------------------------" >> $LOG_FILE