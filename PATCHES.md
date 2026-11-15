# Changes from upstream

This is the Asciiverse packaging of [Diabaig](https://github.com/conornally/diabaig)
by conornally (MIT, `LICENSE`), a traditional turn-based ncurses
roguelike. Upstream is the `upstream` remote; this build is upstream's
`main` at `b90d358` (2025-09-26), which is its `diabaig-v1.0.1` tag. The
`asciiverse` branch carries the changes below, each small enough to offer
upstream (UPSTREAM.md).

## The game

Unchanged: same dungeon, rules, texts and fixed 78x33 screen (the game
asks for a terminal of at least 79x34 and waits until it has one).

## Code

- **State folder** (`src/platform.c`, `include/platform.h`, `src/main.c`):
  Diabaig opens `save/`, `.diabaigrc` and `diabaig.scr` by relative
  paths, so they land in whatever folder it is started from. At start it
  now moves into `$XDG_STATE_HOME/diabaig` (else `~/.local/state/diabaig`;
  on Windows `%LOCALAPPDATA%\diabaig`), making the folder if needed.
  Paths given with `-l` and `-S` are made absolute first, so they still
  mean what the player typed. If no such folder can be made, the game
  stays where it started, as before.
- **The `-v` log** (`src/log.c`, `src/diabaig.c`): written to
  `diabaig.log` in that state folder instead of `/tmp/diabaig.log`, so it
  works on Windows too and is not shared between users. It is upstream's
  own session log; nothing is logged without `-v`.

## Build settings

`asciiverse/build.sh`, not the Makefile, decides these:

- `-std=gnu17`: GCC 15 defaults to C23, where `int c_inroom()` in
  `src/autopilot.c` takes no arguments, and the call with one fails.
- `build/data_embedded.h` is written with `printf`: the Makefile's
  `echo "...\n"` only works where `sh`'s echo expands `\n` (dash, macOS),
  not with busybox or bash. `src/data_embedded.c` is committed and
  matches `res/`, so it is only touched, not regenerated.
- Linux links ncurses statically in Alpine (`-static -lncursesw`), so the
  binary needs nothing installed; it reads the system's terminfo. macOS
  links the system ncurses. Windows links PDCurses statically from MSYS2,
  the library upstream's `toolchain/windows.mk` names.

## Packaging

- `asciiverse/build.sh` (new): the build above.
- `.github/workflows/asciiverse-release.yml` (new): av archives for Linux
  (static, x86-64 and ARM64), macOS (Intel and Apple silicon) and Windows
  (x86-64 and ARM64), plus SHA256SUMS, on a `*-av.*` tag. Upstream's
  `c.yml` stays; it runs only on pushes to `main`, which this repository
  does not use.
- `asciiverse/record-preview.sh`, `asciiverse/drive.py` (new): the
  catalog preview.
- `asciiverse/diabaig.toml`, `asciiverse/diabaig.md`, `asciiverse/diabaig.cast`
  (new): the catalog manifest, store page and preview, as drafts for hub.
- `CLAUDE.md`, `PATCHES.md`, `UPSTREAM.md` (new): notes.
