if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

PS1="\u@\h:\w\$ "
[[ $PS1 && -f /usr/local/share/bash-completion/bash_completion.sh ]] && \
        source /usr/local/share/bash-completion/bash_completion.sh

bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'

# Specify Pager for man.
export MANPAGER='less -Xi'
export MANWIDTH="tty"
export MAIL=/home/artembunichev/mail/inb
export MBOX=/home/artembunichev/mail/arc
export NO_COLOR=1
