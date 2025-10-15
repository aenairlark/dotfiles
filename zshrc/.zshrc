# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"
# editor
export EDITOR=helix

#PATH
export PATH="$PATH:/home/asim/.cargo/bin" #for packages from cargo
export PATH="$PATH:/home/asim/.nix-profile/bin/" #for packages from nix package manager

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Updates last command to alacritty
preexec(){print -Pn "\e]0;$1\a"}

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

#Quick cd using fd, it respects .ignore .gitignore
function fc() {
  cd "$(fd | fzf --preview 'tree -C {} | head -200' --preview-window 'up:60%')"
}

# Find and edit using fzf
function fe() {
  helix "$(fd --type f | fzf --preview 'cat {}' --preview-window 'up:60%')"
}
# Find and open pdfs, images, files, using xdg-open
function fo() {
	RG_PREFIX="fd --type f"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort  --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="up:0%"
	)" &&
	echo "opening $file" &&
	xdg-open "$file" &
	disown
}

# cd using yazi, on yazi exit goes to the dir where yazi left.
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
# opens a popup to select, create, delete tmux sessions C-o
bindkey -s '^o' '^u~/scripts/sesh-connect.sh\n'
# below method is better, but broke for some reason
# sesh-connect() {
#  	 ./scripts/sesh-connect.sh
#  }
#  zle -N sesh-connect
#  bindkey '^o' sesh-connect

#Aliases
alias ls='eza --git --icons --color=always'
alias ff='fastfetch'
alias hx='helix'
alias calculator='galculator & disown'
alias shx='sudo -E helix'
alias grep='grep --color=auto'
alias timeshiftgtk='sudo -E timeshift-gtk'
alias c='clear'
alias ..='cd ..'
alias bon='sudo systemctl start bluetooth.service'
alias bof='sudo systemctl stop bluetooth.service'
alias cat='bat'
alias power-saver='tuned-adm profile laptop-battery-powersave'
alias performance='tuned-adm profile latency-performance'
alias wg-up='sudo wg-quick up'
alias wg-down='sudo wg-quick down'
alias update-mirrors='sudo reflector -l 15 -p https --ipv4 -c India --sort rate --save /etc/pacman.d/mirrorlist'
alias sunset='hyprsunset -t 3000 & disown'
alias sunrise='pkill hyprsunset'
alias unzipall='for z in *.zip; do unzip "$z"; done' #unzips all zip files within a directory
alias r-un-needed='sudo pacman -Qqd | pacman -Rsu -' #run as su


#Script Aliases
alias ytm='~/scripts/yt.sh'
alias yt='youtube-tui'
alias password='~/scripts/password.sh'
