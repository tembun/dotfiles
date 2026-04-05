# .shrc - bourne shell startup file
#
# This file will be used if the shell is invoked for interactive use and
# the environment variable ENV is set to this file.
#
# see also sh(1), environ(7).

# # csh like history on arrow up and down
# bind ^[[A ed-search-prev-history
# bind ^[[B ed-search-next-history

# # ctrl+arrow allow to jump from words to words
# bind "\\e[1;5C" em-next-word
# bind "\\e[1;5D" ed-prev-word
#alias history='fc -l'

# set prompt: ``username@hostname:directory$ ''
export PS1="\u@\h:\w\\$ "
export TERM=xterm-256color
export EDITOR=vim
export VISUAL=vim
export MANPAGER="vim -M +MANPAGER '+set nu rnu' -"
export MANWIDTH=tty
export MANWIDTH_TTY_OFFSET=3
export NO_COLOR=1
export ENV=~/.shrc sh
export TMPDIR=/tmp
export HISTSIZE=100000

alias tps='. tps'

# shells/bash specific
export PROMPT_COMMAND='history -a; history -r'

# textproc/fzf specific
export FZF_DEFAULT_OPTS="--walker-root=. /etc /usr/include /usr/local/etc /usr/local/include /usr/local/src /home/tem/dev /home/tem/bin /home/tem/scripts /usr/src-current /tmp"

# sysutils/tmux specific
# tux() -- tmux create-or-attach
#	tmux does support custom command aliases with command-alias. But even if
#	we define an alias like: `s = new -As`, then `tmux s tmp` would work
#	only when the tmux server is already running. This is not very
#	convenient, that's why it seems that the only way to achieve that is to
#	use a shell function.
#	If no arguments are given, it lists all the active sessions.
#	If the first given argument is 'kill', then rest of the arguments are
#	treated as names of the sessions to kill.
#	Otherwise, if a single argument is given, it's treated as a session name.
#	If session with such name exists, attach to that session, otherwise -
#	create it.
tux()
{
	local arg="${1}"
	which -s tmux || return
	case "${arg}" in
	"")	tmux ls ;;
	"kill")
		shift
		if [ ${#} -eq 0 ]; then
			echo "Which sessions to kill?" 1>&2
			return 2
		fi
		for ses in ${@}; do
			tmux kill-session -t "${ses}"
		done
		;;
	*)	tmux new -As "${arg}" ;;
	esac
}
