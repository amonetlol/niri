#!/usr/bin/env bash
set -euo pipefail

die() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || die "curl não encontrado."
command -v bash >/dev/null 2>&1 || die "bash não encontrado."

backup() {
  local path="$1"
  if [[ -e "$path" ]]; then
    mv -- "$path" "$path.bak.$(date +%Y%m%d%H%M%S).$$"
  fi
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

DOT_RAW_BASE="https://raw.githubusercontent.com/amonetlol/dot/main/dotfiles/bin/.bin"
for script in mon wlogout; do
  curl --fail --silent --show-error --location \
    "${DOT_RAW_BASE}/${script}" --output "${tmp_dir}/${script}"
  [[ -s "${tmp_dir}/${script}" ]] || die "download vazio: ${script}"
  bash -n "${tmp_dir}/${script}"
done

mkdir -p "$HOME/.local/bin"
backup "$HOME/.bin/mon"
for script in mon wlogout; do
  backup "$HOME/.local/bin/${script}"
  install -m 755 "${tmp_dir}/${script}" "$HOME/.local/bin/${script}"
done

printf '%s\n' "mon e wlogout atualizados diretamente do repositório dot."
