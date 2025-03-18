xset b off
xset r rate 380 28
#
# Remap XF86Back и XF86Forward keys to PgUp/PgDn for ThinkPad X220.
# It is important to invoke `setxkbmap' first, because otherwise
# `xmodmap' will not work (it'll like be overwritten by later
# call of `setxkbmap', that is done automatically).
#
setxkbmap
xmodmap ~/.config/Xmodmap
xbindkeys &
xsd &
xhp &
sleep 1 && batd &
emn &
exec /usr/local/bin/i3
