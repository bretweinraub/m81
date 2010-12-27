

debug () {
   $* >& out
   (emacs -cr gold -bg $BG_COLOR -fg $FG_COLOR -geometry 160x75+0 --eval '(compile "cat out")' &)
}

