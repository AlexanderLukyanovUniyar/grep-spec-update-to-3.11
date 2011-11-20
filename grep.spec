Name: grep
Version: 2.10
Release: alt1

Summary: The GNU versions of grep pattern matching utilities
License: GPLv3+
Group: File tools
Url: http://www.gnu.org/software/grep/

# git://git.sv.gnu.org/grep refs/heads/master
Source0: grep-%version-%release.tar
# git://git.sv.gnu.org/gnulib refs/heads/master
Source1: gnulib-%version-%release.tar
# translationproject.org::tp/latest/grep/
Source2: po-%version-%release.tar

Source3: GREP_COLORS
Source4: color_grep.sh
Source5: color_grep.csh

# git://git.altlinux.org/people/ldv/packages/gnulib refs/heads/grep
#Patch: grep-%version-%release.patch

# due to libpcre relocation.
Requires: libpcre3 >= 0:6.4-alt2
Provides: pcre-grep, pgrep
Obsoletes: pcre-grep, pgrep

BuildRequires: gperf libpcre-devel

%description
The GNU versions of commonly used grep utilities.  grep searches through
textual input for lines which contain a match to a specified pattern
and then prints the matching lines.  GNU's grep utilities include grep,
egrep, fgrep, and pcregrep.

%prep
%setup -n grep-%version-%release -a1 -a2

echo -n %version >.tarball-version

# Generate LINGUAS file.
ls po/*.po | sed 's|.*/||; s|\.po$||' > po/LINGUAS

# git and rsync aren't needed for build.
sed -i '/^\(git\|rsync\)[[:space:]]/d' bootstrap.conf

# Unset the variable gl_printf_safe to indicate that we do not need
# a safe handling of non-IEEE-754 'long double' values.
sed -i 's/gl_printf_safe=yes/gl_printf_safe=/' \
        gnulib-%version-%release/modules/printf-safe

%build
./bootstrap --skip-po --gnulib-srcdir=gnulib-%version-%release
%configure --bindir=/bin --disable-silent-rules --without-included-regex --enable-gcc-warnings
%make_build

%install
%makeinstall_std bindir=/bin

# Use symlinks for pcregrep
ln -s grep %buildroot/bin/pcregrep
ln -s grep.1 %buildroot%_man1dir/pcregrep.1

mkdir -p %buildroot%_sysconfdir/profile.d
install -pm755 %_sourcedir/color_grep.{sh,csh} \
	%buildroot%_sysconfdir/profile.d/
install -pm644 %_sourcedir/GREP_COLORS \
	%buildroot%_sysconfdir/

%find_lang %name

%check
%make_build -k check

