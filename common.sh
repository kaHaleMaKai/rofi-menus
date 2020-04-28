_script_path="$(basename "$(readlink -f "${BASH_SOURCE[1]:-.}")")"
_script_name="${_script_path/.sh}"

common.remove-markup() {
  sed -r 's_</?[^>]+>|[[:space:]]+✔__g'
}

common.get-input-with-markup() {
  local prompt="$1"
  rofi -i -markup-rows -dmenu -p "$prompt" \
  | common.remove-markup
}

common.get-and-cache-input() {
  local rofi_prompt="$1"
  local cache_file="${HOME}/.cache/rofi3.${_script_name}-cache"
  if [[ ! -f "$cache_file" ]]; then
    touch "$cache_file"
  fi
  local cache="$(< "$cache_file")"
  local value="$(
    echo "$cache" \
    | sed 's/^[0-9]*;//' \
    | rofi -i -dmenu -p "$rofi_prompt"
  )"
  if [[ -n "$value" ]]; then
    { echo "1;${value}"; echo "$cache"; } \
      | awk -F ';' '{ s[$2]+=$1 } END { for (i in s) {printf "%d;%s\n", s[i], i} }' \
      | sort -t ';' -k1  -n -r \
      | head -n 1000 \
      > "$cache_file"
  fi
  echo "$value"
}

# vim: ft=bash
