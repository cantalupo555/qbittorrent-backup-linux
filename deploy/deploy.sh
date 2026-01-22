#!/bin/bash
#
# Deploy script for qbt.cantalupo.com.br
# Run this from your local machine to deploy to VPS
#

set -euo pipefail

# ============================================================
# CONFIGURATION
# ============================================================
VPS_HOST="rbc"                           # SSH config alias
VPS_PATH="/var/www/qbt_cantalupo_com_br"

# ============================================================
# Colors
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================
# Functions
# ============================================================
info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ============================================================
# Checks
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

[[ ! -f "$PROJECT_DIR/run.sh" ]] && error "run.sh não encontrado"
[[ ! -f "$PROJECT_DIR/generate-index.sh" ]] && error "generate-index.sh não encontrado"

# Generate index.html
info "Generating index.html..."
(cd "$PROJECT_DIR" && ./generate-index.sh) || error "Failed to generate index.html"
ok "index.html generated"

# ============================================================
# Deploy
# ============================================================
echo ""
echo "=========================================="
echo "  Deploying qbt-backup to VPS"
echo "=========================================="
echo ""

info "Target: ${VPS_HOST}"
info "Path: ${VPS_PATH}"
echo ""

# Copy files to /tmp first, then move with sudo
info "Copying files..."
scp "$PROJECT_DIR/run.sh" "$PROJECT_DIR/index.html" "${VPS_HOST}:/tmp/"
ok "Files copied to /tmp"

# Move to final destination and set permissions
info "Moving files and setting permissions..."
ssh "${VPS_HOST}" "sudo mv /tmp/{run.sh,index.html} ${VPS_PATH}/ && sudo chown www-data:www-data ${VPS_PATH}/{run.sh,index.html} && sudo chmod 644 ${VPS_PATH}/{run.sh,index.html}"
ok "Permissions set"

echo ""
echo "=========================================="
echo -e "  ${GREEN}Deploy complete!${NC}"
echo "=========================================="
echo ""
echo "Test:"
echo "  curl -sL https://qbt.cantalupo.com.br | head -10"
echo ""
