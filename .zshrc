#!/bin/zsh
# Set up the prompt

# Set up environment variables

if [[ -z $XDG_DATA_HOME ]]; then
	export XDG_DATA_HOME=$HOME/.local/share
fi

if [[ -z $XDG_CONFIG_HOME ]]; then
	export XDG_CONFIG_HOME=$HOME/.config
fi

if [[ -z $XDG_CACHE_HOME ]]; then
	export XDG_CACHE_HOME=$HOME/.cache
fi

if [[ -z $XDG_DATA_DIRS ]]; then
	export XDG_DATA_DIRS=/usr/local/share:/usr/share
else
	export XDG_DATA_DIRS=/usr/local/share:/usr/share:$XDG_DATA_DIRS
fi

if [[ -z $XDG_CONFIG_DIRS ]]; then
	export XDG_CONFIG_DIRS=/etc/xdg
else
	export XDG_CONFIG_DIRS=/etc/xdg:$XDG_CONFIG_DIRS
fi

# Enable 256 color mode
export TERM="xterm-256color"

# Keep 1000 lines of history within the shell and save it to ~/.cache/shell_history
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.cache/shell_history

# Preferred apps
EDITOR="vim"

# Shell options
setopt histignorealldups sharehistory
# assume "cd" when a command is a directory
setopt autocd
# Substitute commands in the prompt
setopt promptsubst

# Enable git vcs_info module
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats " %F{003}(%r:%b)"
precmd() {
	vcs_info
}

# Enable powerline if available, otherwise use a regular PS1
if [[ -e /usr/share/zsh/site-contrib/powerline.zsh ]]; then
	. /usr/share/zsh/site-contrib/powerline.zsh
	VIRTUAL_ENV_DISABLE_PROMPT=true
else
	if [[ $EUID -lt 1000 ]]; then
		PS1="%F{yellow}[%*] %(!.%F{red}.%F{magenta})%n@%M%k %B%F{green}%(8~|...|)%7~ %F{white}%# %b%f%k"
	else
		PROMPT='%F{yellow}[%*] %F{cyan}%n@%M%k %B%F{green}%(8~|...|)%7~${vcs_info_msg_0_} %F{white}%# %b%f%k'
	fi
fi

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


# keybinds

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
	function zle-line-init () {
		printf '%s' ${terminfo[smkx]}
	}
	function zle-line-finish () {
		printf '%s' ${terminfo[rmkx]}
	}
	zle -N zle-line-init
	zle -N zle-line-finish
fi
# Bind ctrl-left / ctrl-right
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word

# Bind ctrl-backspace to delete word. NOTE: This may not work properly in some emulators
# bindkey "^?" backward-delete-word

# Bind shift-tab to backwards-menu
# NOTE this won't work on Konsole if the new tab button is shown
bindkey "\e[Z" reverse-menu-complete

# Make ctrl-e edit the current command line
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line


# Aliases

# Colors
alias ls='ls -F --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias less='less -R' # make less accept color codes and re-output them

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias lh='ls -lh'
alias l='ls -CF'
alias lash='ls -lAsh'
alias sl='ls'

# developer aliases

# Make unified diff syntax the default
alias diff="diff -u"

# Alias make to a proper amount of cores
alias make="make -j$(grep processor /proc/cpuinfo | wc -l)"

# From grml's zshrc!
# https://github.com/grml/grml-etc-core/blob/master/etc/zsh/zshrc

# make a backup of a file
bk() {
	cp -a "$1" "${1}_$(date --iso-8601=seconds)"
}


# Create small urls via http://goo.gl using curl(1).
# API reference: https://code.google.com/apis/urlshortener/
function zurl() {
	emulate -L zsh
	if [[ -z $1 ]]; then
		print "USAGE: zurl <URL>"
		return 1
	fi

	local PN url prog api json data
	PN=$0
	url=$1

	# Prepend 'http://' to given URL where necessary for later output.
	if [[ ${url} != http(s|)://* ]]; then
		url='http://'${url}
	fi

	prog=curl
	api='https://www.googleapis.com/urlshortener/v1/url'
	contenttype="Content-Type: application/json"
	json="{\"longUrl\": \"${url}\"}"
	data=$($prog --silent -H ${contenttype} -d ${json} $api)
	# Match against a regex and print it
	if [[ $data =~ '"id": "(http://goo.gl/[[:alnum:]]+)"' ]]; then
		print $match
	fi
}

# simple webserver
alias http="python -mhttp.server"

# json prettify
alias json="python -mjson.tool"

# octal/text permissions for file
alias perms="stat -c '%A %a %n'"

# get public ip
alias myip="curl ifconfig.me"

# display a list of supported colors
function colorlist() {
	((cols = $COLUMNS - 4))
	s=$(printf %${cols}s)
	for i in {000..$(tput colors)}; do
		echo -e $i $(tput setaf $i; tput setab $i)${s// /=}$(tput op);
	done
}

# get the content type of an http resource
function htmime() {
	if [[ -z $1 ]]; then
		print "USAGE: htmime <URL>"
		return 1
	fi
	mime=$(curl -sIX HEAD $1 | grep ^Content-Type | sed "s/Content-Type: //")
	print $mime
}

# urlencode text
function urlencode {
	setopt extendedglob
	echo "${${(j: :)@}//(#b)(?)/%$[[##16]##${match[1]}]}"
}

# open a web browser on google for a query
function google {
	xdg-open "http://www.google.com/search?q=`urlencode "${(j: :)@}"`"
}

# translates text (note: disabled by Google)
function translate {
	wget -qO- "http://ajax.googleapis.com/ajax/services/language/translate?v=2.0&q=$1&langpair=$2|${3:-en}" | sed 's/.*"translatedText":"\([^"]*\)".*}/\1\n/';
}

# xdg basedir-related stuff
alias skype="skype --dbpath=$HOME/.config/skype"
alias nvidia-settings="nvidia-settings --config=$HOME/.config/nvidia-settings"
export CCACHE_DIR=$XDG_CACHE_HOME/ccache
export FORTUNE_DIR=$XDG_DATA_HOME/fortune
export LESSHISTFILE=$XDG_CACHE_HOME/less_history
export MPLAYER_HOME=$XDG_CONFIG_HOME/mplayer
export WINEPREFIX=$XDG_DATA_HOME/wineprefixes/default
export PATH=$HOME/bin:$PATH

# virtualenvwrapper
if command virtualenvwrapper_lazy.sh >/dev/null 2>&1; then
	export WORKON_HOME=$XDG_DATA_HOME/virtualenvs
	export PROJECT_HOME=$HOME/src/git
	source virtualenvwrapper_lazy.sh
	# Arch linux uses python3 by default, this is required to make python2-compatible projects
	alias mkproject2="mkproject -p /usr/bin/python2"
	alias mkvirtualenv2="mkvirtualenv -p /usr/bin/python2"
fi


# plugins
if [[ -e /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
