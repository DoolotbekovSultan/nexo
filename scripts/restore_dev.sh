#!/bin/bash
# Restores path dependencies for local development.
# Usage: bash scripts/restore_dev.sh

set -e
cd "$(dirname "$0")/.."

swap_to_path() {
  local pkg=$1
  local dep=$2
  local pubspec="packages/$pkg/pubspec.yaml"
  sed -i '' "s|$dep: \^0.1.0|$dep:\n    path: \.\./$dep|" "$pubspec"
  echo "  $pkg: $dep → path"
}

echo "Restoring path deps for development..."

swap_to_path nexo_errors nexo_logger
swap_to_path nexo_core nexo_errors
swap_to_path nexo_validation nexo_errors
swap_to_path nexo_network nexo_logger
swap_to_path nexo_network nexo_errors
swap_to_path nexo_datasource nexo_logger
swap_to_path nexo_datasource nexo_network
swap_to_path nexo_usecase nexo_core
swap_to_path nexo_usecase nexo_errors
swap_to_path nexo_usecase nexo_logger
swap_to_path nexo_bloc nexo_core
swap_to_path nexo_bloc nexo_errors
swap_to_path nexo_bloc nexo_logger
swap_to_path nexo_sync nexo_errors
swap_to_path nexo_sync nexo_logger
swap_to_path nexo_ui nexo_core
swap_to_path nexo_ui nexo_errors
swap_to_path nexo_testing nexo_errors
swap_to_path nexo_errors_firebase nexo_errors
swap_to_path nexo_errors_hive nexo_errors
swap_to_path nexo_errors_isar nexo_errors
swap_to_path nexo_errors_drift nexo_errors

echo ""
echo "Done! Path deps restored for local development."
