#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   setup.sh — Kali Hacker Workstation                        ║
# ║   tarikul3639@kali                                          ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { printf "${GREEN}  ✓  ${RESET}%s\n" "$1"; }
info() { printf "${CYAN}  ●  ${RESET}%s\n" "$1"; }
warn() { printf "${YELLOW}  ⚠  ${RESET}%s\n" "$1"; }
fail() { printf "${RED}  ✗  ${RESET}%s\n" "$1"; }
step() { echo ""; printf "${BOLD}${CYAN}══ %s ══${RESET}\n" "$1"; echo ""; }

# ══════════════════════════════════════════════════════════════════
# STEP 1: APT PACKAGES
# ══════════════════════════════════════════════════════════════════
step "01 · System Packages"

sudo apt update -qq

APT_PACKAGES=(
  zsh git curl wget unzip zip tar
  figlet lolcat neovim tmux htop btop jq
  ripgrep fd-find bat fzf zoxide eza delta
  xclip nmap netcat-traditional whois dnsutils
  python3 python3-pip python3-venv
  docker.io docker-compose
)

for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    ok "$pkg (already installed)"
  else
    info "Installing $pkg..."
    sudo apt install -y "$pkg" -qq && ok "$pkg" || warn "Failed: $pkg"
  fi
done

if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  mkdir -p ~/.local/bin
  ln -sf "$(which batcat)" ~/.local/bin/bat
  ok "bat symlink created"
fi

if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  mkdir -p ~/.local/bin
  ln -sf "$(which fdfind)" ~/.local/bin/fd
  ok "fd symlink created"
fi

# ══════════════════════════════════════════════════════════════════
# STEP 2: ZSH PLUGINS
# ══════════════════════════════════════════════════════════════════
step "02 · ZSH Plugins"

PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

clone_or_update_plugin() {
  local repo="$1" name="$2"
  local dir="$PLUGIN_DIR/$name"
  if [[ -d "$dir" ]]; then
    git -C "$dir" pull -q && ok "$name updated"
  else
    git clone --depth=1 "https://github.com/$repo" "$dir" -q && ok "$name installed"
  fi
}

clone_or_update_plugin "zsh-users/zsh-autosuggestions"    "zsh-autosuggestions"
clone_or_update_plugin "zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"

# ══════════════════════════════════════════════════════════════════
# STEP 3: STARSHIP
# ══════════════════════════════════════════════════════════════════
step "03 · Starship Prompt"

if command -v starship &>/dev/null; then
  ok "Starship already installed: $(starship --version)"
else
  info "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  ok "Starship installed"
fi

mkdir -p "$HOME/.config"
cp "$(dirname "$0")/configs/starship.toml" "$HOME/.config/starship.toml"
ok "starship.toml installed"

# ══════════════════════════════════════════════════════════════════
# STEP 4: FASTFETCH
# ══════════════════════════════════════════════════════════════════
step "04 · Fastfetch"

if command -v fastfetch &>/dev/null; then
  ok "Fastfetch already installed: $(fastfetch --version)"
else
  info "Installing Fastfetch..."
  FASTFETCH_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
    | jq -r '.assets[] | select(.name | test("linux-amd64.deb")) | .browser_download_url' \
    | head -1)
  if [[ -n "$FASTFETCH_URL" ]]; then
    wget -qO /tmp/fastfetch.deb "$FASTFETCH_URL"
    sudo dpkg -i /tmp/fastfetch.deb && ok "Fastfetch installed" || sudo apt install -f -y
  else
    warn "Could not auto-download Fastfetch"
  fi
fi

mkdir -p "$HOME/.config/fastfetch"
cp "$(dirname "$0")/configs/fastfetch-config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
ok "Fastfetch config installed"

# ══════════════════════════════════════════════════════════════════
# STEP 5: NVM + NODE
# ══════════════════════════════════════════════════════════════════
step "05 · Node.js via NVM"

if [[ -d "$HOME/.nvm" ]]; then
  ok "NVM already installed"
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  ok "NVM installed"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

if command -v node &>/dev/null; then
  ok "Node.js: $(node --version)"
else
  nvm install --lts && nvm use --lts && nvm alias default node
  ok "Node.js LTS installed"
fi

