#!/bin/bash
set -euo pipefail

export LC_ALL=C

if [ -z "$1" ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

SYSTEM_PATH="$(realpath "${1}")"

if [[ ! -e "$SYSTEM_PATH" ]]; then
  echo "The file or directory does not exist."
  exit 1
fi

files=$(find "$SYSTEM_PATH" -type f | sort -n)
hashes=""
ignore_paths=(
    "${SYSTEM_PATH}/.git"
    "${SYSTEM_PATH}/script/sandbox.sha256sum"
)

is_ignored() {
  local file_path="$1"

  for ignore in "${ignore_paths[@]}"; do
    if [[ "$file_path" == *"$ignore"* ]]; then
      return 0
    fi
  done

  if [ -f "$SYSTEM_PATH/.gitignore" ]; then
    while IFS= read -r pattern; do
      [[ -z "$pattern" || "$pattern" == \#* ]] && continue

      regex=$(echo "$pattern" | sed 's/\./\\./g; s/\*/.*/g; s/\?/./g')

      if [[ "$file_path" =~ $regex ]]; then
        return 0
      fi
    done < "$SYSTEM_PATH/.gitignore"
  fi

  return 1
}

while IFS= read -r file; do
    if ! is_ignored "$file"; then
        hash=$(shasum -a 256 "$file" | awk '{print $1}')
        hashes="${hashes}${hash}"
    fi
done <<< "$files"

echo -n "$hashes" | shasum -a 256 | awk '{print $1}'
