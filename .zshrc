#!/bin/zsh
# My .zshrc
# Jerome Leclanche <jerome@leclan.ch>
# https://github.com/jleclanche/dotfiles/blob/master/.zshrc


##
# Somebody set us up the prompt
#

# Let's have some colors first
autoload -U colors && colors

if [[ -e /usr/share/zsh/site-contrib/powerline.zsh ]]; then
	# Powerline support is enabled if available, otherwise use a regular PS1
	. /usr/share/zsh/site-contrib/powerline.zsh
	VIRTUAL_ENV_DISABLE_PROMPT=true
else
	# Default colors:
	# Cyan for users, red for root, magenta for system users
	local _time="%{$fg[yellow]%}[%*]"
	local _path="%B%{$fg[green]%}%(8~|...|)%7~"
	local _usercol
	if [[ $EUID -lt 1000 ]]; then
		# red for root, magenta for system users
		_usercol="%(!.%{$fg[red]%}.%{$fg[magenta]%})"
	else
		_usercol="$fg[cyan]"
	fi
	local _user="%{$_usercol%}%n@%M"
	local _prompt="%{$fg[white]%}${(r:$SHLVL*2::%#:)}"

	PROMPT="$_time $_user $_path $_prompt%b%f%k "

	RPROMPT='${vcs_info_msg_0_}' # git branch
	if [[ ! -z "$SSH_CLIENT" ]]; then
		RPROMPT="$RPROMPT ⇄" # ssh icon
	fi
fi

##
# Environment variables
#

# basedir defaults, in case they're not already set up.
# http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
if [[ -z "$XDG_DATA_HOME" ]]; then
	export XDG_DATA_HOME="$HOME/.local/share"
fi

if [[ -z "$XDG_CONFIG_HOME" ]]; then
	export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -z "$XDG_CACHE_HOME" ]]; then
	export XDG_CACHE_HOME="$HOME/.cache"
fi

if [[ -z "$XDG_DATA_DIRS" ]]; then
	export XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

if [[ -z "$XDG_CONFIG_DIRS" ]]; then
	export XDG_CONFIG_DIRS="/etc/xdg"
else
	export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"
fi

# add ~/bin to $PATH
path=(~/bin $path)
# add ~/.config/zsh/completion to completion paths
# NOTE: this needs to be a directory with 0755 permissions, otherwise you will
# get "insecure" warnings on shell load!
fpath=("$XDG_CONFIG_HOME/zsh/completion" $fpath)


##
# zsh configuration
#

# Keep 1000 lines of history within the shell
HISTSIZE=1000
SAVEHIST=1000
HISTFILE="$HOME/.zsh_history"

# shell options
setopt autocd # assume "cd" when a command is a directory
setopt histignorealldups # Substitute commands in the prompt
setopt sharehistory # Share the same history between all shells
setopt promptsubst # required for git plugin
# setopt extendedglob
# Extended glob syntax, eg ^ to negate, <x-y> for range, (foo|bar) etc.
# Backwards-incompatible with bash, so disabled by default.

# Colors!

# 256 color mode
export TERM="xterm-256color"

# Color aliases
if command -V dircolors >/dev/null 2>&1; then
	eval "$(dircolors -b)"
	# Only alias ls colors if dircolors is installed
	alias ls="ls -F --color=auto --group-directories-first"
fi

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
# make less accept color codes and re-output them
alias less="less -R"


##
# Completion system
#

autoload -Uz compinit
compinit

zstyle ":completion:*" auto-description "specify: %d"
zstyle ":completion:*" completer _complete _correct _approximate
zstyle ":completion:*" format "Completing %d"
zstyle ":completion:*" group-name ""
zstyle ":completion:*" menu select=2
zstyle ":completion:*:default" list-colors ${(s.:.)LS_COLORS}
zstyle ":completion:*" list-colors ""
zstyle ":completion:*" list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ":completion:*" matcher-list "" "m:{a-z}={A-Z}" "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=* l:|=*"
zstyle ":completion:*" menu select=long
zstyle ":completion:*" select-prompt %SScrolling active: current selection at %p%s
zstyle ":completion:*" verbose true

zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#)*=0=01;31"
zstyle ":completion:*:kill:*" command "ps -u $USER -o pid,%cpu,tty,cputime,cmd"


##
# Keybinds
#

# Use emacs-style keybindings
bindkey -e

bindkey "$terminfo[khome]" beginning-of-line # Home
bindkey "$terminfo[kend]" end-of-line # End
bindkey "$terminfo[kich1]" overwrite-mode # Insert
bindkey "$terminfo[kdch1]" delete-char # Delete
bindkey "$terminfo[kcuu1]" up-line-or-history # Up
bindkey "$terminfo[kcud1]" down-line-or-history # Down
bindkey "$terminfo[kcub1]" backward-char # Left
bindkey "$terminfo[kcuf1]" forward-char # Right
# bindkey "$terminfo[kpp]" # PageUp
# bindkey "$terminfo[knp]" # PageDown

# Bind ctrl-left / ctrl-right
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word

# Bind ctrl-backspace to delete word.
# NOTE: This may not work properly in some emulators
# bindkey "^?" backward-delete-word

# Bind shift-tab to backwards-menu
# NOTE this won't work on Konsole if the new tab button is shown
bindkey "\e[Z" reverse-menu-complete

# Make ctrl-e edit the current command line
autoload edit-command-line
zle -N edit-command-line
bindkey "^e" edit-command-line

# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
	function zle-line-init {
		printf "%s" ${terminfo[smkx]}
	}
	function zle-line-finish {
		printf "%s" ${terminfo[rmkx]}
	}
	zle -N zle-line-init
	zle -N zle-line-finish