command -v pnpm &>/dev/null && ok "pnpm: $(pnpm --version)" || { npm install -g pnpm -q && ok "pnpm installed"; }
command -v bun  &>/dev/null && ok "bun: $(bun --version)"   || { curl -fsSL https://bun.sh/install | bash && ok "bun installed"; }

# ══════════════════════════════════════════════════════════════════
# STEP 6: DOTFILES
# ══════════════════════════════════════════════════════════════════
step "06 · Dotfiles"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CONFIG_DIR="$SCRIPT_DIR/configs"

backup_and_copy() {
  local src="$1" dst="$2"
  [[ -f "$dst" ]] && cp "$dst" "${dst}.bak.$(date +%Y%m%d_%H%M%S)" && warn "Backed up: $dst"
  cp "$src" "$dst" && ok "Installed: $dst"
}

backup_and_copy "$CONFIG_DIR/.zshrc"             "$HOME/.zshrc"
backup_and_copy "$CONFIG_DIR/.aliases"           "$HOME/.aliases"
backup_and_copy "$CONFIG_DIR/.functions"         "$HOME/.functions"
backup_and_copy "$CONFIG_DIR/.gitconfig"         "$HOME/.gitconfig"
backup_and_copy "$CONFIG_DIR/.gitignore_global"  "$HOME/.gitignore_global"

# ══════════════════════════════════════════════════════════════════
# STEP 7: FIX ALIAS/FUNCTION CONFLICTS (auto)
# ══════════════════════════════════════════════════════════════════
step "07 · Fix Alias/Function Conflicts"

# These aliases conflict with same-named functions in .functions
CONFLICT_ALIASES=("sizeof" "serve" "extract")

for alias_name in "${CONFLICT_ALIASES[@]}"; do
  if grep -q "^alias ${alias_name}=" "$HOME/.aliases" 2>/dev/null; then
    sed -i "/^alias ${alias_name}=/d" "$HOME/.aliases"
    ok "Removed conflicting alias: $alias_name (function takes priority)"
  else
    ok "No conflict: $alias_name"
  fi
done

# ══════════════════════════════════════════════════════════════════
# STEP 8: FONT
# ══════════════════════════════════════════════════════════════════
step "08 · JetBrains Mono Nerd Font"

FONT_DIR="$HOME/.local/share/fonts"
if ls "$FONT_DIR"/JetBrains* &>/dev/null 2>&1; then
  ok "JetBrains Mono Nerd Font already installed"
else
  mkdir -p "$FONT_DIR"
  wget -qO /tmp/JetBrainsMono.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -q /tmp/JetBrainsMono.zip -d "$FONT_DIR/JetBrainsMono"
  fc-cache -f -q
  ok "JetBrains Mono Nerd Font installed"
fi

# ══════════════════════════════════════════════════════════════════
# STEP 9: GNOME TERMINAL
# ══════════════════════════════════════════════════════════════════
step "09 · GNOME Terminal Profile"

if command -v dconf &>/dev/null; then
  PROFILE_ID=$(dconf list /org/gnome/terminal/legacy/profiles:/ | head -1 | tr -d '/:')
  if [[ -n "$PROFILE_ID" ]]; then
    BASE="/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}"
    dconf write "${BASE}/use-system-font"                  "false"
    dconf write "${BASE}/font"                             "'JetBrainsMono Nerd Font 11'"
    dconf write "${BASE}/use-transparent-background"       "true"
    dconf write "${BASE}/background-transparency-percent"  "10"
    dconf write "${BASE}/background-color"                 "'#0D0F18'"
    dconf write "${BASE}/foreground-color"                 "'#C8D3F5'"
    dconf write "${BASE}/cursor-blink-mode"                "'on'"
    dconf write "${BASE}/cursor-shape"                     "'block'"
    dconf write "${BASE}/cursor-foreground-color"          "'#0D0F18'"
    dconf write "${BASE}/cursor-background-color"          "'#89DDFF'"
    dconf write "${BASE}/scrollbar-policy"                 "'never'"
    dconf write "${BASE}/scrollback-unlimited"             "true"
    dconf write "${BASE}/audible-bell"                     "false"
    dconf write "${BASE}/use-theme-colors"                 "false"
    dconf write "${BASE}/palette" "['#1A1B26', '#FF5370', '#C3E88D', '#FFCB6B', '#82AAFF', '#C792EA', '#89DDFF', '#C8D3F5', '#4A4F6A', '#FF6B7A', '#C8E6A0', '#FFD580', '#9ABBFF', '#D6ACFF', '#A0E0EE', '#FFFFFF']"
    ok "GNOME Terminal profile configured"
  else
    warn "No GNOME Terminal profile found"
  fi
else
  warn "dconf not found — skipping"
fi

# ══════════════════════════════════════════════════════════════════
# STEP 10: DEFAULT SHELL
# ══════════════════════════════════════════════════════════════════
step "10 · Set Default Shell"

if [[ "$SHELL" == "$(which zsh)" ]]; then
  ok "ZSH is already the default shell"
else
  chsh -s "$(which zsh)" && ok "ZSH set as default shell"
fi

# ══════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}${BOLD}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   Setup Complete!                               ║"
echo "  ║   Restart your terminal or run: exec zsh        ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${RESET}"