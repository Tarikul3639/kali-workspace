# ╔══════════════════════════════════════════════════════════════╗
# ║           tarikul3639@kali — ZSH Configuration              ║
# ║           Backend Engineer | Security Researcher             ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Performance: Skip global compinit ─────────────────────────────────────────
skip_global_compinit=1

# ══════════════════════════════════════════════════════════════════
# 01 · ENVIRONMENT
# ══════════════════════════════════════════════════════════════════

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color
export COLORTERM=truecolor
export EDITOR=nvim
export VISUAL=nvim
export PAGER="bat --style=plain"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export GPG_TTY=$(tty)

# ── XDG Base Directories ──────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ── PATH ─────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# ── Node.js / nvm ─────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ── pnpm ──────────────────────────────────────────────────────────
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── bun ───────────────────────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ── Python ────────────────────────────────────────────────────────
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export PIP_REQUIRE_VIRTUALENV=false

# ── Docker ────────────────────────────────────────────────────────
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# ── fzf ───────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border=rounded
  --prompt="❯ "
  --pointer="▶"
  --marker="✓"
  --color=bg+:#1e2030,bg:#0d0f18,spinner:#89ddff,hl:#c3e88d
  --color=fg:#c8d3f5,header:#c3e88d,info:#89ddff,pointer:#89ddff
  --color=marker:#c3e88d,fg+:#c8d3f5,prompt:#89ddff,hl+:#c3e88d
'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# ── zoxide ────────────────────────────────────────────────────────
export _ZO_ECHO=1

# ── bat ───────────────────────────────────────────────────────────
export BAT_THEME="TwoDark"

# ── ripgrep ───────────────────────────────────────────────────────
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# ══════════════════════════════════════════════════════════════════
# 02 · ZSH OPTIONS
# ══════════════════════════════════════════════════════════════════

# Navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# Globbing
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt NO_CASE_GLOB

# Correction
setopt CORRECT
setopt CORRECT_ALL

# Misc
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt RC_QUOTES

# ── History ───────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ══════════════════════════════════════════════════════════════════
# 03 · COMPLETION
# ══════════════════════════════════════════════════════════════════

autoload -Uz compinit
# Only re-check compinit once per day for performance
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{cyan}── %d ──%f'
zstyle ':completion:*:messages' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}No matches found%f'
zstyle ':completion:*:corrections' format '%F{green}%d (errors: %e)%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"

# ══════════════════════════════════════════════════════════════════
# 04 · KEY BINDINGS
# ══════════════════════════════════════════════════════════════════

bindkey -e  # Emacs key bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' up-history
bindkey '^N' down-history

# ══════════════════════════════════════════════════════════════════
# 05 · PLUGINS
# ══════════════════════════════════════════════════════════════════

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5c6370,italic'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

PLUGIN_DIR="$HOME/.local/share/zsh/plugins"

_load_plugin() {
  local plugin_path="$PLUGIN_DIR/$1/$1.plugin.zsh"
  [[ -f "$plugin_path" ]] && source "$plugin_path"
}

_load_plugin "zsh-autosuggestions"
_load_plugin "zsh-syntax-highlighting"

# fzf shell integration
if command -v fzf &>/dev/null; then
  source <(fzf --zsh 2>/dev/null) || {
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/zsh/vendor-completions/_fzf ]] && source /usr/share/zsh/vendor-completions/_fzf
  }
fi

# zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ══════════════════════════════════════════════════════════════════
# 06 · TOOL COMPLETIONS
# ══════════════════════════════════════════════════════════════════

# kubectl
command -v kubectl &>/dev/null && source <(kubectl completion zsh)

# docker
command -v docker &>/dev/null && {
  [[ -f /usr/share/zsh/vendor-completions/_docker ]] && source /usr/share/zsh/vendor-completions/_docker
}

# npm
command -v npm &>/dev/null && source <(npm completion 2>/dev/null)

# GitHub CLI
command -v gh &>/dev/null && source <(gh completion -s zsh 2>/dev/null)

# ══════════════════════════════════════════════════════════════════
# 07 · SOURCES
# ══════════════════════════════════════════════════════════════════

[[ -f "$HOME/.aliases" ]]   && source "$HOME/.aliases"
[[ -f "$HOME/.functions" ]] && source "$HOME/.functions"
[[ -f "$HOME/.env.local" ]] && source "$HOME/.env.local"

# ══════════════════════════════════════════════════════════════════
# 08 · STARTUP BANNER
# ══════════════════════════════════════════════════════════════════

_show_banner() {
  # Only show in interactive, non-SSH, non-tmux sessions at startup
  if [[ -o interactive ]] && [[ -z "$TMUX" ]]; then
    echo ""

    # ASCII banner via figlet + lolcat
    if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
      figlet -f slant "TARIKUL" | lolcat --freq 0.3 --seed 42
    else
      echo "  ████████╗ █████╗ ██████╗ ██╗██╗  ██╗██╗   ██╗██╗     "
      echo "     ██╔══╝██╔══██╗██╔══██╗██║██║ ██╔╝██║   ██║██║     "
      echo "     ██║   ███████║██████╔╝██║█████╔╝ ██║   ██║██║     "
      echo "     ██║   ██╔══██║██╔══██╗██║██╔═██╗ ██║   ██║██║     "
      echo "     ██║   ██║  ██║██║  ██║██║██║  ██╗╚██████╔╝███████╗"
      echo "     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
    fi

    echo ""
    printf "  \033[1;32m⚡ TARIKUL ISLAM\033[0m  \033[1;36mBackend Engineer\033[0m  \033[38;5;240m│\033[0m  \033[1;35mNestJS · Next.js · Linux · Security\033[0m\n"
    printf "  \033[38;5;240m──────────────────────────────────────────────────────────\033[0m\n"
    printf "  \033[38;5;240m󰌢 \033[0m\033[38;5;245m%s\033[0m  \033[38;5;240m \033[0m\033[38;5;245m%s\033[0m  \033[38;5;240m󰅐 \033[0m\033[38;5;245m%s\033[0m\n" \
      "$(uname -r | cut -d'-' -f1)" \
      "$(uptime -p 2>/dev/null || echo 'just started')" \
      "$(date '+%a, %d %b %Y  %H:%M')"
    echo ""
  fi
}

_show_banner

# ── Fastfetch (only on first login) ───────────────────────────────
if [[ -o login ]] && command -v fastfetch &>/dev/null; then
  fastfetch
fi

# ══════════════════════════════════════════════════════════════════
# 09 · STARSHIP PROMPT (must be last)
# ══════════════════════════════════════════════════════════════════

command -v starship &>/dev/null && eval "$(starship init zsh)"
