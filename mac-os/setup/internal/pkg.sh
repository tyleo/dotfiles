#!/usr/bin/env bash

# Command-line tools shipped as a vendor's signed `.pkg` installer. The vendor
# signs and notarizes the pkg, so `installer` runs it with no Gatekeeper bypass.
# These tools do not self-update, so each version below is pinned and acts as
# the source of truth: bump the version and its matching URL together and the
# next run upgrades in place.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

items=(
  "PowerShell"
  "pwsh"
  "7.6.3"
  "https://github.com/PowerShell/PowerShell/releases/download/v7.6.3/powershell-7.6.3-osx-arm64.pkg"
)

install_rows 4 install_pkg "${items[@]}"
