#! /bin/sh
# Test various combinations of command-line options.
# This set of tests was started by Julian Foad.

: ${GREP=../src/grep}

VERBOSE=  # empty or "1"
failures=0

# grep_test INPUT EXPECTED_OUTPUT PATTERN_AND_OPTIONS...
# Run "grep" with the given INPUT, pattern and options, and check that
# the output is EXPECTED_OUTPUT.  If not, print a message and set 'failures'.
# "/" represents a newline within INPUT and EXPECTED_OUTPUT.
grep_test ()
{
  INPUT="$1"
  EXPECT="$2"
  shift 2
  OUTPUT=`echo -n "$INPUT" | tr "/" "\n" | "$GREP" "$@" | tr "\n" "/"`
  if test "$OUTPUT" != "$EXPECT" || test "$VERBOSE" = "1"; then
    echo "Testing:  $GREP $@"
    test "$LC_ALL" != C && test "$LC_ALL" != "" && echo "  LC_ALL: \"$LC_ALL\""
    echo "  input:  \"$INPUT\""
    echo "  output: \"$OUTPUT\""
  fi
  if test "$OUTPUT" != "$EXPECT"; then
    echo "  expect: \"$EXPECT\""
    echo "FAIL"
    failures=1
  fi
}


# Test "--only-matching" ("-o") option

# "-o" with "-i" should output an exact copy of the matching input text.
grep_test "WordA/wordB/WORDC/" "Word/word/WORD/" "Word" -o -i
grep_test "WordA/wordB/WORDC/" "Word/word/WORD/" "word" -o -i
grep_test "WordA/wordB/WORDC/" "Word/word/WORD/" "WORD" -o -i

# Should display the line number (-n), octet offset (-b), or file name
# (-H) of every match, not just of the first match on each input line.
# Check it both with and without -i because of the separate code paths.
# Also check what it does when lines of context are specified.
grep_test "wA wB/wC/" "1:wA/1:wB/2:wC/" "w." -o -n
grep_test "wA wB/wC/" "1:wA/1:wB/2:wC/" "w." -o -n -i
grep_test "wA wB/wC/" "1:wA/1:wB/2:wC/" "w." -o -n -3 2>/dev/null
grep_test "XwA YwB/ZwC/" "1:wA/5:wB/9:wC/" "w." -o -b
grep_test "XwA YwB/ZwC/" "1:wA/5:wB/9:wC/" "w." -o -b -i
grep_test "XwA YwB/ZwC/" "1:wA/5:wB/9:wC/" "w." -o -b -3 2>/dev/null
grep_test "XwA YwB/ZwC/" "1:w/5:w/9:w/" "w" -F -o -b
grep_test "XwA YwB/ZwC/" "1:w/5:w/9:w/" "w" -F -o -b -i
grep_test "XwA YwB/ZwC/" "1:w/5:w/9:w/" "w" -F -o -b -3 2>/dev/null
grep_test "wA wB/" "(standard input):wA/(standard input):wB/" "w." -o -H
grep_test "wA wB/" "(standard input):wA/(standard input):wB/" "w." -o -H -i
grep_test "wA wB/" "(standard input):wA/(standard input):wB/" "w." -o -H -3 2>/dev/null

# End of a previous match should not match a "start of ..." expression.
grep_test "word_word/" "word_/" "^word_*" -o
grep_test "wordword/" "word/" "\<word" -o


# Test "--color" option

CB="[01;31m[K"
CE="[m[K"

# "--color" with "-i" should output an exact copy of the matching input text.
grep_test "WordA/wordb/WORDC/" "${CB}Word${CE}A/${CB}word${CE}b/${CB}WORD${CE}C/" "Word" --color=always -i
grep_test "WordA/wordb/WORDC/" "${CB}Word${CE}A/${CB}word${CE}b/${CB}WORD${CE}C/" "word" --color=always -i
grep_test "WordA/wordb/WORDC/" "${CB}Word${CE}A/${CB}word${CE}b/${CB}WORD${CE}C/" "WORD" --color=always -i

# End of a previous match should not match a "start of ..." expression.
grep_test "word_word/" "${CB}word_${CE}word/" "^word_*" --color=always
grep_test "wordword/" "${CB}word${CE}word/" "\<word" --color=always


# Test combination of "-m" with "-A" and anchors.
# Based on a report from Pavol Gono.
grep_test "4/40/"  "4/40/"  "^4$" -m1 -A99
grep_test "4/04/"  "4/04/"  "^4$" -m1 -A99
grep_test "4/444/" "4/444/" "^4$" -m1 -A99
grep_test "4/40/"  "4/40/"  "^4"  -m1 -A99
grep_test "4/04/"  "4/04/"  "^4"  -m1 -A99
grep_test "4/444/" "4/444/" "^4"  -m1 -A99
grep_test "4/40/"  "4/40/"  "4$"  -m1 -A99
grep_test "4/04/"  "4/04/"  "4$"  -m1 -A99
grep_test "4/444/" "4/444/" "4$"  -m1 -A99


