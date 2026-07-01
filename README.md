# ⚡ Kali Hacker Workstation — tarikul3639@kali

> Minimal · Modern · Professional · Green Hacker Aesthetic

---

## 📁 File Structure

```
kali-setup/
├── setup.sh                      ← Run this first
└── configs/
    ├── .zshrc                    → ~/.zshrc
    ├── .aliases                  → ~/.aliases
    ├── .functions                → ~/.functions
    ├── .gitconfig                → ~/.gitconfig
    ├── .gitignore_global         → ~/.gitignore_global
    ├── starship.toml             → ~/.config/starship.toml
    └── fastfetch-config.jsonc    → ~/.config/fastfetch/config.jsonc
```

---

## 🚀 Installation (One Command)

```bash
git clone https://github.com/tarikul3639/kali-workspace ~/kali-workspace
cd ~/kali-workspace
chmod +x setup.sh
./setup.sh
```

Or manually, step by step:

---

## 🔧 Manual Step-by-Step Setup

### Step 1 — Core APT Packages

```bash
sudo apt update && sudo apt install -y \
  zsh git curl wget unzip zip tar \
  figlet lolcat neovim tmux \
  htop btop jq \
  ripgrep fd-find bat fzf zoxide eza \
  xclip nmap \
  python3 python3-pip python3-venv \
  docker.io docker-compose
```

Fix Debian symlinks:

```bash
# bat
mkdir -p ~/.local/bin
ln -sf $(which batcat) ~/.local/bin/bat

# fd
ln -sf $(which fdfind) ~/.local/bin/fd
```

### Step 2 — ZSH Plugins (no oh-my-zsh)

```bash
PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
  "$PLUGIN_DIR/zsh-autosuggestions"

git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
  "$PLUGIN_DIR/zsh-syntax-highlighting"
```

### Step 3 — Starship Prompt

```bash
curl -sS https://starship.rs/install.sh | sh

mkdir -p ~/.config
cp configs/starship.toml ~/.config/starship.toml
```

### Step 4 — Fastfetch

```bash
# Option A: via apt (may be older version)
sudo apt install fastfetch

# Option B: latest release from GitHub
LATEST=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
  | jq -r '.assets[] | select(.name | test("linux-amd64.deb")) | .browser_download_url')
wget -O /tmp/fastfetch.deb "$LATEST"
sudo dpkg -i /tmp/fastfetch.deb

mkdir -p ~/.config/fastfetch
cp configs/fastfetch-config.jsonc ~/.config/fastfetch/config.jsonc
```

### Step 5 — NVM + Node.js

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.nvm/nvm.sh

nvm install --lts
nvm use --lts
nvm alias default node

npm install -g pnpm
curl -fsSL https://bun.sh/install | bash
```

### Step 6 — JetBrains Mono Nerd Font

```bash
mkdir -p ~/.local/share/fonts
wget -qO /tmp/JetBrainsMono.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -f
```

Then in GNOME Terminal: Preferences → Profile → Custom font → **JetBrainsMono Nerd Font 13**

### Step 7 — git-delta

```bash
# Install via cargo (recommended)
cargo install git-delta

# Or via apt
sudo apt install delta

# Or download from GitHub
DELTA_URL=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest \
  | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl.tar.gz")) | .browser_download_url')
wget -qO /tmp/delta.tar.gz "$DELTA_URL"
tar -xzf /tmp/delta.tar.gz -C /tmp
sudo mv /tmp/delta-*/delta /usr/local/bin/
```

### Step 8 — Dotfiles

```bash
cp configs/.zshrc              ~/.zshrc
cp configs/.aliases            ~/.aliases
cp configs/.functions          ~/.functions
cp configs/.gitconfig          ~/.gitconfig
cp configs/.gitignore_global   ~/.gitignore_global
```

### Step 9 — Set ZSH as Default

```bash
chsh -s $(which zsh)
```

### Step 10 — GNOME Terminal (manual or via dconf)

```bash
# Get your profile ID
PROFILE=$(dconf list /org/gnome/terminal/legacy/profiles:/ | head -1 | tr -d '/:')
BASE="/org/gnome/terminal/legacy/profiles:/:${PROFILE}"

