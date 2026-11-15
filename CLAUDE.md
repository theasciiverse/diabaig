# Diabaig (Asciiverse packaging)

conornally's Diabaig (C, ncurses, MIT), packaged for the Asciiverse
catalog (id `diabaig`, kind `game`, genre `roguelike`). Not our code: the
game stays as its author made it; list every change in PATCHES.md and
keep each one offerable upstream (UPSTREAM.md).

- `upstream` is github.com/conornally/diabaig (branch `main`); ours is
  branch `asciiverse`, `origin` github.com/theasciiverse/diabaig (private).
- Build: `sh asciiverse/build.sh` (Linux static in alpine:3.22 under
  docker in CI; locally it links static against the host's ncursesw and
  tinfo). Binary in `build/<platform>/diabaig`.
- Release: tag `v<upstream version>-av.<n>` (first `v1.0.1-av.1`) and push
  it; `.github/workflows/asciiverse-release.yml` builds Linux, macOS and
  Windows.
- Saves, settings, scores and the `-v` log live in `$XDG_STATE_HOME/diabaig`.
  Tests and scripted runs always set a scratch `XDG_STATE_HOME` in the same
  command, under `systemd-run --user --scope -p MemoryMax=4G`.
- The screen is fixed at 78x33 and the game waits for at least 79x34, so
  the preview records at 100x34 and hub crops it to 100x30 following the
  player.
- Preview: `asciiverse/record-preview.sh build/linux/diabaig`.
- Catalog drafts: `asciiverse/diabaig.toml` and `.md`; hub pushes are done
  from beast.
