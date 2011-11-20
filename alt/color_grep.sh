# color-grep initialization

if [ -n "${TERM-}" -a -n "${PS1-}" ]; then

for color_grep in "$HOME/.grep_colors.$TERM" "$HOME/.grep_colors" \
			"/etc/GREP_COLORS.$TERM" "/etc/GREP_COLORS"; do
	[ -f "$color_grep" -a -r "$color_grep" ] || continue
	if egrep -iqs '^COLOR(=|[[:space:]]+)none[[:space:]]*$' "$color_grep"; then
		break
	fi
	eval `sed -n 's/^\(GREP_COLORS\)\(=\|[[:space:]]\+\)\([^[:space:]=].*\)/\1="\3"/p' "$color_grep"`
	if [ -z "${SHELL#*bash}" -o -z "${SHELL#*zsh}" ]; then
		alias grep='grep --color=auto'
	fi
	break
done
unset color_grep

fi
