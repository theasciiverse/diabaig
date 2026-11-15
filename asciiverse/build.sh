#!/bin/sh
# Builds Diabaig for the Asciiverse catalog. Leaves the binary in
# build/<platform>/diabaig (diabaig.exe on Windows).
#   Linux:   docker run --rm -v "$PWD":/src -w /src alpine:3.22 sh asciiverse/build.sh
#            (fully static against Alpine's ncurses; reads the system's terminfo)
#   macOS:   sh asciiverse/build.sh  (links the system's ncurses)
#   Windows: sh asciiverse/build.sh  in an MSYS2 UCRT64 or CLANGARM64 shell
#            (static PDCurses wincon 3.9, built from source here, as
#            upstream's own CI did)
#
# The Makefile regenerates build/data_embedded.h with `echo "...\n"`,
# which only works where sh's echo expands \n. src/data_embedded.c is
# committed and matches res/, so the header is written here with printf
# and make finds both up to date. -std=gnu17: GCC 15 defaults to C23,
# where autopilot.c's `int c_inroom()` no longer takes an argument.
set -eu
case "$(uname -s)" in
  Linux)  platform=linux ;;
  Darwin) platform=macos ;;
  MINGW*|MSYS*|UCRT*|CLANG*) platform=windows ;;
  *) echo "unknown platform $(uname -s)" >&2; exit 1 ;;
esac

if [ -f /etc/alpine-release ]; then
  apk add --no-cache build-base ncurses-dev ncurses-static >/dev/null
fi

touch src/data_embedded.c
mkdir -p build
{
  printf '//Auto generated header\n#ifndef DATAHEADER_H\n#define DATAHEADER_H\n\n'
  grep const src/data_embedded.c | sed 's/const/extern const/' | sed 's/\ =.*/;/'
  printf '\n#endif//DATAHEADER_H\n'
} > build/data_embedded.h

case $platform in
  linux)
    # Alpine's libncursesw.a has terminfo built in; elsewhere it is libtinfo
    libs="-static -lncursesw -lm"
    [ -f /etc/alpine-release ] || libs="-static -lncursesw -ltinfo -lm"
    make -j4 CC="cc -std=gnu17" LDLIBS="$libs" build/linux/diabaig
    strip build/linux/diabaig ;;
  macos)
    make -j4 CC="clang -std=gnu17" build/macos/diabaig
    strip build/macos/diabaig ;;
  windows)
    # PDCurses' console port (wincon), built here: MSYS2's pdcurses
    # package is the WinGUI port, which opens a window of its own
    pdc=build/PDCurses-3.9
    if [ ! -f "$pdc/wincon/pdcurses.a" ]; then
      curl -fsSL https://github.com/wmcbrine/PDCurses/archive/refs/tags/3.9.tar.gz | tar -xz -C build
      make -C "$pdc/wincon" CC=cc pdcurses.a
      # Diabaig includes <pdcurses.h>, the name MSYS2 installs curses.h under
      printf '#include "curses.h"\n' > "$pdc/pdcurses.h"
    fi
    make -j4 PLATFORM=windows CC="cc -std=gnu17 -I$pdc" LDLIBS="-static $pdc/wincon/pdcurses.a -lm" build/windows/diabaig.exe
    strip build/windows/diabaig.exe ;;
esac
