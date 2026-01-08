#!/bin/bash

# 1. Limpieza de archivos temporales
echo "Eliminando archivos temporales no modificados en los últimos 7 días..."
find /tmp -type f -mtime +7 -exec rm -f {} \;
echo "Limpieza completada."

# 2. Informe de uso de disco por directorios en la raíz
du -h --max-depth=1 / > /var/log/informe_uso_disco_$(date +%F).log

# 3. Backup automático del directorio /home
backup_dir="/backup"
fecha=$(date +%F)
archivo_backup="home_backup_$fecha.tar.gz"
mkdir -p "$backup_dir"
tar -czf "$backup_dir/$archivo_backup" /home
