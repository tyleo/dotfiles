# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

fpath=("$HOME/.zsh/completions" $fpath)

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  fzf-tab
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Setup `alias`s

alias open='open -a ForkLift'

# Setup Directories

hash -d applications=~/applications
hash -d documents=~/documents
hash -d downloads=~/downloads
hash -d git=~/git
hash -d misc=~/misc
hash -d scratch=~/scratch

# Setup `PATH`

export PATH="$HOME/.local/bin:$PATH"

# Setup Tools

## `fzf`
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

## `nvm`
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

## `starship`
eval "$(starship init zsh)"

# Setup Variables
gitconfig=~/.gitconfig
zshrc=~/.zshrc

# Setup Functions

## System Functions

# Make Dock pop up instantly
set_dock_animation_speed() {
  local autohide_delay="${1:-0.05}"
  local autohide_time_modifier="${2:-0.5}"
  if defaults write com.apple.dock autohide-delay -float "${autohide_delay}" \
    && defaults write com.apple.dock autohide-time-modifier -float "${autohide_time_modifier}"; then
    killall Dock
    echo "✅ Dock set to pop up instantly"
  else
    echo "❌ Failed to set Dock animation speed"
    return 1
  fi
}

# Restore Dock to default animation
restore_dock_animation_speed() {
  defaults delete com.apple.dock autohide-time-modifier 2>/dev/null
  defaults delete com.apple.dock autohide-delay 2>/dev/null
  killall Dock
  echo "✅ Restored default Dock animation"
}

# Make holding a key repeat it (instead of showing the accent picker).
set_key_repeat() {
  if defaults write -g ApplePressAndHoldEnabled -bool false; then
    echo "✅ Key repeat enabled. Log out and back in (or restart apps) to apply"
  else
    echo "❌ Failed to enable key repeat"
    return 1
  fi
}

# Restore default press-and-hold behavior (accent picker on key hold).
restore_key_repeat() {
  defaults delete -g ApplePressAndHoldEnabled 2>/dev/null
  echo "✅ Restored press-and-hold. Log out and back in to apply"
}

# Map F18/F19 (Karabiner mouse buttons) to the Back/Forward menu items in all
# apps. Registers as App Shortcuts in System Settings. F18 is \uf715 and F19
# is \uf716 in the NSF18FunctionKey range.
set_mouse_back_forward() {
  if defaults write -g NSUserKeyEquivalents -dict-add "Back" $'\uf715' \
    && defaults write -g NSUserKeyEquivalents -dict-add "Forward" $'\uf716'; then
    echo "✅ F18/F19 mapped to Back/Forward. Restart apps to apply"
  else
    echo "❌ Failed to map F18/F19 to Back/Forward"
    return 1
  fi
}

# Remove the F18/F19 Back/Forward shortcuts, keeping other App Shortcuts.
restore_mouse_back_forward() {
  /usr/libexec/PlistBuddy -c "Delete :NSUserKeyEquivalents:Back" ~/Library/Preferences/.GlobalPreferences.plist 2>/dev/null
  /usr/libexec/PlistBuddy -c "Delete :NSUserKeyEquivalents:Forward" ~/Library/Preferences/.GlobalPreferences.plist 2>/dev/null
  killall cfprefsd
  echo "✅ Removed F18/F19 Back/Forward shortcuts. Restart apps to apply"
}

# Make ForkLift the default app for opening folders.
set_file_viewer_to_forklift() {
  if defaults write -g NSFileViewer -string com.binarynights.ForkLift \
    && defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.folder";LSHandlerRoleAll="com.binarynights.ForkLift";}'; then
    killall Finder
    echo "✅ ForkLift set as the default folder viewer. Log out and back in for it to fully apply"
  else
    echo "❌ Failed to set ForkLift as the default folder viewer"
    return 1
  fi
}

# Restore Finder as the default app for opening folders.
restore_file_viewer() {
  if defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.folder";LSHandlerRoleAll="com.apple.finder";}'; then
    defaults delete -g NSFileViewer 2>/dev/null
    killall Finder
    echo "✅ Restored Finder as the default folder viewer. Log out and back in for it to fully apply"
  else
    echo "❌ Failed to restore Finder as the default folder viewer"
    return 1
  fi
}

# Make Finder show hidden files.
set_finder_show_hidden_files() {
  if defaults write com.apple.finder AppleShowAllFiles -bool true; then
    killall Finder
    echo "✅ Finder set to show hidden files"
  else
    echo "❌ Failed to set Finder to show hidden files"
    return 1
  fi
}

