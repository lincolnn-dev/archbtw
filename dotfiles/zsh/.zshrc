# Created by newuser for 5.9.2

source ~/.local/share/zsh/plugins/zsh-shift-select/zsh-shift-select.plugin.zsh

alias zrc="nvim ~/.zshrc"
alias ll="ls -la"
alias homeserver="ssh -4 tropikalmalady@homeserver.local"

bindkey '\eOH' beginning-of-line
bindkey '\eOF' end-of-line
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

function fixaudio() {
	systemctl --user restart pipewire pipewire-pulse wireplumber
	pkill noctalia
	nohup noctalia > /dev/null 2>&1 &
}

function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"
export XDG_DATA_HOME="$HOME/.local/share"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

export PATH=$PATH:$HOME/.spicetify
