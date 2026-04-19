#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/srv/backup"

log() { echo "[$(date +%H:%M:%S)] $*"; }

do_backup() {
	local TIMESTAMP
	TIMESTAMP=$(date +%Y%m%d_%H%M%S)
	local BACKUP_PATH="${BACKUP_DIR}/${TIMESTAMP}"
	mkdir -p "${BACKUP_PATH}"

	log "Dumping PostgreSQL..."
	sudo -u postgres pg_dumpall >"${BACKUP_PATH}/postgresql_dump.sql"
	log "PostgreSQL dump complete"

	log "Stopping tempo, loki, prometheus..."
	sudo systemctl stop loki prometheus # tempo 

	log "Backing up Prometheus..."
	sudo tar -czf "${BACKUP_PATH}/prometheus.tar.gz" -C /var/lib prometheus
	log "Backing up Loki..."
	sudo tar -czf "${BACKUP_PATH}/loki.tar.gz" -C /var/lib loki
	#log "Backing up Tempo..."
	#sudo tar -czf "${BACKUP_PATH}/tempo.tar.gz" -C /var/lib tempo

	log "Starting prometheus, loki, tempo..."
	sudo systemctl start prometheus loki # tempo

	log "All backups saved to ${BACKUP_PATH}"
	ls -lh "${BACKUP_PATH}"
}

do_restore() {
	local BACKUP_PATH="${1:?Usage: $0 restore <backup_dir>}"

	if [ ! -d "${BACKUP_PATH}" ]; then
		echo "Error: backup directory not found: ${BACKUP_PATH}" >&2
		exit 1
	fi

	log "Stopping all services..."
	sudo systemctl stop tempo loki prometheus postgresql

	if [ -f "${BACKUP_PATH}/prometheus.tar.gz" ]; then
		log "Restoring Prometheus..."
		sudo rm -rf /var/lib/prometheus
		sudo tar -xzf "${BACKUP_PATH}/prometheus.tar.gz" -C /var/lib
		sudo chown -R prometheus:prometheus /var/lib/prometheus
		log "Prometheus restore complete"
	fi

	if [ -f "${BACKUP_PATH}/loki.tar.gz" ]; then
		log "Restoring Loki..."
		sudo rm -rf /var/lib/loki
		sudo tar -xzf "${BACKUP_PATH}/loki.tar.gz" -C /var/lib
		sudo chown -R loki:loki /var/lib/loki
		log "Loki restore complete"
	fi

	if [ -f "${BACKUP_PATH}/tempo.tar.gz" ]; then
		log "Restoring Tempo..."
		sudo rm -rf /var/lib/tempo
		sudo tar -xzf "${BACKUP_PATH}/tempo.tar.gz" -C /var/lib
		sudo chown -R tempo:tempo /var/lib/tempo
		log "Tempo restore complete"
	fi

	if [ -f "${BACKUP_PATH}/postgresql_dump.sql" ]; then
		log "Restoring PostgreSQL..."
		sudo -u postgres pg_dropcluster 17 main -- 2>/dev/null || true
		sudo -u postgres pg_createcluster 17 main || true
		sudo systemctl start postgresql
		sudo -u postgres psql -f "${BACKUP_PATH}/postgresql_dump.sql" postgres
		log "PostgreSQL restore complete"
	fi

	log "Starting all services..."
	sudo systemctl start prometheus loki # tempo

	log "Restore finished!"
}

case "${1:-}" in
backup) do_backup ;;
restore) do_restore "${2:-}" ;;
*)
	echo "Usage: $0 {backup|restore} [backup_dir]"
	echo "  $0 backup"
	echo "  $0 restore /srv/backup/20250419_120000"
	exit 1
	;;
esac