%files -f %name.lang
%config(noreplace) %_sysconfdir/GREP_COLORS
%config(noreplace) %_sysconfdir/profile.d/*
/bin/*
%_mandir/man?/*
%_infodir/*.info*
%doc AUTHORS NEWS README THANKS TODO

%changelog
* Sun Nov 20 2011 Dmitry V. Levin <ldv@altlinux.org> 2.10-alt1
- Updated grep to v2.10.
- Updated gnulib to v0.0-6628-g4f6a7ef.
- Updated translations from translationproject.org.
- Fixed %%find_lang misplacement (closes: #26570).

* Thu Jun 23 2011 Dmitry V. Levin <ldv@altlinux.org> 2.9-alt1
- Updated grep to v2.9.
- Updated gnulib to v0.0-5844-g2dbdfc4.
- Updated translations from translationproject.org.

* Thu May 19 2011 Dmitry V. Levin <ldv@altlinux.org> 2.8-alt1
- Updated grep to v2.8.
- Updated gnulib to v0.0-5275-gc6dc8f1.
- Updated translations from translationproject.org.

* Wed May 11 2011 Dmitry V. Levin <ldv@altlinux.org> 2.7-alt4
- Updated grep to v2.7-43-ged23dd2.
- Updated gnulib to v0.0-5245-gc1a8825.
- Updated translations from translationproject.org.

* Mon Jan 31 2011 Dmitry V. Levin <ldv@altlinux.org> 2.7-alt3
- Updated grep to v2.7-24-ga14a699.
- Updated gnulib to v0.0-4672-ga2e8447.
- Updated translations from translationproject.org.
- Added /etc/profile.d/color_grep.*sh and /etc/GREP_COLORS files
  (closes: #24729).

* Mon Oct 04 2010 Dmitry V. Levin <ldv@altlinux.org> 2.7-alt2
- Fixed build on ARM.

* Mon Sep 20 2010 Dmitry V. Levin <ldv@altlinux.org> 2.7-alt1
- Updated to 2.7.

* Fri Apr 02 2010 Dmitry V. Levin <ldv@altlinux.org> 2.6.3-alt1
- Updated to 2.6.3.

* Mon Mar 29 2010 Dmitry V. Levin <ldv@altlinux.org> 2.6.2-alt1
- Updated to 2.6.2.

* Thu Mar 25 2010 Dmitry V. Levin <ldv@altlinux.org> 2.6.1-alt0.1
- Updated to 2.6.1 prerelease snapshot v2.6-17-g74ab780 (closes: #23228).

* Tue Mar 23 2010 Dmitry V. Levin <ldv@altlinux.org> 2.6-alt1
- Updated to 2.6 (closes: #19291).
- Removed obsolete patches.

* Wed Sep 09 2009 Dmitry V. Levin <ldv@altlinux.org> 2.5.1a-alt5
- Moved "make check" to %%check section.

* Mon Jul 13 2009 Dmitry V. Levin <ldv@altlinux.org> 2.5.1a-alt4
- Removed obsolete %%install_info/%%uninstall_info calls.

* Sun Apr 15 2007 Dmitry V. Levin <ldv@altlinux.org> 2.5.1a-alt3
- Imported "fgrep -w" fix by Pavel Kankovsky.
- Adopted Debian fix for big file handling.

* Sat Sep 02 2006 Dmitry V. Levin <ldv@altlinux.org> 2.5.1a-alt2
- Fixed various segfaults due to incorrect bound checks (#9941).
- Applied upstream patch to fix '-D skip' (RH#189580).
- Add requirement on libpcre3 >= 0:6.4-alt2 (#9666).

* Sat Dec 03 2005 Dmitry V. Levin <ldv@altlinux.org> 2.5.1a-alt1
- Updated to 2.5.1a.
- Merged patches from Owl, Debian and Red Hat.
- Cleaned up specfile.
- Enabled PCRE support.

* Tue Oct 28 2003 Stanislav Ievlev <inger@altlinux.ru> 2.5.1-alt0.4.cvs
- fix requires

* Thu Oct 16 2003 Stanislav Ievlev <inger@altlinux.ru> 2.5.1-alt0.3.cvs
- fix manpage

* Tue Oct 29 2002 Stanislav Ievlev <inger@altlinux.ru> 2.5.1-alt0.2.cvs
- rebuild with gcc3
- added patch from RH ( casesensitive lookup with -o -i options )

* Fri Aug 09 2002 Stanislav Ievlev <inger@altlinux.ru> 2.5.1-alt0.1.cvs
- 2.5.1

* Thu Dec 27 2001 Stanislav Ievlev <inger@altlinux.ru> 2.4.2-ipl6mdk
- added Belarusian translation

* Wed Nov 15 2000 Dmitry V. Levin <ldv@fandra.org> 2.4.2-ipl5mdk
- RE adaptions.
- Fixed texinfo documentation.

* Mon Sep 25 2000 Chmouel Boudjnah <chmouel@mandrakesoft.com> 2.4.2-4mdk
- Add i18n character ranges patch from Ulrich Drepper.

* Sat Sep  2 2000 Pixel <pixel@mandrakesoft.com> 2.4.2-3mdk
- use find_lang

* Wed Jul 19 2000 Chmouel Boudjnah <chmouel@mandrakesoft.com> 2.4.2-2mdk
- BM.
- Macros.
- CLean-up.

* Thu Mar 30 2000 Chmouel Boudjnah <chmouel@mandrakesoft.com> 2.4.2-1mdk
- Clean up specs.
- Adjust groups.
- 2.4.2.

* Tue Mar  7 2000 Chmouel Boudjnah <chmouel@mandrakesoft.com> 2.4.1-1mdk
- 2.4.1.

* Fri Dec  3 1999 Chmouel Boudjnah <chmouel@mandrakesoft.com>
- adjust URL.
- 2.4.

* Tue Nov 02 1999 Chmouel Boudjnah <chmouel@mandrakesoft.com>
- Prereq install-info.

* Wed Oct 20 1999 Chmouel Boudjnah <chmouel@mandrakesoft.com>
- Build release.
- Fix buid as user.

* Sat Apr 10 1999 Bernhard Rosenkraenzer <bero@linux-mandrake.com>
- Mandrake adaptions
- bzip2 man/info pages
- add de locale

* Mon Mar 08 1999 Preston Brown <pbrown@redhat.com>
- upgraded to grep 2.3, added install-info %post/%preun for info

* Wed Feb 24 1999 Preston Brown <pbrown@redhat.com>
- Injected new description and group.

* Sat May 09 1998 Prospector System <bugs@redhat.com>
- translations modified for de, fr, tr

* Fri May 01 1998 Cristian Gafton <gafton@redhat.com>
- updated to 2.2

* Thu Oct 16 1997 Donnie Barnes <djb@redhat.com>
- updated from 2.0 to 2.1
- spec file cleanups
- added BuildRoot

* Mon Jun 02 1997 Erik Troan <ewt@redhat.com>
- built against glibc