#!/bin/bash
# Swaps path dependencies to versioned for pub.dev publication.
# Usage: bash scripts/prepare_publish.sh
# After publishing, run: bash scripts/restore_dev.sh

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

# Map of package name → list of nexo deps
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
    # Replace path dep with versioned
    sed -i '' "/$dep:/{
      N
      s|$dep:\n    path: \.\./$dep|$dep: ^0.1.0|
    }" "$pubspec"
  done

  echo "UPDATED: $pubspec"
done

echo ""
echo "Done! Path deps swapped to versioned."
echo "Now publish in order: nexo_logger → nexo_errors → nexo_core → rest"
echo "After publishing, run: bash scripts/restore_dev.sh"