dconf write "${BASE}/font"                  "'JetBrainsMono Nerd Font 13'"
dconf write "${BASE}/use-system-font"       "false"
dconf write "${BASE}/background-color"      "'#0D0F18'"
dconf write "${BASE}/foreground-color"      "'#C8D3F5'"
dconf write "${BASE}/cursor-shape"          "'block'"
dconf write "${BASE}/cursor-background-color" "'#89DDFF'"
dconf write "${BASE}/scrollbar-policy"      "'never'"
dconf write "${BASE}/scrollback-unlimited"  "true"
dconf write "${BASE}/audible-bell"          "false"
dconf write "${BASE}/use-transparent-background" "true"
dconf write "${BASE}/background-transparency-percent" "10"
```

### Step 11 — Apply Everything

```bash
exec zsh
```

### If face npm or node not found, run:
```bash
nvm use 24 # 24 is the latest LTS version as of 2024-06
```

---

## 🎨 Prompt Preview

```
╭─ 󰌽 tarikul3639@kali  ~/Projects/ClassFlow  󰊢 main ✓   󰎙 v22   3.13  🐳 Docker  14:32
│ 
╰─❯ 
```

---

## 📦 What's Included

### Aliases (key ones)

| Alias | Command |
|-------|---------|
| `ll` | `eza --icons --long --git` |
| `gs` | `git status` |
| `gp` | `git push` |
| `gpl` | `git pull` |
| `gco` | `git checkout` |
| `update` | `sudo apt update` |
| `upgrade` | Full system upgrade |
| `ports` | `ss -tulnp` |
| `myip` | External IP |
| `cls` | `clear` |
| `reload` | `exec zsh` |
| `serve` | Python HTTP server |
| `docker-clean` | Remove all Docker data |
| `k` | `kubectl` |
| `v` | `nvim` |

### Functions (key ones)

| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create and enter directory |
| `backup <file>` | Timestamped file backup |
| `extract <archive>` | Universal archive extractor |
| `weather [city]` | Weather info (default: Dhaka) |
| `killport <port>` | Kill process on port |
| `findport <port>` | Show what's on a port |
| `serve [port]` | Quick HTTP server |
| `json [file]` | Pretty print JSON |
| `git-clean` | Remove merged branches |
| `gcommit` | Interactive conventional commit |
| `scannet <target>` | nmap quick scan |
| `hashtype <hash>` | Identify hash type |
| `sysinfo` | System overview |
| `please` | Repeat last command as sudo |

### Git Aliases

| Alias | Description |
|-------|-------------|
| `git s` | Short status |
| `git l` | Graph log |
| `git wip` | Quick WIP commit |
| `git feat "msg"` | `feat: msg` commit |
| `git fix "msg"` | `fix: msg` commit |
| `git sync` | Fetch + pull rebase |
| `git gone` | Delete remote-gone branches |
| `git branches` | Sorted branch list |

---

## 🔒 Security Notes

- No insecure shell options enabled
- No `eval` of untrusted input
- Passwords/keys never stored in shell history (prefix command with space)
- `.env` files in global gitignore

---

## 🛠 Troubleshooting

**Prompt shows boxes/question marks:**
→ Make sure JetBrains Mono Nerd Font is set in terminal

**Starship not loading:**
→ Run `which starship` — if missing, reinstall: `curl -sS https://starship.rs/install.sh | sh`

**bat shows as batcat:**
→ Run: `ln -sf $(which batcat) ~/.local/bin/bat`

**zsh-autosuggestions not working:**
→ Check: `ls ~/.local/share/zsh/plugins/zsh-autosuggestions/`

**No color in terminal:**
→ Ensure `TERM=xterm-256color` and `COLORTERM=truecolor` are set

**Delta not found:**
→ Install via: `sudo apt install delta` or `cargo install git-delta`
