# macOS setup

Provisions a new Mac: GUI apps, command-line tools, language toolchains, and editor config. Everything is idempotent, so it is safe to re-run any time to pick up newly added tools.

## Run it

```sh
mac-os/setup/setup.sh
```

`setup.sh` runs every step in `internal/` in order. You do not need to install anything first.

### Before you run

- **Sign in to the Mac App Store** (App menu, or System Settings). `mas` can no longer sign in from the CLI, and each App Store app must already be in your purchase history, or its install is skipped.
- Expect **password prompts** and a long first run.
- When it finishes, **restart your terminal** so the new shell config and PATH entries take effect.

### Run a single step

Every step is self-contained and safe to run on its own - handy for refreshing just one thing without redoing the whole setup:

```sh
mac-os/setup/internal/vscode.sh   # just refresh VS Code extensions
mac-os/setup/internal/homebrew.sh # just sync the Brewfile
```

## What it installs

`homebrew.sh` runs first and `dotfiles.sh` last; the steps in between are independent and alphabetical.

| Step                | Installs                                                                        |
| ------------------- | ------------------------------------------------------------------------------- |
| `apps-app-store.sh` | Mac App Store apps via `mas` (Xcode, Office, GarageBand, ...)                   |
| `apps-dmg.sh`       | GUI apps shipped as `.dmg`, downloaded straight into `/Applications`            |
| `apps-zip.sh`       | GUI apps shipped as `.zip`, downloaded straight into `/Applications`            |
| `apps-manual.sh`    | Prints reminders for apps it will not auto-install (bot-gated, paid, ambiguous) |
| `apps-steam.sh`     | Prints reminders for apps installed through Steam (Aseprite, Resprite)          |
| `cargo.sh`          | Rust toolchain (rustup) plus the listed cargo crates                            |
| `cli.sh`            | Self-updating vendor CLIs over curl (Claude Code, Oh My Zsh, yt-dlp)            |
| `dotfiles.sh`       | Copies the tracked dotfiles into `$HOME` (shell rc, git, VS Code, Ghostty, ...) |
| `homebrew.sh`       | Everything in the `Brewfile` (CLIs, casks, fonts)                               |
| `node.sh`           | nvm + an LTS Node, with Corepack enabled                                        |
| `pkg.sh`            | CLI tools from a vendor's signed `.pkg` (PowerShell)                            |
| `vscode.sh`         | The listed VS Code extensions                                                   |

Directly-downloaded apps (`apps-dmg.sh` / `apps-zip.sh`) own their own updates; `apps-manual.sh` and `apps-steam.sh` only nudge you - nothing is installed for those.
