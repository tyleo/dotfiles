# macOS setup

Provisions a new Mac: GUI apps, command-line tools, language toolchains, and
editor config. Everything is idempotent, so it is safe to re-run any time to pick
up newly added tools.

## Run it

```sh
mac-os/setup/setup.sh
```

`setup.sh` runs every step in `internal/` in order. You do not need to install
anything first - Homebrew and each language toolchain are bootstrapped on demand.

### Before you run

- **Sign in to the Mac App Store** (App menu, or System Settings). `mas` can no
  longer sign in from the CLI, and each App Store app must already be in your
  purchase history, or its install is skipped.
- Expect **password prompts** (Homebrew, some installers) and a long first run -
  Xcode alone is a ~10GB+ download.
- When it finishes, **restart your terminal** so the new shell config and PATH
  entries take effect.

### Run a single step

Every step is self-contained and safe to run on its own - handy for refreshing
just one thing without redoing the whole setup:

```sh
mac-os/setup/internal/vscode.sh   # just refresh VS Code extensions
mac-os/setup/internal/homebrew.sh # just sync the Brewfile
```

## What it installs

Steps run in alphabetical order; they are independent, so order does not matter.

| Step                | Installs                                                                        |
| ------------------- | ------------------------------------------------------------------------------- |
| `apps-app-store.sh` | Mac App Store apps via `mas` (Xcode, Office, GarageBand, ...)                   |
| `apps-dmg.sh`       | GUI apps shipped as `.dmg`, downloaded straight into `/Applications`            |
| `apps-zip.sh`       | GUI apps shipped as `.zip`, downloaded straight into `/Applications`            |
| `apps-manual.sh`    | Prints reminders for apps it will not auto-install (bot-gated, paid, ambiguous) |
| `cargo.sh`          | Rust toolchain (rustup) plus the listed cargo crates                            |
| `cli.sh`            | Vendor curl-installed CLIs (Claude Code, Oh My Zsh)                             |
| `homebrew.sh`       | Everything in the `Brewfile` (CLIs, casks, fonts)                               |
| `node.sh`           | nvm + an LTS Node, with Corepack enabled                                        |
| `pkg.sh`            | CLI tools from a vendor's signed `.pkg` (PowerShell)                            |
| `vscode.sh`         | The listed VS Code extensions                                                   |

Directly-downloaded apps (`apps-dmg.sh` / `apps-zip.sh`) own their own updates;
`apps-manual.sh` only nudges you - nothing is installed for those.

## Adding tools

Each list lives in its own step script, kept in alphabetical order:

- **Homebrew formula / cask / font** - add a line to `internal/Brewfile`.
- **Direct-download app** - add a `"<name>"` / `"<url>"` pair to `apps-dmg.sh` or
  `apps-zip.sh` (whichever format it ships as).
- **Mac App Store app** - add a `"<name>"` / `"<app-store-id>"` pair to
  `apps-app-store.sh`.
- **App with no clean download** - add a `"<name>"` / `"<url>"` pair to
  `apps-manual.sh` so a reminder is printed.
- **CLI tool from a signed `.pkg`** - add an `install_pkg` call to `pkg.sh` with
  the tool's command, pinned version, and `.pkg` URL.
- **cargo crate** - add it to `cargo_crates` in `cargo.sh`.
- **VS Code extension** - add it to `vscode_extensions` in `vscode.sh`.

Shared helpers (`ensure_brew`, `install_app_dmg`, `install_app_zip`,
`install_each`, `install_pairs`, `install_pkg`, ...) live in `internal/lib.sh`.
