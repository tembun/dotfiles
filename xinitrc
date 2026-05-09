# Turn the terminal bell off.
xset b off
# Set a bit faster keyboard rate.
# It means, if you press and hold the key, it reports events faster,
# thus, characters are printed faster.
xset r rate 160 35

# Remap XF86Back и XF86Forward keys to PgUp/PgDn for ThinkPad X220.
# It is important to invoke `setxkbmap' first, because otherwise
# `xmodmap' will not work (it'll like be overwritten by later
# call of `setxkbmap', that is done automatically).
setxkbmap
xmodmap ~/.config/Xmodmap

# Custom keybindings (see ~/.xbindkeysrc).
daemon -o /dev/null xbindkeys
# Start the selection daemon for X11.
daemon -o /dev/null xsd
# Hide X pointer if it hasn't been active for a while.
daemon -o /dev/null xhp
# Run email-notifier daemons (for several mail accounts)
daemon -o /dev/null emn ~/.emnrc.primary
daemon -o /dev/null emn ~/.emnrc.sink

# Start the battery monitor.
# A little delay before execution bacause drawing an X-window
# immediately after startup doesn't always work correctly.
(sleep 1 && batd) &

if tmux has-session 2>/dev/null; then
	tmux_cmd="tmux attach"
else
	tmux_cmd="tmux"
fi

xrdb -load ~/.Xdefaults
xterm -e $tmux_cmd &
exec dwm
