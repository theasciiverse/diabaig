# Changes for upstream

Hi! These are the small changes the Asciiverse build of Diabaig carries,
written so each can be taken on its own or left out. PATCHES.md has the
full list with the packaging files.

## 1. Saves, settings and scores in a per-player folder

`save/`, `.diabaigrc` and `diabaig.scr` are opened by relative paths, so
a player who starts the game from a different folder (or from a launcher)
finds no saves and no settings. `platform_statedir()` in `src/platform.c`
moves into `$XDG_STATE_HOME/diabaig`, else `~/.local/state/diabaig`
(`%LOCALAPPDATA%\diabaig` on Windows), creating it, right after the
options are read in `main()`. `-l` and `-S` paths are made absolute first
(`platform_abspath()`). If no folder can be made, nothing changes.

## 2. The `-v` log beside the saves

`_log()` and `init()` use `diabaig.log` (so the state folder) instead of
`/tmp/diabaig.log`, which does not exist on Windows and is shared between
users elsewhere.

## 3. Two build notes (no source change)

- GCC 15 builds C23 by default, where `int c_inroom()` means no
  arguments, so `src/autopilot.c:68` fails to compile. Either
  `int c_inroom(coord p)` (the argument is unused) or `-std=gnu17` in
  `CCFLAGS` fixes it.
- The Makefile writes `build/data_embedded.h` with `echo "...\n"`. With
  bash or busybox as `sh`, the `\n` stays literal and the `#endif` line
  breaks. `printf` works everywhere.

Thank you for Diabaig!
