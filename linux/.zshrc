export PATH="$HOME/.local/bin:$PATH"
source ~/bin/wsl-ssh-agent-relay.sh
unsetopt beep

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# keep prompt at the bottom of the terminal
printf '\n%.0s' {1..$LINES}

# Update starship config for WSL mounted path module
# ~/bin/update-starship-config.sh

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH

# History
# HISTSIZE=5000
# HISTFILE=~/.zsh_history
# SAVEHIST=$HISTSIZE
# HISTDUP=erase
# setopt appendhistory
# setopt sharehistory
# # setopt hist_ignore_space
# setopt hist_ignore_all_dups
# setopt hist_save_no_dups
# setopt hist_ignore_dups
# setopt hist_find_no_dups


export dotfiles="$HOME/dotfiles"

alias clip='xclip -selection clipboard'
alias vi='nvim'
alias vid='cd $HOME/.config/nvim'
alias lg='lazygit'
alias wh='which'
alias ls='eza --icons -l'
alias lsa='eza --icons -la'
alias lst='eza --icons -lT'
alias lsat='eza --icons -laT'
alias dot='cd $HOME/dotfiles'
alias gitcfg='git config --global -e'
alias zf="__zoxide_zi"

## Quick edit functions for various config files
function edit-wezterm-profile() {
  nvim "$dotfiles/.wezterm.lua"
}

function edit-lazygit-config() {
  nvim "$HOME/.config/lazygit/config.yml"
}

function edit-tmux-config() {
  nvim "$HOME/.tmux.conf"
}

function edit-zshrc() {
  nvim "$HOME/.zshrc"
}

# Edit aliases
alias wzcfg='edit-wezterm-profile'
alias lgcfg='edit-lazygit-config'
alias tmcfg='edit-tmux-config'
alias zscfg='edit-zshrc'

## Utility functions
function start-nvim-bug-repro() {
  local config_path="$HOME/dotfiles/nvim-config3.0/bug-repro/init.lua"
   if [[ ! -f "$config_path" ]]; then
    echo "Config file does not exist: $config_path"
    return 1
  fi
  local config_dir=$(dirname "$config_path")
  cd "$config_dir"
  nvim -u "$config_path"
}

function copy-path-to-clipboard() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a file or directory path"
    return 1
  fi

  fullPath=$(realpath "$1" 2>/dev/null)

  if [ $? -ne 0 ]; then
    echo "Error: File or directory not found"
    return 1
  fi

  if command -v xclip &>/dev/null; then
    echo -n "$fullPath" | xclip -selection clipboard
  elif command -v xsel &>/dev/null; then
    echo -n "$fullPath" | xsel -b
  else
    echo "Error: Please install xclip or xsel"
    return 1
  fi

  echo "Copied to clipboard: $fullPath"
}

function clear-and-put-prompt-at-bottom() {
  printf "\e[H\ec\e[${LINES}B"
}

# Utility aliases
alias virepro='start-nvim-bug-repro'
alias cpath='copy-path-to-clipboard'
alias clear='clear-and-put-prompt-at-bottom'

# yazi for file navigation 
function lf() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
### End of Zinit's installer chunk


zinit snippet OMZP::git

# vi mode
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode
# bindkey -v
# zinit ice depth=1
# zinit light zsh-vi-more/vi-motions
function zvm_config() {
  ZVM_KEYTIMEOUT=0.5
  ZVM_ESCAPE_KEYTIMEOUT=0.001
}
# function zvm_after_init() {
#   bindkey '^[[C' forward-word # Right arrow
#   bindkey '\e;' end-of-line # Alt-;
#   zvm_bindkey viins '^p' history-search-backward
#   zvm_bindkey viins '^n' history-search-forward
# }

# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward

# # Enable autocomplete explicitly
# autoload -Uz compinit
# compinit


# # autosuggestions
# zinit ice depth=1
# zinit light zsh-users/zsh-autosuggestions
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#757575"
#
# # syntax highlighting
# zinit ice depth=1
# zinit light zsh-users/zsh-syntax-highlighting

# powerlevel10k
# zinit ice depth=1
# zinit light romkatv/powerlevel10k

# fzf-tab
zinit ice depth=1
zinit light Aloxaf/fzf-tab


# precmd() {
#     print $'\n\n\n\n\n\n\n\n\e[9A'
# }

source <(fzf --zsh)
# eval "$(starship init zsh)"
eval "$(zoxide init zsh)"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
