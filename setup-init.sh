#!/bin/bash

set -euo pipefail

DOTFILES_REPO="git@github.com:anunayasri/dotfiles.git"
DOTFILES_DIR="$HOME/workspace/dotfiles"
BREWFILE="$DOTFILES_DIR/Brewfile"
CONFIG_DIR="$HOME/.config"

log() { echo -e "👉 $1"; }
success() { echo -e "✅ $1"; }
fail() { echo -e "❌ $1"; }

install_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && success "Homebrew installed."
  else
    success "Homebrew already installed."
  fi
}

install_git() {
  if ! command -v git >/dev/null 2>&1; then
    log "Installing Git via Homebrew..."
    brew install git && success "Git installed."
  else
    success "Git already installed."
  fi
}

configure_git() {
  log "Configuring Git username and email..."

  if [[ -n "${GIT_USERNAME:-}" && -n "${GIT_EMAIL:-}" ]]; then
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"
    success "Configured Git with username '$GIT_USERNAME' and email '$GIT_EMAIL'"
  else
    fail "GIT_USERNAME or GIT_EMAIL not set. Please export them and rerun the script, or configure Git manually:"
    echo "  git config --global user.name \"Your Name\""
    echo "  git config --global user.email \"your@email.com\""
  fi
}

clone_dotfiles() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    success "Dotfiles repo already cloned at $DOTFILES_DIR"
  else
    log "Cloning dotfiles repo to $DOTFILES_DIR..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" && success "Dotfiles repo cloned."
  fi
}

run_brew_bundle() {
  if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    log "Running brew bundle..."
    brew bundle --file="$DOTFILES_DIR/Brewfile" && success "Brew bundle completed."
  else
    fail "Brewfile not found in $DOTFILES_DIR"
  fi
}

create_symlinks() {
  log "Creating symlinks for dotfiles..."

  if [ ! -d $CONFIG_DIR ]; then
      mkdir $CONFIG_DIR
  fi

  declare -a SYMLINKS=(
    "$DOTFILES_DIR/.shellrc:$HOME/.shellrc"
    "$DOTFILES_DIR/.zshrc:$HOME/.zshrc"
    "$DOTFILES_DIR/tmux:$CONFIG_DIR/tmux"
    "$DOTFILES_DIR/vifm:$CONFIG_DIR/vifm"
    "$DOTFILES_DIR/alacritty:$CONFIG_DIR/alacritty"
    "$DOTFILES_DIR/nvim:$CONFIG_DIR/nvim"
    "$DOTFILES_DIR/git:$CONFIG_DIR/git"
  )

  for pair in "${SYMLINKS[@]}"; do
    IFS=":" read -r SOURCE TARGET <<< "$pair"
    if [ -L "$TARGET" ]; then
      success "Symlink already exists: $TARGET → $(readlink "$TARGET")"
    elif [ -e "$TARGET" ]; then
      fail "Skipping: $TARGET already exists and is not a symlink."
    else
      mkdir -p "$(dirname "$TARGET")"
      ln -s "$SOURCE" "$TARGET"
      success "Created symlink: $TARGET → $SOURCE"
    fi
  done
}

configure_mac_settings() {
  log "Configuring macOS settings..."

  defaults write com.apple.dock orientation -string right
  success "Moved Dock to the right"

  defaults write com.apple.dock tilesize -int 48
  success "Set Dock icon size to 48px"

  defaults write com.apple.dock minimize-to-application -bool true
  success "Enabled minimize-to-application"

  defaults write com.apple.dock persistent-apps -array
  success "Cleared default Dock icons"

  defaults write com.apple.dock autohide -bool true
  success "Enabled Dock auto-hide"

  killall Dock
  success "Restarted Dock to apply changes"
}


main() {
  install_homebrew
  install_git
  configure_git
  clone_dotfiles
  run_brew_bundle
  create_symlinks
  configure_mac_settings
}

main "$@"
