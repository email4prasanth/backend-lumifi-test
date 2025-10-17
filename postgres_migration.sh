#!/bin/bash
set -euo pipefail

# -----------------------------
# CONFIGURATION
# -----------------------------
# Source (dev) RDS
SRC_HOST="dev-lumifi-db.cxkiky6us81t.us-east-1.rds.amazonaws.com"
SRC_DB="dev_lumifi"
SRC_USER="dbadmin"
SRC_PASS="x6mTPvo_FH_y2Trw"
SRC_PORT=5432

# Target (prod) RDS
TGT_HOST="prod-db-private.cxkiky6us81t.us-east-1.rds.amazonaws.com"
TGT_DB="prod_lumifi_private"
TGT_USER="dbadmin"
TGT_PASS="Fji0rR30mb-MOAn^"
TGT_PORT=5432

# Dump file location
DUMP_FILE="/tmp/dev_lumifi.dump"

# -----------------------------
# STEP 1: VERIFY CONNECTIVITY
# -----------------------------
echo "Checking connectivity to DEV RDS..."
PGPASSWORD="$SRC_PASS" psql -h "$SRC_HOST" -U "$SRC_USER" -d "$SRC_DB" -p "$SRC_PORT" -c "\l"

echo "Checking connectivity to PROD RDS..."
PGPASSWORD="$TGT_PASS" psql -h "$TGT_HOST" -U "$TGT_USER" -d "$TGT_DB" -p "$TGT_PORT" -c "\l"

# -----------------------------
# STEP 2: DUMP DEV RDS
# -----------------------------
echo "Dumping DEV RDS to $DUMP_FILE ..."
PGPASSWORD="$SRC_PASS" pg_dump -h "$SRC_HOST" -U "$SRC_USER" -d "$SRC_DB" -Fc -f "$DUMP_FILE"

# -----------------------------
# STEP 3: RESTORE TO PROD RDS
# -----------------------------
echo "Restoring dump to PROD RDS..."
PGPASSWORD="$TGT_PASS" pg_restore -h "$TGT_HOST" -U "$TGT_USER" -d "$TGT_DB" -v "$DUMP_FILE"
