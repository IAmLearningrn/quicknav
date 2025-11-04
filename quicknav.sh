# dirmarks.sh — simple directory bookmark helper for Bash
# Copyright (c) 2025 Amirhossein Hosseingholi
# License: MIT (see LICENSE or https://opensource.org/licenses/MIT)

: "${DIRMARKS_FILE:=$HOME/.dirmarks}"
[[ -f "$DIRMARKS_FILE" ]] || : > "$DIRMARKS_FILE"

dmhelp() {
  cat <<'EOF'
Usage:
  mark <key> [dir]   – remember current (or given) directory
  unmark <key>       – remove mark
  marks              – list all marks
  go <key>           – cd to marked directory
  lsgo <key>         – cd and list contents
  mkcd <dir>         – mkdir -p and cd into it
  back [n]           – go up n directories (default 1)
Notes:
  - Keys must not contain ':'.
  - Re-marking an existing key updates its path.
EOF
}

_qn_abs(){
  ( builtin cd -- "${1:-$PWD}" 2>/dev/null && pwd -P )
}

mkcd(){
  [[ -z "$1" ]] && { echo "mkcd: Need dir" >&2; return 2 ; }
  mkdir -p -- "$1" && builtin cd -- "$1"
}

mark(){
  [[ -z "$1" ]] && { echo  "mark: need key">&2; return 2; }
  local key="$1" ; shift || true
  [[ "$key" = *:* ]] && { echo  "mark: Key Can not Contain ':'">&2; return 2; }
  local path="$(_qn_abs "${1:-$PWD}")" || return
  [[ -d $path ]] || { echo  "mark: Not a Directory: $path">&2; return 2; }
  mkdir -p -- "$(dirname -- "$DIRMARKS_FILE")"

  local existing_key
  existing_key="$(awk -F : -v p="$path" '$2==p{print $1}' "$DIRMARKS_FILE" 2>/dev/null | head -n1 || true)"
  if [[ -n $existing_key ]] && [[ $existing_key != "$key" ]];then
    echo "mark: path already marked as '$existing_key'">&2
    read -r -p "[ ? ] Update mark?" yn
    case $yn in
      [yY]*) : ;;
      [nN]*) echo "Aborted">&2 ; return 0 ;;
    esac
  fi

  local tmp; tmp="$(mktemp "${DIRMARKS_FILE}.XXXXXX")" || return 1
  awk -F: -v k="$key" '$1 != k' "$DIRMARKS_FILE" 2>/dev/null > "$tmp" || :
  printf '%s:%s\n' "$key" "$path" >> "$tmp"
  mv -- "$tmp" "$DIRMARKS_FILE"
  echo "Marked $key -> $path"
}

marks(){
  [[ -f $DIRMARKS_FILE ]] || { echo "No marks yet."; return 0; }
  if command -v column >/dev/null 2>&1;then
    column -s: -t < "$DIRMARKS_FILE" | sort
  else
    awk -F: '{printf "%-20s %s\n , $1 , $2"}' "$DIRMARKS_FILE" | sort
  fi
}

unmark(){
  [[ -z "$1" ]] && { echo "unmark: need key">&2; return 2; }
  [[ -f "$DIRMARKS_FILE" ]] || { echo "No marks."; return 0; }
  local key="$1"
  local tmp; tmp="$(mktemp "${DIRMARKS_FILE}.XXXXXX")" || return 1
  awk -F: -v k="$key" '$1 != k' "$DIRMARKS_FILE" 2>/dev/null > "$tmp" || :
  mv -- "$tmp" "$DIRMARKS_FILE"
  echo "Unmarked"
}

go(){
  [[ -z ${1-} ]] && { echo "go: need key" >&2 ; return 2; }
  local dest
  dest="$(awk -F: -v k="$1" '$1==k{print $2}' "$DIRMARKS_FILE" 2>/dev/null)"
  [[ -z $dest ]] && { echo "go: no such mark '$1'.">&2 ; return 1;}
  builtin cd -- "$dest" || return
}

lsgo(){
  [[ -z ${1-} ]] && { echo "go: need key" >&2 ; return 2; }
  local dest
  dest="$(awk -F: -v k="$1" '$1==k{print $2}' "$DIRMARKS_FILE" 2>/dev/null)"
  [[ -z $dest ]] && { echo "go: no such mark '$1'.">&2 ; return 1;}
  builtin cd -- "$dest" || return
  clear
  ls -laht "$dest" || return
}

for n in {0..9};do
  eval "
$n() {
  go $n
}
"
done

back() {
  local n=${1:-1}
  [[ $n =~ ^[0-9]+$ ]] || { echo "back: n must be integer" >&2 ; return 2;}
  local p="."
  for ((i=0; i<n; i++)); do p="$p/.."; done
  builtin cd -- "$p"
}