# Restore default Finder behavior (hidden files not shown).
restore_finder_show_hidden_files() {
  defaults delete com.apple.finder AppleShowAllFiles 2>/dev/null
  killall Finder
  echo "✅ Restored Finder to hiding hidden files"
}

# Keep the system awake on AC power so SSH stays reachable while plugged in.
# The display still sleeps; battery behavior is unchanged; closing the lid
# still sleeps unless in clamshell mode.
set_no_sleep_on_ac() {
  if sudo pmset -c sleep 0; then
    echo "✅ System sleep disabled on AC power. SSH stays reachable while plugged in"
  else
    echo "❌ Failed to disable system sleep on AC power"
    return 1
  fi
}

# Restore default system sleep on AC power (1 minute after the display sleeps).
restore_sleep_on_ac() {
  if sudo pmset -c sleep 1; then
    echo "✅ Restored system sleep on AC power"
  else
    echo "❌ Failed to restore system sleep on AC power"
    return 1
  fi
}

# Restart the display and brightness services to fix monitor glitches.
reload_monitors() {
  if sudo killall -HUP corebrightnessd && sudo killall -HUP WindowServer; then
    echo "✅ Reloaded display and brightness services"
  else
    echo "❌ Failed to reload display and brightness services"
    return 1
  fi
}

# Reload ~/.zshrc into the current shell.
reload_zshrc() {
  if source ~/.zshrc; then
    echo "✅ Reloaded ~/.zshrc"
  else
    echo "❌ Failed to reload ~/.zshrc"
    return 1
  fi
}

## cd

# Change into the git directory.
cdg() {
  cd ~git
}

## claude

# Switch the Claude Code statusline preset (e.g. set_claude mobile).
set_claude() {
  local preset="$1"
  local settings=~/.claude/statusline-settings.json

  if [[ -z "$preset" ]]; then
    echo "usage: set_claude <preset>"
    return 1
  fi

  if ! jq -e --arg preset "$preset" '.presets[$preset]' "$settings" > /dev/null 2>&1; then
    echo "❌ Unknown preset '$preset' (available: $(jq -r '.presets | keys | join(", ")' "$settings" 2>/dev/null))"
    return 1
  fi

  if jq -n --arg preset "$preset" '{preset: $preset}' > ~/.claude/statusline-state.json; then
    echo "✅ Claude statusline preset set to $preset"
  else
    echo "❌ Failed to set Claude statusline preset"
    return 1
  fi
}

## cwebp

# Convert a single image file into WebP format, deleting the original file.
file_into_webp() {
  file_to_webp "$1"
  rm "$1"
}
# Convert a single image file into WebP format, keeping the original file.
file_to_webp() {
  cwebp "$1" -o "${1%.*}.webp"
}
# Convert multiple image files into WebP format, deleting the original files.
ext_into_webp() {
  ext_to_webp "$@"
  rm "$@"
}
# Convert multiple image files into WebP format, keeping the original files.
ext_to_webp() {
  for img in "$@"; do
    cwebp "$img" -o "${img%.*}.webp"
  done
}

## duti

