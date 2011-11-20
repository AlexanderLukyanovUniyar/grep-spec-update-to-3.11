# color-grep initialization

if ($?TERM) then
if ($TERM != "") then

foreach color_grep ($HOME/.grep_colors.$TERM $HOME/.grep_colors \
			/etc/GREP_COLORS.$TERM /etc/GREP_COLORS)
	if (! -f $color_grep || ! -r $color_grep) then
		continue
	endif

	egrep -iqs '^COLOR(=|[[:space:]]+)none[[:space:]]*$' $color_grep
	if ($? == 0) then
		break
	endif

	eval `sed -n 's/^\(GREP_COLORS\)\(=\|[[:space:]]\+\)\([^[:space:]=].*\)/setenv \1 "\3"/p' $color_grep`
	alias grep 'grep --color=auto'
	break
end
unsetenv color_grep

endif
endif
