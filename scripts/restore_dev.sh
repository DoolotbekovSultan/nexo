#!/bin/bash
# Restores path dependencies for local development.
# Usage: bash scripts/restore_dev.sh

set -e

PACKAGES=(
  nexo_errors
  nexo_core
  nexo_validation
  nexo_network
  nexo_datasource
  nexo_usecase
  nexo_bloc
  nexo_sync
  nexo_ui
  nexo_testing
  nexo_errors_firebase
  nexo_errors_hive
  nexo_errors_isar
  nexo_errors_drift
)

declare -A NEXO_DEPS
NEXO_DEPS[nexo_errors]="nexo_logger"
NEXO_DEPS[nexo_core]="nexo_errors"
NEXO_DEPS[nexo_validation]="nexo_errors"
NEXO_DEPS[nexo_network]="nexo_logger nexo_errors"
NEXO_DEPS[nexo_datasource]="nexo_logger nexo_network"
NEXO_DEPS[nexo_usecase]="nexo_core nexo_errors nexo_logger"
NEXO_DEPS[nexo_bloc]="nexo_core nexo_errors nexo_logger"
NEXO_DEPS[nexo_sync]="nexo_errors nexo_logger"
NEXO_DEPS[nexo_ui]="nexo_core nexo_errors"
NEXO_DEPS[nexo_testing]="nexo_errors"
NEXO_DEPS[nexo_errors_firebase]="nexo_errors"
NEXO_DEPS[nexo_errors_hive]="nexo_errors"
NEXO_DEPS[nexo_errors_isar]="nexo_errors"
NEXO_DEPS[nexo_errors_drift]="nexo_errors"

for pkg in "${PACKAGES[@]}"; do
  pubspec="packages/$pkg/pubspec.yaml"
  if [ ! -f "$pubspec" ]; then
    echo "SKIP: $pubspec not found"
    continue
  fi

  deps="${NEXO_DEPS[$pkg]}"
  for dep in $deps; do
    # Replace versioned dep with path
    sed -i '' "s|$dep: \^0.1.0|$dep:\n    path: \.\./$dep|" "$pubspec"
  done

  echo "RESTORED: $pubspec"
done

echo ""
echo "Done! Path deps restored for local development."