# Print the app that opens files with the given extension
# (e.g. get_default_app_for_extension mkv -> VLC).
get_default_app_for_extension() {
  local ext="$1"

  if [[ -z "$ext" ]]; then
    echo "usage: get_default_app_for_extension <extension>"
    return 1
  fi

  local out
  out="$(duti -x "${ext#.}")" || return 1
  echo "$out" | sed -n '1s/\.app$//p'
}

# Print the bundle id of the app that opens files with the given extension
# (e.g. get_default_app_id_for_extension mkv -> org.videolan.vlc).
get_default_app_id_for_extension() {
  local ext="$1"

  if [[ -z "$ext" ]]; then
    echo "usage: get_default_app_id_for_extension <extension>"
    return 1
  fi

  local out
  out="$(duti -x "${ext#.}")" || return 1
  echo "$out" | sed -n '3p'
}

# Set the default app for a file extension by app name
# (e.g. set_default_app_for_extension mkv VLC).
set_default_app_for_extension() {
  local ext="$1" app="$2"

  if [[ -z "$ext" || -z "$app" ]]; then
    echo "usage: set_default_app_for_extension <extension> <app-name>"
    return 1
  fi

  local bundle_id
  bundle_id="$(get_app_id "$app")" || return 1
  set_default_app_by_id_for_extension "$ext" "$bundle_id"
}

# Set the default app for a file extension by bundle id
# (e.g. set_default_app_by_id_for_extension mkv org.videolan.vlc).
set_default_app_by_id_for_extension() {
  local ext="$1" bundle_id="$2"

  if [[ -z "$ext" || -z "$bundle_id" ]]; then
    echo "usage: set_default_app_by_id_for_extension <extension> <bundle-id>"
    return 1
  fi

  ext=".${ext#.}"
  if duti -s "$bundle_id" "$ext" all; then
    echo "✅ $ext now opens with $bundle_id"
  else
    echo "❌ Failed to set default app for $ext"
    return 1
  fi
}

# Set the default app for a UTI by app name
# (e.g. set_default_app_for_uti org.matroska.mkv VLC).
set_default_app_for_uti() {
  local uti="$1" app="$2"

  if [[ -z "$uti" || -z "$app" ]]; then
    echo "usage: set_default_app_for_uti <uti> <app-name>"
    return 1
  fi

  local bundle_id
  bundle_id="$(get_app_id "$app")" || return 1
  set_default_app_by_id_for_uti "$uti" "$bundle_id"
}

# Set the default app for a UTI by bundle id
# (e.g. set_default_app_by_id_for_uti org.matroska.mkv org.videolan.vlc).
set_default_app_by_id_for_uti() {
  local uti="$1" bundle_id="$2"

  if [[ -z "$uti" || -z "$bundle_id" ]]; then
    echo "usage: set_default_app_by_id_for_uti <uti> <bundle-id>"
    return 1
  fi

  if duti -s "$bundle_id" "$uti" all; then
    echo "✅ $uti now opens with $bundle_id"
  else
    echo "❌ Failed to set default app for $uti"
    return 1
  fi
}

## ffmpeg

# Convert a portion of a video into a high-quality GIF.
#
# Usage:
#   gifify [options] input.mp4 output.gif
#
# Options:
#   -s <start>   Optional start timestamp (e.g. 3 or 00:00:03)
#   -e <end>     Optional end timestamp (e.g. 7 or 00:00:07)
#   -w <width>   Optional output width in pixels (default: 480)
#   -f <fps>     Optional frames per second (default: 12)
#
# Examples:
#   # Full video to GIF
#   gifify input.mp4 output.gif
#
#   # Clip from 3s to 7s
#   gifify -s 3 -e 7 input.mp4 output.gif
#
#   # Custom width + fps
#   gifify -s 1 -e 4 -w 360 -f 15 input.mp4 output.gif
#
# Notes:
#   - Height auto-scales to preserve aspect ratio.
#   - Uses inline palette generation (no temp files).
gifify() {
  local start=() end=()
  local fps=12
  local width=480
  local opt

  while getopts "s:e:w:f:" opt; do
    case "$opt" in
      s) start=(-ss "$OPTARG") ;;
      e) end=(-to "$OPTARG") ;;
      w) width="$OPTARG" ;;
      f) fps="$OPTARG" ;;
      *)
        echo "Usage: gifify [-s start] [-e end] [-w width] [-f fps] input.mp4 output.gif" >&2
        return 1
        ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$#" -ne 2 ]; then
    echo "Usage: gifify [-s start] [-e end] [-w width] [-f fps] input.mp4 output.gif" >&2
    return 1
  fi

  local in="$1"
  local out="$2"

  ffmpeg "${start[@]}" "${end[@]}" -i "$in" -filter_complex \
"[0:v] fps=${fps},scale=${width}:-1:flags=lanczos,split [a][b]; \
 [a] palettegen [p]; \
 [b][p] paletteuse" \
-y "$out"
}

