"""Plays Diabaig for the catalog preview (asciiverse/record-preview.sh).

Reads the tmux pane and presses keys at a watchable pace: a new game as a
Warrior, then auto-explore (o), stepping into any creature next to the
hero to fight it, and down the stairs when a floor is done. Quits after
about 45 seconds without saving (Q).
    python3 -I drive.py <tmux socket> <session>
"""
import subprocess
import sys
import time

SOCK, SESS = sys.argv[1], sys.argv[2]
LENGTH = 45.0
DEBUG = len(sys.argv) > 3
T0 = time.time()
# vi keys for each step (dx, dy)
KEYS = {(-1, -1): "y", (0, -1): "k", (1, -1): "u", (-1, 0): "h",
        (1, 0): "l", (-1, 1): "b", (0, 1): "j", (1, 1): "n"}


def tmux(*args):
    return subprocess.run(["tmux", "-L", SOCK, *args], capture_output=True,
                          text=True).stdout


def screen():
    return tmux("capture-pane", "-p", "-t", SESS).split("\n")


def key(k, wait=0.35):
    if DEBUG:
        print(round(time.time() - T0, 1), k, file=sys.stderr)
    tmux("send-keys", "-t", SESS, k)
    time.sleep(wait)


def hero(rows):
    for y, row in enumerate(rows[1:29], 1):
        x = row.find("@")
        if x >= 0:
            return x, y
    return None


def adjacent_creature(rows, pos):
    x, y = pos
    for (dx, dy), k in KEYS.items():
        yy, xx = y + dy, x + dx
        if 1 <= yy < 29 and 1 <= xx < min(78, len(rows[yy])) and rows[yy][xx].isalpha():
            return k
    return None


time.sleep(2.5)                    # title screen
key("Enter", 1.0)                  # New Game
key("Enter", 0.8)                  # keep the player name
key("Down", 0.5)                   # Warrior
key("Enter", 2.0)
start = time.time()
last = None
while time.time() - start < LENGTH:
    rows = screen()
    text = "\n".join(rows)
    if "YOU FELL" in text or "Fallen" in text:
        break
    if "--more--" in text or "[ENTER]" in text and hero(rows) is None:
        key("Enter", 0.6)
        continue
    pos = hero(rows)
    if pos is None:
        key("Escape", 0.5)
        continue
    attack = adjacent_creature(rows, pos)
    if attack:
        key(attack, 0.45)
        continue
    if rows == last:               # explore has nothing left: on the stairs
        key(">", 1.0)
    else:
        key("o", 0.9)
    last = rows
key("Q", 0.8)
key("y", 3.0)                      # the gravestone
for _ in range(8):
    if "New Game" in "\n".join(screen()):
        for _ in range(5):
            key("Down", 0.15)
        key("Enter", 1.0)          # Quit
        break
    key("Enter", 1.5)
