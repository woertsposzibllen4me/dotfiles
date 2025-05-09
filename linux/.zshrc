export PATH="$HOME/.local/bin:$PATH"
source ~/bin/wsl-ssh-agent-relay.sh
unsetopt beep

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/bin:$PATH"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export dotfiles="$HOME/dotfiles"

alias clip='xclip -selection clipboard'
alias vi='nvim'
alias vid='cd $HOME/.config/nvim'
alias lg='lazygit'
alias wh='which'
alias lf='yazi'
alias ls='eza --icons -l'
alias lsa='eza --icons -la'
alias lst='eza --icons -lT'
alias lsat='eza --icons -laT'
alias dot='cd $HOME/dotfiles'
alias gitcfg='git config --global -e'
alias zf="__zoxide_zi"

function edit-wezterm-profile() {
  nvim "$dotfiles/.wezterm.lua"
}

function edit-lazygit-config() {
  nvim "$dotfiles/lazygit-config.yml"
}

start-nvim-bug-repro() {
  local config_path="$HOME/dotfiles/nvim-config3.0/bug-repro/init.lua"
   if [[ ! -f "$config_path" ]]; then
    echo "Config file does not exist: $config_path"
    return 1
  fi
  local config_dir=$(dirname "$config_path")
  cd "$config_dir"
  nvim -u "$config_path"
}

alias wzcfg='edit-wezterm-profile'
alias lgcfg='edit-lazygit-config'
alias virepro='start-nvim-bug-repro'

function lfcd() {
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

function zvm_config() {
  ZVM_KEYTIMEOUT=0.01
  ZVM_ESCAPE_KEYTIMEOUT=0.001
}

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

zinit ice depth=1
zinit light Aloxaf/fzf-tab

# zinit ice depth=1
# zinit light romkatv/powerlevel10k


source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
