#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   setup.sh — Kali Hacker Workstation                        ║
# ║   tarikul3639@kali                                          ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────
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
  zsh
  git
  curl
  wget
  unzip
  zip
  tar
  figlet
  lolcat
  neovim
  tmux
  htop
  btop
  jq
  ripgrep
  fd-find
  bat
  fzf
  zoxide
  eza
  delta
  xclip
  nmap
  netcat-traditional
  whois
  dnsutils
  python3
  python3-pip
  python3-venv
  docker.io
  docker-compose
)

for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    ok "$pkg (already installed)"
  else
    info "Installing $pkg..."
    sudo apt install -y "$pkg" -qq && ok "$pkg" || warn "Failed: $pkg"
  fi
done

# ── Fix bat symlink (Debian names it batcat) ─────────────────────
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  mkdir -p ~/.local/bin
  ln -sf "$(which batcat)" ~/.local/bin/bat
  ok "bat symlink created"
fi

# ── Fix fd symlink (Debian names it fdfind) ──────────────────────
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  mkdir -p ~/.local/bin
  ln -sf "$(which fdfind)" ~/.local/bin/fd
  ok "fd symlink created"
fi

# ══════════════════════════════════════════════════════════════════
# STEP 2: ZSH PLUGINS (no oh-my-zsh)
# ══════════════════════════════════════════════════════════════════
step "02 · ZSH Plugins"

PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

clone_or_update_plugin() {
  local repo="$1"
  local name="$2"
  local dir="$PLUGIN_DIR/$name"
  if [[ -d "$dir" ]]; then
    git -C "$dir" pull -q && ok "$name updated"
  else
    git clone --depth=1 "https://github.com/$repo" "$dir" -q && ok "$name installed"
  fi
}

clone_or_update_plugin "zsh-users/zsh-autosuggestions"   "zsh-autosuggestions"
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
  # Get latest release from GitHub
  FASTFETCH_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
    | jq -r '.assets[] | select(.name | test("linux-amd64.deb")) | .browser_download_url' \
    | head -1)
  if [[ -n "$FASTFETCH_URL" ]]; then
    wget -qO /tmp/fastfetch.deb "$FASTFETCH_URL"
    sudo dpkg -i /tmp/fastfetch.deb && ok "Fastfetch installed" || {
      warn "dpkg failed, trying apt fix..."
      sudo apt install -f -y
    }
  else
    warn "Could not auto-download Fastfetch. Install manually from: https://github.com/fastfetch-cli/fastfetch/releases"
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
  info "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  ok "NVM installed"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

if command -v node &>/dev/null; then
  ok "Node.js: $(node --version)"
else
  info "Installing Node.js LTS..."
  nvm install --lts && nvm use --lts && nvm alias default node
  ok "Node.js LTS installed"
fi

# ── pnpm ──────────────────────────────────────────────────────────
if command -v pnpm &>/dev/null; then
  ok "pnpm: $(pnpm --version)"
else
  info "Installing pnpm..."
  npm install -g pnpm -q && ok "pnpm installed"
fi

# ── bun ───────────────────────────────────────────────────────────
if command -v bun &>/dev/null; then
  ok "bun: $(bun --version)"
else
  info "Installing bun..."
  curl -fsSL https://bun.sh/install | bash && ok "bun installed"
fi

# ══════════════════════════════════════════════════════════════════
# STEP 6: DOTFILES
# ══════════════════════════════════════════════════════════════════
step "06 · Dotfiles"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CONFIG_DIR="$SCRIPT_DIR/configs"

backup_and_copy() {
  local src="$1"
  local dst="$2"
  if [[ -f "$dst" ]]; then
    cp "$dst" "${dst}.bak.$(date +%Y%m%d_%H%M%S)"
    warn "Backed up existing $dst"
  fi
  cp "$src" "$dst" && ok "Installed: $dst"
}

backup_and_copy "$CONFIG_DIR/.zshrc"          "$HOME/.zshrc"
backup_and_copy "$CONFIG_DIR/.aliases"        "$HOME/.aliases"
backup_and_copy "$CONFIG_DIR/.functions"      "$HOME/.functions"
backup_and_copy "$CONFIG_DIR/.gitconfig"      "$HOME/.gitconfig"
backup_and_copy "$CONFIG_DIR/.gitignore_global" "$HOME/.gitignore_global"

# ══════════════════════════════════════════════════════════════════
# STEP 7: FONT CHECK
# ══════════════════════════════════════════════════════════════════
step "07 · JetBrains Mono Nerd Font"

FONT_DIR="$HOME/.local/share/fonts"
if ls "$FONT_DIR"/JetBrains* &>/dev/null 2>&1; then
  ok "JetBrains Mono Nerd Font already installed"
else
  info "Downloading JetBrains Mono Nerd Font..."
  mkdir -p "$FONT_DIR"
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  wget -qO /tmp/JetBrainsMono.zip "$FONT_URL"
  unzip -q /tmp/JetBrainsMono.zip -d "$FONT_DIR/JetBrainsMono"
  fc-cache -fv
  ok "JetBrains Mono Nerd Font installed"
fi

# ══════════════════════════════════════════════════════════════════
# STEP 8: GNOME TERMINAL PROFILE (dconf)
# ══════════════════════════════════════════════════════════════════
step "08 · GNOME Terminal Profile"

if command -v dconf &>/dev/null; then
  PROFILE_ID=$(dconf list /org/gnome/terminal/legacy/profiles:/ | head -1 | tr -d '/:')
  if [[ -n "$PROFILE_ID" ]]; then
    BASE="/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}"
    dconf write "${BASE}/use-system-font"             "false"
    dconf write "${BASE}/font"                        "'JetBrainsMono Nerd Font 13'"
    dconf write "${BASE}/use-transparent-background"  "true"
    dconf write "${BASE}/background-transparency-percent" "10"
    dconf write "${BASE}/background-color"            "'#0D0F18'"
    dconf write "${BASE}/foreground-color"            "'#C8D3F5'"
    dconf write "${BASE}/cursor-blink-mode"           "'on'"
    dconf write "${BASE}/cursor-shape"                "'block'"
    dconf write "${BASE}/cursor-foreground-color"     "'#0D0F18'"
    dconf write "${BASE}/cursor-background-color"     "'#89DDFF'"
    dconf write "${BASE}/scrollbar-policy"            "'never'"
    dconf write "${BASE}/scrollback-unlimited"        "true"
    dconf write "${BASE}/audible-bell"                "false"
    dconf write "${BASE}/use-theme-colors"            "false"
    # Palette: Tokyo Night inspired (16 colors)
    dconf write "${BASE}/palette" "['#1A1B26', '#FF5370', '#C3E88D', '#FFCB6B', '#82AAFF', '#C792EA', '#89DDFF', '#C8D3F5', '#4A4F6A', '#FF6B7A', '#C8E6A0', '#FFD580', '#9ABBFF', '#D6ACFF', '#A0E0EE', '#FFFFFF']"
    ok "GNOME Terminal profile configured"
  else
    warn "No GNOME Terminal profile found — skipping"
  fi
else
  warn "dconf not found — skipping GNOME Terminal config"
fi

# ══════════════════════════════════════════════════════════════════
# STEP 9: ZSH AS DEFAULT SHELL
# ══════════════════════════════════════════════════════════════════
step "09 · Set Default Shell"

if [[ "$SHELL" == "$(which zsh)" ]]; then
  ok "ZSH is already the default shell"
else
  info "Setting ZSH as default shell..."
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