# Test for "-F -w" bugs.  Thanks to Gordon Lack for these two.
grep_test "A/CX/B/C/" "A/B/C/" -wF -e A -e B -e C
grep_test "LIN7C 55327/" "" -wF -e 5327 -e 5532

# Test for non-empty matches following empty ones.
grep_test 'xyz/' 'y/' -o 'y*'
grep_test 'xyz/' "x${CB}y${CE}z/" --color=always 'y*'


# The rest of this file is meant to be executed under this locale.
LC_ALL=cs_CZ.UTF-8; export LC_ALL
# If the UTF-8 locale doesn't work, skip these tests silently.
locale -k LC_CTYPE 2>/dev/null | "${GREP}" -q "charmap.*UTF-8" || exit $failures

# Test character class erroneously matching a '[' character.
grep_test "[/" "" "[[:alpha:]]" -E

for mode in F G E; do
  # Hint:  pipe the output of these tests in
  #        "| LESS= LESSCHARSET=ascii less".
  # LETTER N WITH TILDE is U+00F1 and U+00D1.
  # LETTER Y WITH DIAERESIS is U+00FF and U+0178.
  grep_test 'añÿb/AÑŸB/' 'ñÿ/ÑŸ/' 'ñÿ' -o -i -$mode
  grep_test 'añÿb/AÑŸB/' 'ñÿ/ÑŸ/' 'ÑŸ' -o -i -$mode
  grep_test 'añÿb/AÑŸB/' "a${CB}ñÿ${CE}b/A${CB}ÑŸ${CE}B/" 'ñÿ' --color=always -i -$mode
  grep_test 'añÿb/AÑŸB/' "a${CB}ñÿ${CE}b/A${CB}ÑŸ${CE}B/" 'ÑŸ' --color=always -i -$mode

  # POSIX (about -i):  ... each character in the string is matched
  # against the pattern, not only the character, but also its case
  # counterpart (if any), shall be matched.
  # The following were chosen because of their trickiness due to the
  # differing UTF-8 octet length of their counterpart and to the
  # non-reflexivity of their mapping.
  # Beware of homographs!  Look carefully at the actual octets.

  # lc(U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE) = U+0069 LATIN SMALL LETTER I
  grep_test 'aİb/' "a${CB}İ${CE}b/" 'i' --color=always -i -$mode
  grep_test 'aib/' ''               'İ' --color=always -i -$mode
  grep_test 'aİb/' ''               'I' --color=always -i -$mode
  # uc(U+0131 LATIN SMALL LETTER DOTLESS I)          = U+0049 LATIN CAPITAL LETTER I
  grep_test 'aıb/' "a${CB}ı${CE}b/" 'I' --color=always -i -$mode
  grep_test 'aIb/' ''               'ı' --color=always -i -$mode
  grep_test 'aıb/' ''               'i' --color=always -i -$mode
  # uc(U+017F LATIN SMALL LETTER LONG S)             = U+0053 LATIN CAPITAL LETTER S
  grep_test 'aſb/' "a${CB}ſ${CE}b/" 'S' --color=always -i -$mode
  grep_test 'aSb/' ''               'ſ' --color=always -i -$mode
  grep_test 'aſb/' ''               's' --color=always -i -$mode
  # uc(U+1FBE GREEK PROSGEGRAMMENI)                  = U+0399 GREEK CAPITAL LETTER IOTA
  grep_test 'aιb/' "a${CB}ι${CE}b/" 'Ι' --color=always -i -$mode
  grep_test 'aΙb/' ''               'ι' --color=always -i -$mode
  grep_test 'aιb/' ''               'ι' --color=always -i -$mode
  # lc(U+2126 OHM SIGN)                              = U+03C9 GREEK SMALL LETTER OMEGA
  grep_test 'aΩb/' "a${CB}Ω${CE}b/" 'ω' --color=always -i -$mode
  grep_test 'aωb/' ''               'Ω' --color=always -i -$mode
  grep_test 'aΩb/' ''               'Ω' --color=always -i -$mode
  # lc(U+212A KELVIN SIGN)                           = U+006B LATIN SMALL LETTER K
  grep_test 'aKb/' "a${CB}K${CE}b/" 'k' --color=always -i -$mode
  grep_test 'akb/' ''               'K' --color=always -i -$mode
  grep_test 'aKb/' ''               'K' --color=always -i -$mode
  # lc(U+212B ANGSTROM SIGN)                         = U+00E5 LATIN SMALL LETTER A WITH RING ABOVE
  grep_test 'aÅb/' "a${CB}Å${CE}b/" 'å' --color=always -i -$mode
  grep_test 'aåb/' ''               'Å' --color=always -i -$mode
  grep_test 'aÅb/' ''               'Å' --color=always -i -$mode
done


# Any tests inserted right here will be performed under an UTF-8 locale.
# Insert them before LC_ALL is set above to avoid this.
# Leave this comment last.

exit $failures
