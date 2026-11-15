#!/bin/sh
# Records the catalog preview, asciiverse/diabaig.cast (hub/RECORDING.md):
# the title screen, a new Warrior, auto-explore and fights on the first
# floors, then quitting to the gravestone. Diabaig's screen is a fixed
# 78x33, so this records at 100x34 and hub crops it to 100x30 following
# the player (media.crop). asciinema records a tmux pane (own socket, no
# status line, no user config) that asciiverse/drive.py reads and plays
# into. Needs asciinema 3 and tmux.
#   asciiverse/record-preview.sh build/linux/diabaig [seed]
set -eu
binary=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
seed=${2:-2026}
here=$(cd "$(dirname "$0")" && pwd)
out=$here/diabaig.cast
home=$(mktemp -d)
trap 'tmux -L avrec kill-server 2>/dev/null; rm -rf "$home"' EXIT
mkdir "$home/bin" && cp "$binary" "$home/bin/diabaig"
cd "$home"  # nothing in the recording names a local path
export HOME="$home" XDG_STATE_HOME="$home/state" PATH="$home/bin:$PATH" \
  USER=player LOGNAME=player TERM=xterm-256color COLORTERM=truecolor LANG=C.UTF-8
tmux -L avrec -f /dev/null new-session -d -s rec -x 100 -y 34 "diabaig -s $seed" \; set -g status off
python3 -I "$here/drive.py" avrec rec &
drive=$!
asciinema rec --headless --overwrite -q \
  --window-size 100x34 --idle-time-limit 2 \
  --capture-env "TERM,COLORTERM,LANG" --title "Diabaig" \
  --command "tmux -L avrec attach -t rec" "$out"
wait "$drive"
