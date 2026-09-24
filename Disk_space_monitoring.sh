
#!/usr/bin/env bash

# Comprueba uso de disco, diagnostica qué directorios ocupan más espacio,
# y opcionalmente limpia candidatos seguros conocidos (allowlist).
# Uso:
#   ./disk_cleanup.sh              -> solo diagnóstico + dry-run
#   ./disk_cleanup.sh --execute    -> ejecuta la limpieza de verdad

set -euo pipefail

THRESHOLD=80
LOGFILE="/var/log/disk_cleanup.log"
MOUNT="/"
EXECUTE=false
DAYS_OLD_TMP=7          # borrar en /tmp archivos con más de N días
DAYS_OLD_LOGS=30        # comprimir/rotar logs con más de N días

[[ "${1:-}" == "--execute" ]] && EXECUTE=true

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" | tee -a "$LOGFILE"
}

get_usage() {
    df -h "$MOUNT" | awk 'NR==2 {print $5}' | sed 's/%//'
}

USAGE=$(get_usage)
log "Chequeo de disco: uso actual ${USAGE}% (umbral ${THRESHOLD}%)"

if [ "$USAGE" -lt "$THRESHOLD" ]; then
    log "Disco OK, no se requiere acción."
    exit 0
fi

log "ALERTA: uso de disco supera el umbral. Iniciando diagnóstico."

# --- 1. Diagnóstico: top directorios por tamaño en zonas conocidas de crecimiento ---
log "--- Top 10 directorios en /var (log/cache) ---"
du -x -h /var 2>/dev/null | sort -rh | head -n 10 | tee -a "$LOGFILE"

log "--- Top 10 archivos individuales más grandes en el sistema ---"
find / -xdev -type f -size +100M -exec du -h {} \; 2>/dev/null \
    | sort -rh | head -n 10 | tee -a "$LOGFILE"

# --- 2. Candidatos seguros de limpieza (allowlist explícita) ---
declare -A CANDIDATES=(
    ["journal_vacuum"]="journalctl --vacuum-time=${DAYS_OLD_LOGS}d"
    ["apt_cache"]="apt-get clean"
    ["tmp_old_files"]="find /tmp -type f -mtime +${DAYS_OLD_TMP} -delete"
)

log "--- Candidatos de limpieza (allowlist) ---"
for name in "${!CANDIDATES[@]}"; do
    cmd="${CANDIDATES[$name]}"
    if $EXECUTE; then
        log "EJECUTANDO [$name]: $cmd"
        eval "$cmd" && log "OK [$name]" || log "FALLO [$name]"
    else
        log "DRY-RUN [$name]: $cmd  (no ejecutado, correr con --execute)"
    fi
done

NEW_USAGE=$(get_usage)
log "Uso de disco tras la corrida: ${NEW_USAGE}% (antes: ${USAGE}%)"

if [ "$NEW_USAGE" -ge "$THRESHOLD" ]; then
    log "SIGUE en alerta tras limpieza automática. Requiere revisión manual."
    log "Revisar el diagnóstico de arriba: qué directorio/archivo específico está creciendo fuera de la allowlist."
    exit 1
fi

log "Disco recuperado por debajo del umbral."
exit 0
