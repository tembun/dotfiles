# Turn the terminal bell off.
xset b off

#
# Set a bit faster keyboard rate.
# It means, if you press and hold the key, it reports events faster,
# thus, characters are printed faster.
#
xset r rate 380 28

#
# Remap XF86Back и XF86Forward keys to PgUp/PgDn for ThinkPad X220.
# It is important to invoke `setxkbmap' first, because otherwise
# `xmodmap' will not work (it'll like be overwritten by later
# call of `setxkbmap', that is done automatically).
#
setxkbmap
xmodmap ~/.config/Xmodmap

# Custom keybindings (see ~/.xbindkeysrc).
xbindkeys &

# Start the selection daemon for X11.
xsd &

# Hide X pointer if it hasn't been active for a while.
xhp &

#
# Start the battery monitor.
# A little delay before execution bacause drawing an X-window
# immediately after startup doesn't always work correctly.
#
(sleep 1 && batd) &

# Run email-notifier daemon.
emn &

# Execute the window manager (i3).
exec /usr/local/bin/i3
