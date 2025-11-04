<<<<<<< HEAD
# quicknav.sh
A Bash CLI to bookmark and jump to directories
=======
# dirmarks.sh

A tiny Bash helper to bookmark directories and jump to them fast.

You can:

- `mark proj` → save current directory as `proj`
- `go proj` → `cd` to it
- `marks` → list all saved marks
- `unmark proj` → remove it
- `mkcd newdir` → `mkdir -p newdir` and `cd` into it
- `back 2` → go up 2 directories
- numeric shortcuts `0..9` → call `go 0`, `go 1`, ...

All marks are saved in `~/.dirmarks` by default (you can change it).

---

## Install

1. Put the script somewhere, e.g.

   mkdir -p ~/.local/bin
   cp dirmarks.sh ~/.local/bin/

2. Source it in your shell startup (so that the functions are available in the current shell):

# in ~/.bashrc or ~/.zshrc

   source ~/.local/bin/dirmarks.sh


3. Reload your shell:

   source ~/.bashrc
>>>>>>> baa4d36 (Initial commit)
