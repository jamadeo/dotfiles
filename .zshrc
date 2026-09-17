set -o vi
bindkey -v

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=1

# # Better searching in command mode
# bindkey -M vicmd '?' history-incremental-search-backward
# bindkey -M vicmd '/' history-incremental-search-forward

# Beginning search with arrow keys
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search

# bindkey -M viins '^[' vi-cmd-mode


typeset -U path PATH

path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/opt/homebrew/opt/coreutils/libexec/gnubin"
  $path
)

export PATH

# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

export EDITOR="vim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R"

# ------
# tools
# ------
. "$HOME/.cargo/env"

# ------------------------------------------------------------
# History
# ------------------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000000
SAVEHIST=5000000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# ------------------------------------------------------------
# Shell behavior
# ------------------------------------------------------------

setopt AUTO_CD
# setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' squeeze-slashes true

_comp_options+=(globdots)

# ------------------------------------------------------------
# Prompt
# ------------------------------------------------------------

autoload -Uz vcs_info

zstyle ':vcs_info:git:*' formats ' %F{cyan}(%b)%f'
zstyle ':vcs_info:*' enable git

precmd() {
  vcs_info
}

autoload -Uz add-zsh-hook

git_stack_prompt() {
  local branch base old_base new_base

  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || return
  base=$(git config --get "branch.${branch}.stack-base" 2>/dev/null) || return
  old_base=$(git config --get "branch.${branch}.stack-base-commit" 2>/dev/null) || return
  new_base=$(git rev-parse --verify "${base}^{commit}" 2>/dev/null) || return

  if [[ "$old_base" == "$new_base" ]]; then
    print -r -- "%F{#48b79f} ↳ ${base}%f"
  else
    print -r -- "%F{red} ↳ ${base} ⇡%f"
  fi
}

hermit_prompt() {
  if [[ -n "$HERMIT_ENV" ]]; then
    print -r -- "🐚 "
  fi
}

_custom_prompt_precmd() {
  GIT_STACK_PROMPT="$(git_stack_prompt)"
  HERMIT_PROMPT="$(hermit_prompt)"
}

add-zsh-hook precmd _custom_prompt_precmd

setopt prompt_subst

PROMPT='${HERMIT_PROMPT}%F{blue}%~%f${vcs_info_msg_0_}${GIT_STACK_PROMPT} %F{yellow}❯%f '

# ------------------------------------------------------------
# Keybindings
# ------------------------------------------------------------

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[3~' delete-char

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

alias l='ls -ltraG'

# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------

mkcd() {
  mkdir -p "$1" && cd "$1"
}

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "Don't know how to extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ------------------------------------------------------------
# Optional integrations
# ------------------------------------------------------------

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
fi

# # Syntax highlighting should be near the end.
# if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
#   source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# fi

# if [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
#   source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
