#!/usr/bin/env bash

# Command-line tools shipped as a vendor's signed `.pkg` installer. The vendor
# signs and notarizes the pkg, so `installer` runs it with no Gatekeeper bypass.
# These tools do not self-update. Each run resolves the vendor's latest pkg and
# upgrades in place when its version differs from the one on PATH.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

items=(
  "PowerShell"
  "pwsh"
  "github PowerShell/PowerShell ^powershell-[0-9.]+-osx-arm64\.pkg$"
)

install_rows 3 install_pkg "${items[@]}"
