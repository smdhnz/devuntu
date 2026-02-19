# ===========================================================================
# Functions
# ===========================================================================

br-sync() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "⚠️  Not inside a Git repository. Skipping git_force_sync."
    return 1
  fi
  if [ -z "$1" ]; then
    local branch_name=$(git rev-parse --abbrev-ref HEAD)
    echo "==> Forcing current branch '$branch_name' to match origin/$branch_name"
    git stash push -m "WIP: 変更一時退避"
    git fetch origin
    git reset --hard origin/"$branch_name"
    git stash pop
  else
    local target_branch="$1"
    echo "==> Forcing branch '$target_branch' to match origin/$target_branch"
    git fetch origin
    git branch -f "$target_branch" origin/"$target_branch"
  fi
}

function activate () {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.venv/bin/activate" ]; then
      source "$dir/.venv/bin/activate"
      return
    fi
    dir=$(dirname "$dir")
  done
  uv venv && source .venv/bin/activate && uv pip install isort black pyright
}

function tree() {
  local TARGET_DIR="${1:-.}"
  local EXCLUDE_DIRS=("node_modules" "dist" "build" ".venv" "__pycache__")
  is_excluded() {
    local name="$1"
    for exclude in "${EXCLUDE_DIRS[@]}"; do
      if [[ "$name" == "$exclude" ]]; then return 0; fi
    done
    return 1
  }
  generate_tree() {
    local DIR=$1
    local PREFIX=$2
    local entries=()
    while IFS= read -r -d $'\0' entry; do entries+=("$entry"); done < <(find "$DIR" -mindepth 1 -maxdepth 1 ! -name ".*" -print0 | sort -z)
    local count=${#entries[@]}
    for i in "${!entries[@]}"; do
      local path="${entries[$i]}"
      local name=$(basename "$path")
      local connector="├──"
      local new_prefix="$PREFIX│   "
      if [ "$i" -eq "$((count - 1))" ]; then connector="└──"; new_prefix="$PREFIX    "; fi
      if [ -d "$path" ]; then
        echo "${PREFIX}${connector} ${name}/"
        if ! is_excluded "$name"; then generate_tree "$path" "$new_prefix"; fi
      else
        echo "${PREFIX}${connector} ${name}"
      fi
    done
  }
  echo "$(basename "$TARGET_DIR")/"
  generate_tree "$TARGET_DIR" ""
}

function xcat() {
  local EXCLUDE_DIRS=(".venv" "node_modules" "dist" ".git" "__pycache__" "test" ".DS_Store" ".idea" ".vscode")
  local target_paths=()
  local extensions=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --exp) extensions="$2"; shift 2 ;;
      *) target_paths+=("$1"); shift ;;
    esac
  done
  if [[ ${#target_paths[@]} -eq 0 ]]; then
    echo "Usage: xcat <パス1> [パス2...] [--exp <拡張子1,拡張子2...>]"
    return 1
  fi
  print_formatted() {
    local file="$1"
    echo "[${file}]"
    local ext="${file##*.}"
    [[ "$file" == "$ext" ]] && ext=""
    echo '```'"${ext}"
    cat "$file"
    echo '```'
    echo ""
  }
  local find_opts=()
  for dir in "${EXCLUDE_DIRS[@]}"; do find_opts+=(! -path "*/$dir/*"); done
  if [[ -n "$extensions" ]]; then
    local ext_args=()
    ext_args+=(\()
    IFS=',' read -ra ADDR <<< "$extensions"
    local is_first=true
    for ext in "${ADDR[@]}"; do
      if [ "$is_first" = true ]; then is_first=false; else ext_args+=(-o); fi
      ext_args+=(-name "*.${ext}")
    done
    ext_args+=(\))
    find_opts+=("${ext_args[@]}")
  fi
  find "${target_paths[@]}" -type f "${find_opts[@]}" | while read -r file; do print_formatted "$file"; done
  unset -f print_formatted
}

function fixperms() {
  local TARGET="${1:-.}"
  local EXCLUDE_DIRS=( ".venv" )
  local -a PRUNE_EXPR=()
  if ((${#EXCLUDE_DIRS[@]} > 0)); then
    PRUNE_EXPR+=( \( )
    for dir in "${EXCLUDE_DIRS[@]}"; do
      local d="${dir%/}"
      PRUNE_EXPR+=( -path "$TARGET/$d" -o -path "$TARGET/$d/*" -o )
    done
    unset 'PRUNE_EXPR[${#PRUNE_EXPR[@]}-1]'
    PRUNE_EXPR+=( \) -prune -o )
  fi
  if ((${#PRUNE_EXPR[@]})); then
    find "$TARGET" "${PRUNE_EXPR[@]}" -type d -exec chmod 755 {} +
    find "$TARGET" "${PRUNE_EXPR[@]}" -type f -exec chmod 644 {} +
  else
    find "$TARGET" -type d -exec chmod 755 {} +
    find "$TARGET" -type f -exec chmod 644 {} +
  fi
}

function del() {
  local trash_root="$HOME/.deleted"
  local trash_dir="$trash_root/$(date +%Y-%m-%d)"
  mkdir -p "$trash_dir"
  if [ -d "$trash_root" ]; then find "$trash_root" -maxdepth 1 -type d -mtime +7 -exec rm -rf {} +; fi
  if [ $# -eq 0 ]; then echo "Usage: del <file_or_dir> ..."; return 1; fi
  for item in "$@"; do
    [[ "$item" == -* ]] && continue
    if [ -e "$item" ]; then
      local base_name=$(basename "$item")
      local dest="$trash_dir/$base_name"
      if [ -e "$dest" ]; then dest="${dest}_$(date +%H%M%S)"; fi
      mv "$item" "$dest"
      echo "Moved to trash: $item"
    else
      echo "del: $item: No such file or directory"
    fi
  done
}

discord() {
  local WEBHOOK_URL="https://discord.com/api/webhooks/1430739694852898838/WoI7GIB7uM3PWTyN4FqPiBsHby_B-0RSwDRODq14Uds7FPOtJFcmW5NInOxsjVwowh8Q"
  if [ ! -t 0 ]; then
    CONTENT=$(cat)
    ESCAPED=$(printf '%s' "$CONTENT" | jq -Rs .)
    curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": $ESCAPED}" "${WEBHOOK_URL}"
    echo
    return
  fi
  if [ "$1" = "-f" ]; then
    FILE="$2"
    if [ "$3" = "-e" ]; then
      PASSPHRASE="$4"
      ENC_FILE="${FILE}.gpg"
      gpg --batch --yes --quiet --passphrase "$PASSPHRASE" -c "$FILE"
      curl -s -X POST -F "file=@${ENC_FILE}" "${WEBHOOK_URL}" | jq
      rm -f "$ENC_FILE"
    else
      curl -s -X POST -F "file=@${FILE}" "${WEBHOOK_URL}" | jq
    fi
    return
  fi
  CONTENT="$*"
  ESCAPED=$(printf '%s' "$CONTENT" | jq -Rs .)
  curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": $ESCAPED}" "${WEBHOOK_URL}"
  echo
}

# Copy to clipboard via OSC 52
clip() {
  local input
  if [ -t 0 ]; then
    input="$*"
  else
    input=$(cat)
  fi
  [ -z "$input" ] && return
  printf "\033]52;c;$(printf "%s" "$input" | base64 | tr -d '\n')\a"
}
