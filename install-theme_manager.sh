#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${ROOT}/themes"
DEST="${HOME}/.config/themes"

die() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -ne 0 ]] || die "Rode como o usuário da sessão; não use sudo."
[[ -d "${SOURCE}" ]] || die "Pasta de origem não encontrada: ${SOURCE}"
[[ -f "${SOURCE}/apply-theme.sh" ]] || die "apply-theme.sh não encontrado em ${SOURCE}."

mkdir -p "$(dirname "${DEST}")"
if [[ -e "${DEST}" || -L "${DEST}" ]]; then
  BACKUP="${DEST}.bak.$(date +%Y%m%d%H%M%S).$$"
  mv -- "${DEST}" "${BACKUP}"
  printf 'Backup criado em %s\n' "${BACKUP}"
fi

mkdir -p "${DEST}"
cp -a "${SOURCE}/." "${DEST}/"
chmod 755 "${DEST}/apply-theme.sh"

printf 'Theme manager instalado em %s\n' "${DEST}"