fi

# typing ... expands to ../.., .... to ../../.., etc.
rationalise-dot() {
	if [[ $LBUFFER = *.. ]]; then
		LBUFFER+=/..
	else
		LBUFFER+=.
	fi
}
zle -N rationalise-dot
bindkey . rationalise-dot
bindkey -M isearch . self-insert # history search fix


##
# Aliases
#

# some more ls aliases
alias l="ls -CF"
alias ll="ls -lh"
alias la="ls -A"
alias sl="ls"

# Make unified diff syntax the default
alias diff="diff -u"

# octal+text permissions for files
alias perms="stat -c '%A %a %n'"

# expand sudo aliases
alias sudo="sudo "

# Default
alias hexdump="hexdump --canonical"

# Default
alias xclip="xclip -selection clipboard"

# Pastebin contents to https://paste.rs/
# alias dpaste="curl -F 'format=url' -F 'content=<-' https://dpaste.de/"
alias dpaste="curl --data-binary @- https://paste.rs/"


##
# Functions
#

# make a backup of a file
# https://github.com/grml/grml-etc-core/blob/master/etc/zsh/zshrc
bk() {
	cp -a "$1" "${1}_$(date --iso-8601=seconds)"
}

# display a list of supported colors
function lscolors {
	((cols = $COLUMNS - 4))
	s=$(printf %${cols}s)
	for i in {000..$(tput colors)}; do
		echo -e $i $(tput setaf $i; tput setab $i)${s// /=}$(tput op);
	done
}

# get the content type of an http resource
function htmime {
	if [[ -z $1 ]]; then
		print "USAGE: htmime <URL>"
		return 1
	fi
	mime=$(curl -sIX HEAD $1 | sed -nr "s/Content-Type: (.+)/\1/p")
	print $mime
}

# open a web browser on google for a query
function google {
	xdg-open "https://www.google.com/search?q=`urlencode "${(j: :)@}"`"
}

# print a separator banner, as wide as the terminal
function hr {
	print ${(l:COLUMNS::=:)}
}

# launch an app
function launch {
	type $1 >/dev/null || { print "$1 not found" && return 1 }
	$@ &>/dev/null &|
}
alias launch="launch " # expand aliases

# Useful python aliases/functions

# simple webserver to serve the current directory
alias mkhttp="python -m http.server"

# Prettify JSON:
alias json="python -m json.tool"
# Convert yaml to pretty JSON:
alias yaml="python -c 'import json, sys, yaml; y=yaml.safe_load(sys.stdin.read()); print(json.dumps(y, indent=4))'"

# https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
# Encode with URLEncode

function urlencode {
	python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}

# Decode URLencoded string
function urldecode {
	python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()), end='')"
}

# Convert a querystring into pretty JSON
function urlarray {
	python -c "import sys, json; from urllib.parse import parse_qs; print(json.dumps({k: q[0] if len(q) == 1 else q for k, q in parse_qs(sys.stdin.read()).items()}), end='')" | json
}

# get public ip
function myip {
	local api
	case "$1" in
		"-4")
			api="http://v4.ipv6-test.com/api/myip.php"
			;;
		"-6")
			api="http://v6.ipv6-test.com/api/myip.php"
			;;
		*)
			api="http://ipv6-test.com/api/myip.php"
			;;
	esac
	curl -s "$api"
	echo # Newline.
}


##
# Extras
#

# Git plugin
autoload -Uz vcs_info
zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:(git*):*" get-revision true
zstyle ":vcs_info:(git*):*" check-for-changes true

local _branch="%c%u%m %{$fg[green]%}%b%{$reset_color%}"
local _repo="%{$fg[green]%}%r %{$fg[yellow]%}%{$reset_color%}"
local _revision="%{$fg[yellow]%}%.7i%{$reset_color%}"
local _action="%{$fg[red]%}%a%{$reset_color%}"
zstyle ":vcs_info:*" stagedstr "%{$fg[yellow]%}✓%{$reset_color%}"
zstyle ":vcs_info:*" unstagedstr "%{$fg[red]%}✗%{$reset_color%}"
zstyle ":vcs_info:git*" formats "$_branch:$_revision - $_repo"
zstyle ":vcs_info:git*" actionformats "$_branch:$_revision:$_action - $_repo"
zstyle ':vcs_info:git*+set-message:*' hooks git-stash
# Uncomment to enable vcs_info debug mode
# zstyle ':vcs_info:*+*:*' debug true

function +vi-git-stash() {
	if [[ -s "${hook_com[base]}/.git/refs/stash" ]]; then
		hook_com[misc]="%{$fg_bold[grey]%}~%{$reset_color%}"
	fi
}

precmd() {
	vcs_info
}

# Syntax highlighting plugin
if [[ -e /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -e /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# virtualenvwrapper support
# Remember to set $PROJECT_HOME in your profile file!
if command -V virtualenvwrapper_lazy.sh >/dev/null 2>&1; then
	export WORKON_HOME="$XDG_DATA_HOME/virtualenvs"
	source virtualenvwrapper_lazy.sh
	# Arch linux uses python3 by default, this is required to make python2-compatible projects
	alias mkproject2="mkproject -p /usr/bin/python2"
	alias mkvirtualenv2="mkvirtualenv -p /usr/bin/python2"
fi

# User profile
if [[ -e "$XDG_CONFIG_HOME/zsh/profile" ]]; then
	source "$XDG_CONFIG_HOME/zsh/profile"
fi

# Check if $LANG is badly set as it causes issues
if [[ $LANG == "C"  || $LANG == "" ]]; then
	>&2 echo "$fg[red]The \$LANG variable is not set. This can cause a lot of problems.$reset_color"
fi
