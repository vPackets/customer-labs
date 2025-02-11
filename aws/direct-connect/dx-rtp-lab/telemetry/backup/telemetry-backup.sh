#!/bin/bash

# Define backup directory
BACKUP_DIR=~/code/telemetry/backups

# Define volume paths
GRAFANA_DATA=~/code/telemetry/grafana/data
INFLUXDB_DATA=~/code/telemetry/influxdb/data

# Define backup file names (replace with your actual backup file names)
GRAFANA_BACKUP_FILE="$BACKUP_DIR/grafana_backup_<timestamp>.tar.gz"
INFLUXDB_BACKUP_FILE="$BACKUP_DIR/influxdb_backup_<timestamp>.tar.gz"

# Restore Grafana data
tar -xzf $GRAFANA_BACKUP_FILE -C $GRAFANA_DATA
echo "Grafana data restored from $GRAFANA_BACKUP_FILE"

# Restore InfluxDB data
tar -xzf $INFLUXDB_BACKUP_FILE -C $INFLUXDB_DATA
echo "InfluxDB data restored from $INFLUXDB_BACKUP_FILE"

# Log the restore
echo "Restore completed at $(date)."