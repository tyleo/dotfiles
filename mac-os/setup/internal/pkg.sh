#!/usr/bin/env bash
# Command-line tools shipped as a vendor's signed .pkg installer (not Homebrew, the
# App Store, or a language toolchain). The vendor signs and notarizes the pkg, so
# `installer` runs it with no Gatekeeper bypass. These tools do not self-update, so
# each version below is pinned and acts as the source of truth: bump the version and
# its matching URL together and the next run upgrades in place.
#
# Each row is four lines - "<name>", "<command>", "<version>", "<url>" - where
# "<command> --version" is matched against "<version>" to decide whether to install.
# pkgs holds those rows and install_rows installs each. Entries are ABC-ordered by
# name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

pkgs=(
  # PowerShell. Apple Silicon build; on Intel swap "osx-arm64" for "osx-x64" in the
  # URL. GitHub release assets have no "latest" alias, so the version is pinned: bump
  # it (and the URL) when a newer release ships. Signed + notarized since the May 2026
  # release, so installer needs no -allowUntrusted.
  "PowerShell"
  "pwsh"
  "7.6.3"
  "https://github.com/PowerShell/PowerShell/releases/download/v7.6.3/powershell-7.6.3-osx-arm64.pkg"
)

install_rows 4 install_pkg "${pkgs[@]}"
