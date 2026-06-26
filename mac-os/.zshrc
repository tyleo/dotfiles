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

# Starship
eval "$(starship init zsh)"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
export PATH="/Applications/Blender.app/Contents/MacOS:$PATH"

# Variables
gitconfig=~/.gitconfig
gitdir=~/git
downloads=~/downloads
misc=~/misc
rrnotes=$gitdir/recroom-notes
scratch=~/scratch
starshiptoml=~/.config/starship.toml
vimrc=~/.vimrc
vimdir=~/.vim
zshrc=~/.zshrc

cdg() {
  cd ~/git
}

## os

alias open='open -a ForkLift'

edit_safari_tabs_db() {
  # https://manualdousuario.net/en/how-to-remove-stuck-icloud-tabs-in-safari/
  sqlite3 ~/Library/Containers/com.apple.Safari/Data/Library/Safari/CloudTabs.db
}


## cwebp

file_to_webp() {
  cwebp "$1" -o "${1%.*}.webp"
}

file_into_webp() {
  file_to_webp "$1"
  rm "$1"
}

ext_to_webp() {
  for img in "$@"; do
    cwebp "$img" -o "${img%.*}.webp"
  done
}

ext_into_webp() {
  ext_to_webp "$@"
  rm "$@"
}

## ffmpeg

# gifify: Convert a portion of a video into a high-quality GIF.
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
#   # Full video → GIF
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

## pdfimages

extract_pdf_images() {
  local pdf_file="$1"
  local out_prefix="$2"

  if [[ -z "$pdf_file" ]]; then
    echo "usage: extract_pdf_images <pdf_file> <output_prefix>"
    return 1
  fi

  pdfimages -all "$pdf_file" "$out_prefix"
}

## yt-dlp

download_max_quality_yt_video() {
  yt-dlp -f "bv*+ba" --merge-output-format mkv "$1"
}

# Make Dock pop up instantly
set_dock_animation_speed() {
  local autohide_delay="$1"
  local autohide_time_modifier="$2"

  defaults write com.apple.dock autohide-delay -float "${autohide_delay}"
  defaults write com.apple.dock autohide-time-modifier -float "${autohide_time_modifier}"
  killall Dock
}

# Restore Dock to default animation
restore_dock_animation_speed() {
  defaults delete com.apple.dock autohide-time-modifier
  defaults delete com.apple.dock autohide-delay
  killall Dock
}

set_file_viewer_to_forklift() {
  defaults write -g NSFileViewer -string com.binarynights.ForkLift
  defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.folder";LSHandlerRoleAll="com.binarynights.ForkLift";}'
}

restore_file_viewer() {
  defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.folder";LSHandlerRoleAll="com.apple.finder";}'
  defaults delete -g NSFileViewer
}

reload_monitors() {
  sudo killall -HUP corebrightnessd
  sudo killall -HUP WindowServer
}

reload_zshrc() {
  source ~/.zshrc
  echo "✅ Reloaded ~/.zshrc"
}

wake_desktop() {
  wakeonlan 4C:D7:17:9E:59:39
}

# Unity RAM disk helpers
# RAM disk name: {cwdName}RAM  e.g. /path/MyGame -> /Volumes/MyGameRAM

