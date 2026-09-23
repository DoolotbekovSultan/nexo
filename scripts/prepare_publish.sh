#!/bin/bash
# Swaps path dependencies to versioned for pub.dev publication.
# Usage: bash scripts/prepare_publish.sh
# After publishing, run: bash scripts/restore_dev.sh

set -e
cd "$(dirname "$0")/.."

swap_to_versioned() {
  local pkg=$1
  local dep=$2
  local pubspec="packages/$pkg/pubspec.yaml"
  sed -i '' "/$dep:/{
    N
    s|$dep:\n    path: \.\./$dep|$dep: ^0.1.0|
  }" "$pubspec"
  echo "  $pkg: $dep → ^0.1.0"
}

echo "Swapping path deps to versioned..."

swap_to_versioned nexo_errors nexo_logger
swap_to_versioned nexo_core nexo_errors
swap_to_versioned nexo_validation nexo_errors
swap_to_versioned nexo_network nexo_logger
swap_to_versioned nexo_network nexo_errors
swap_to_versioned nexo_datasource nexo_logger
swap_to_versioned nexo_datasource nexo_network
swap_to_versioned nexo_usecase nexo_core
swap_to_versioned nexo_usecase nexo_errors
swap_to_versioned nexo_usecase nexo_logger
swap_to_versioned nexo_bloc nexo_core
swap_to_versioned nexo_bloc nexo_errors
swap_to_versioned nexo_bloc nexo_logger
swap_to_versioned nexo_sync nexo_errors
swap_to_versioned nexo_sync nexo_logger
swap_to_versioned nexo_ui nexo_core
swap_to_versioned nexo_ui nexo_errors
swap_to_versioned nexo_testing nexo_errors
swap_to_versioned nexo_errors_firebase nexo_errors
swap_to_versioned nexo_errors_hive nexo_errors
swap_to_versioned nexo_errors_isar nexo_errors
swap_to_versioned nexo_errors_drift nexo_errors

echo ""
echo "Done! Now publish in order:"
echo "  nexo_logger → nexo_errors → nexo_core → rest"
echo ""
echo "After publishing, run: bash scripts/restore_dev.sh"
