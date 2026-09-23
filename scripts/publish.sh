#!/bin/bash
# Publishes all packages to pub.dev in dependency order.
# Prerequisites: bash scripts/prepare_publish.sh && dart pub login
# After publishing: bash scripts/restore_dev.sh

set -e
cd "$(dirname "$0")/.."

publish() {
  local pkg=$1
  echo ""
  echo "=== Publishing $pkg ==="
  cd "packages/$pkg"
  dart pub publish
  cd ../..
}

echo "Publishing nexo packages to pub.dev..."
echo "Make sure you ran: bash scripts/prepare_publish.sh && dart pub login"

publish nexo_logger
publish nexo_errors
publish nexo_core
publish nexo_validation
publish nexo_network
publish nexo_datasource
publish nexo_usecase
publish nexo_bloc
publish nexo_sync
publish nexo_ui
publish nexo_testing
publish nexo_errors_firebase
publish nexo_errors_hive
publish nexo_errors_isar
publish nexo_errors_drift

echo ""
echo "All packages published!"
echo "Run: bash scripts/restore_dev.sh"