# mp4ify: Convert a portion of a video into a high-quality MP4.
#
# Usage:
#   mp4ify [options] input.mp4 output.mp4
#
# Options:
#   -s <start>   Optional start timestamp (e.g. 3 or 00:00:03)
#   -e <end>     Optional end timestamp (e.g. 7 or 00:00:07)
#   -w <width>   Optional output width in pixels (default: 1080)
#   -f <fps>     Optional frames per second (default: source FPS)
#   -c <codec>   Optional codec: h264 (default), h265, vp9, av1
#
# Examples:
#   mp4ify -s 3 -e 7 input.mp4 clip.mp4
#   mp4ify -s 1 -e 4 -w 720 -f 30 input.mp4 small.mp4
#   mp4ify -c h265 input.mp4 out.mp4
#
mp4ify() {
  local start=() end=()
  local fps=""
  local width=1080
  local codec="h264"
  local opt

  # Will hold things like: (-c:v libx264 -preset slow -crf 18)
  local vcodec_args=()

  while getopts "s:e:w:f:c:" opt; do
    case "$opt" in
      s) start=(-ss "$OPTARG") ;;
      e) end=(-to "$OPTARG") ;;
      w) width="$OPTARG" ;;
      f) fps="$OPTARG" ;;
      c) codec="$OPTARG" ;;
      *)
        echo "Usage: mp4ify [-s start] [-e end] [-w width] [-f fps] [-c codec] input.mp4 output.mp4" >&2
        return 1
        ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$#" -ne 2 ]; then
    echo "Usage: mp4ify [-s start] [-e end] [-w width] [-f fps] [-c codec] input.mp4 output.mp4" >&2
    return 1
  fi

  local in="$1"
  local out="$2"

  # Choose codec mapping
  case "$codec" in
    h264)
      vcodec_args=(-c:v libx264 -preset slow -crf 18)
      ;;
    h265|hevc)
      vcodec_args=(-c:v libx265 -preset slow -crf 20)
      ;;
    vp9)
      vcodec_args=(-c:v libvpx-vp9 -b:v 0 -crf 30)
      ;;
    av1)
      vcodec_args=(-c:v libaom-av1 -b:v 0 -crf 32)
      ;;
    *)
      echo "Unknown codec '$codec'. Use: h264, h265, vp9, av1" >&2
      return 1
      ;;
  esac

  # Use -2 so ffmpeg chooses an even height automatically (required by libx264)
  local filters="scale=${width}:-2:flags=lanczos"
  if [ -n "$fps" ]; then
    filters="fps=${fps},${filters}"
  fi

  ffmpeg "${start[@]}" "${end[@]}" -i "$in" \
    -vf "$filters" \
    "${vcodec_args[@]}" \
    -c:a aac -b:a 192k \
    -movflags +faststart \
    -y "$out"
}

## httrack

# Mirror the website at url into out_dir, staying within that URL.
download_webpage() {
  local url="$1"
  local out_dir="$2"

  if [[ -z "$url" || -z "$out_dir" ]]; then
    echo "usage: download_webpage <url> <output_dir>"
    return 1
  fi

  httrack "$url" \
    -O "$out_dir" \
    "%e0" \
    "+${url}*" \
    "-*" \
    --disable-security-limits
}

## mdls

# Print the UTI of a file extension
# (e.g. get_uti_for_extension mkv -> org.matroska.mkv).
get_uti_for_extension() {
  local ext="$1"

  if [[ -z "$ext" ]]; then
    echo "usage: get_uti_for_extension <extension>"
    return 1
  fi

  local dir
  dir="$(mktemp -d)" || return 1
  touch "$dir/file.${ext#.}"
  mdls -name kMDItemContentType -raw "$dir/file.${ext#.}"
  echo
  rm -rf "$dir"
}

## osascript

# Print the bundle identifier of the named app (e.g. get_app_id VLC).
get_app_id() {
  local app="$1"

  if [[ -z "$app" ]]; then
    echo "usage: get_app_id <app-name>"
    return 1
  fi

  osascript -e "id of app \"$app\""
}

# Print the name of the app with the given bundle identifier
# (e.g. get_app_name org.videolan.vlc -> VLC).
get_app_name() {
  local bundle_id="$1"

  if [[ -z "$bundle_id" ]]; then
    echo "usage: get_app_name <bundle-id>"
    return 1
  fi

  osascript -e "name of app id \"$bundle_id\""
}

## pdfimages

# Extract every embedded image from pdf_file, naming each with out_prefix.
extract_pdf_images() {
  local pdf_file="$1"
  local out_prefix="$2"

  if [[ -z "$pdf_file" ]]; then
    echo "usage: extract_pdf_images <pdf_file> <output_prefix>"
    return 1
  fi

  pdfimages -all "$pdf_file" "$out_prefix"
}

## safari

# Open the Safari iCloud tabs database to clear stuck tabs.
edit_safari_tabs_db() {
  # https://manualdousuario.net/en/how-to-remove-stuck-icloud-tabs-in-safari/
  sqlite3 ~/Library/Containers/com.apple.Safari/Data/Library/Safari/CloudTabs.db
}

## yt-dlp

# Download the best video and audio streams for url, merged into an mkv.
download_max_quality_yt_video() {
  yt-dlp -f "bv*+ba" --merge-output-format mkv "$1"
}

## Voxel Max

# Rename input to output, pack it with tyt, and commit it as release version.
vmax_release() {
  local input="$1" output="$2" version="$3"

  if [[ -z "$input" || -z "$output" || -z "$version" ]]; then
    echo "usage: vmax_release <input-file> <output-file> <version>" >&2
    return 1
  fi

  rm -rf "$output" && \
  mv "$input" "$output" && \
  tyt vmax pack "$output" && \
  git add "$output" && \
  git commit -m "feat(assets): $output $version"
}