unity_ram_on() {
  setopt localoptions err_return pipefail nounset

  local size_gb=${1:-32}   # ✅ Default 32 GB now
  local base_dir=$PWD
  local vol_name="$(basename "$base_dir")RAM"
  local mount_dir="/Volumes/${vol_name}"
  local -a rel_paths=("Assets" "Dependencies" "Library/ScriptAssemblies" "Library/PackageCache")

  echo "💾 Creating ${size_gb}GB RAM disk at ${mount_dir} ..."

  if [[ -d "$mount_dir" ]]; then
    echo "ℹ️  RAM disk already mounted at ${mount_dir}; reusing."
  else
    local blocks=$(( size_gb * 2097152 ))
    local device
    device="$(hdiutil attach -nomount "ram://${blocks}" | awk 'NR==1{print $1}')"
    [[ -n "$device" ]] || { echo "❌ Failed to allocate RAM device."; return 1 }
    diskutil erasevolume HFS+ "$vol_name" "$device" >/dev/null
    [[ -d "$mount_dir" ]] || { echo "❌ Failed to mount RAM disk at ${mount_dir}."; return 1 }
  fi

  local rp src dst cur
  for rp in "${rel_paths[@]}"; do
    src="${base_dir}/${rp}"
    dst="${mount_dir}/${rp}"

    if [[ -L "$src" ]]; then
      cur="$(readlink "$src")"
      if [[ "$cur" == "$dst" ]]; then
        echo "↔️  ${rp} already linked to RAM; skipping."
        continue
      else
        echo "❌ ${rp} is a symlink to '${cur}', not '${dst}'. Refusing to change it."
        return 1
      fi
    fi

    if [[ -e "$src" ]]; then
      echo "→ Copying ${rp} ..."
      mkdir -p "$(dirname "$dst")" "$dst"
      rsync -a "${src}/" "${dst}/"
      echo "→ Linking ${rp} → ${dst}"
      rm -rf "$src"
      ln -s "$dst" "$src"
    else
      echo "🆕 ${rp} missing locally — creating on RAM disk and linking."
      mkdir -p "$(dirname "$dst")" "$dst"
      ln -s "$dst" "$src"
    fi
  done

  echo "✅ RAM disk ready: ${mount_dir}"
}

unity_ram_off() {
  setopt localoptions err_return pipefail nounset

  local base_dir=$PWD
  local vol_name="$(basename "$base_dir")RAM"
  local mount_dir="/Volumes/${vol_name}"
  local -a rel_paths=("Assets" "Dependencies" "Library/ScriptAssemblies" "Library/PackageCache")

  [[ -d "$mount_dir" ]] || { echo "❌ RAM disk not mounted at ${mount_dir}."; return 1 }

  local rp link_path src_on_ram cur
  for rp in "${rel_paths[@]}"; do
    link_path="${base_dir}/${rp}"
    src_on_ram="${mount_dir}/${rp}"

    if [[ -L "$link_path" ]]; then
      cur="$(readlink "$link_path")"
      if [[ "$cur" != "$src_on_ram" ]]; then
        echo "❌ ${rp} link points to '${cur}', not '${src_on_ram}'. Aborting to avoid data loss."
        return 1
      fi
      echo "→ Restoring ${rp} from RAM ..."
      rm "$link_path"
      mkdir -p "$link_path"
      if [[ -d "$src_on_ram" ]]; then
        rsync -a "${src_on_ram}/" "${link_path}/"
      else
        echo "⚠️  Nothing to restore for ${rp}."
      fi
    elif [[ -e "$link_path" ]]; then
      echo "ℹ️  ${rp} is a real directory already; skipping."
    else
      if [[ -d "$src_on_ram" ]]; then
        echo "→ Recreating ${rp} from RAM ..."
        mkdir -p "$link_path"
        rsync -a "${src_on_ram}/" "${link_path}/"
      else
        echo "⚠️  Skipping ${rp}; not present locally or on RAM."
      fi
    fi
  done

  echo "⏏️  Unmounting ${mount_dir} ..."
  diskutil unmount "$mount_dir" >/dev/null || { echo "❌ Unmount failed."; return 1; }
  local device
  device="$(mount | awk -v m="${mount_dir}" '$0 ~ m {print $1; exit}')"
  if [[ -n "$device" ]]; then
    hdiutil detach "$device" >/dev/null || { echo "❌ Detach failed for ${device}."; return 1; }
  else
    echo "⚠️  Couldn’t identify device; it may already be detached."
  fi

  echo "✅ RAM disk ${vol_name} removed."
}

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


vmax-release() {
  local input="$1" output="$2" version="$3"

  if [[ -z "$input" || -z "$output" || -z "$version" ]]; then
    echo "usage: vmax-release <input-file> <output-file> <version>" >&2
    return 1
  fi

  rm -rf "$output" && \
  mv "$input" "$output" && \
  tyt vmax pack "$output" && \
  git add "$output" && \
  git commit -m "feat(assets): $output $version"
}
