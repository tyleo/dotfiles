#!/usr/bin/env bash

# Install the Android SDK's `platform-tools` (`adb`) with the `android` CLI from
# `homebrew.sh`. SDK packages a project pins belong to that project.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew

# Falls back to the `.zprofile` value because a first run may not have deployed
# it yet.
ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"

# Already-installed packages are a quick no-op.
android --sdk="$ANDROID_HOME" sdk install platform-tools
