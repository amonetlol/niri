#!/usr/bin/env bash
# Instala as duas configs de niri que estão na vm#10.
#
#   Niri              ~/.config/niri
#   Niri Serpantinum  ~/.config/serpantinum/niri
#
# As entradas do SDDM ficam em /usr/share/wayland-sessions e pedem sudo.
# O script não instala pacotes, o Serpantinum nem os temas.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { printf '%s\n' "$*" >&2; exit 1; }

if [[ "${EUID}" -eq 0 ]]; then
  die "Rode como o usuário da sessão. O sudo é usado só para os arquivos de sessão."
fi

backup() {
  local path="$1"
  if [[ -e "${path}" ]]; then
    mv "${path}" "${path}.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

copy_dir() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "${dest}")"
  backup "${dest}"
  mkdir -p "${dest}"
  cp -a "${src}/." "${dest}/"
}

printf '%s\n' "Instalando ~/.config/niri"
copy_dir "${ROOT}/niri" "${HOME}/.config/niri"

printf '%s\n' "Instalando ~/.config/serpantinum/niri"
copy_dir "${ROOT}/serpantinum/niri" "${HOME}/.config/serpantinum/niri"

printf '%s\n' "Instalando ~/.config/serpantinum/settings.json"
mkdir -p "${HOME}/.config/serpantinum"
backup "${HOME}/.config/serpantinum/settings.json"
sed "s|@HOME@|${HOME}|g" "${ROOT}/serpantinum/settings.json" > "${HOME}/.config/serpantinum/settings.json"

printf '%s\n' "Instalando ~/.bin/mon"
mkdir -p "${HOME}/.bin"
backup "${HOME}/.bin/mon"
cp -a "${ROOT}/bin/mon" "${HOME}/.bin/mon"
chmod 755 "${HOME}/.bin/mon"

printf '%s\n' "Instalando as sessões do login"
sudo install -m 755 "${ROOT}/sessions/niri-default-session" /usr/local/bin/niri-default-session
sudo install -m 755 "${ROOT}/sessions/niri-serpantinum-session" /usr/local/bin/niri-serpantinum-session
sudo install -m 644 "${ROOT}/sessions/niri.desktop" /usr/share/wayland-sessions/niri.desktop
sudo install -m 644 "${ROOT}/sessions/niri-serpantinum.desktop" /usr/share/wayland-sessions/niri-serpantinum.desktop

if command -v niri >/dev/null 2>&1; then
  niri validate -c "${HOME}/.config/niri/config.kdl"
  niri validate -c "${HOME}/.config/serpantinum/niri/config.kdl"
  printf '%s\n' "Configs válidas."
else
  printf '%s\n' "niri não está no PATH. As configs foram copiadas sem validate."
fi

printf '%s\n' "Pronto. No login: Niri ou Niri Serpantinum."
