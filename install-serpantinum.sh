#!/usr/bin/env bash
# Instala a configuração Niri Serpantinum baseada no VM#00.
# A configuração e os arquivos de sessão são instalados com backup dos anteriores.
# O script não instala pacotes nem o Serpantinum; também instala o tema SDDM Material You.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { printf '%s\n' "$*" >&2; exit 1; }

if [[ "${EUID}" -eq 0 ]]; then
  die "Rode como o usuário da sessão. O sudo é usado só para os arquivos de sessão."
fi
command -v sudo >/dev/null 2>&1 || die "sudo não encontrado."

backup() {
  local path="$1"
  if [[ -e "${path}" ]]; then
    mv -- "${path}" "${path}.bak.$(date +%Y%m%d%H%M%S).$$"
  fi
}

sudo_backup() {
  local path="$1"
  if sudo test -e "$path"; then
    sudo mv -- "$path" "$path.bak.$(date +%Y%m%d%H%M%S).$$"
  fi
}

copy_dir() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "${dest}")"
  backup "${dest}"
  mkdir -p "${dest}"
  cp -a "${src}/." "${dest}/"
}

printf '%s\n' "Baixando mon e wlogout atuais do repositório dot"
bash "${ROOT}/scripts/install-dot-tools.sh"

printf '%s\n' "Instalando ~/.config/serpantinum/niri"
copy_dir "${ROOT}/serpantinum/niri" "${HOME}/.config/serpantinum/niri"

printf '%s\n' "Instalando ~/.config/serpantinum/settings.json"
mkdir -p "${HOME}/.config/serpantinum"
backup "${HOME}/.config/serpantinum/settings.json"
sed "s|@HOME@|${HOME}|g" "${ROOT}/serpantinum/settings.json" > "${HOME}/.config/serpantinum/settings.json"

printf '%s\n' "Instalando os atualizadores do Serpantinum"
mkdir -p "${HOME}/.config/serpantinum" "${HOME}/.local/bin"
backup "${HOME}/.config/serpantinum/update-manual-serpantinum.sh"
install -m 755 "${ROOT}/update-manual-serpantinum.sh" "${HOME}/.config/serpantinum/update-manual-serpantinum.sh"
backup "${HOME}/.local/bin/update-serpantinum.sh"
install -m 755 "${ROOT}/update-serpantinum.sh" "${HOME}/.local/bin/update-serpantinum.sh"

printf '%s\n' "Instalando tema SDDM Material You"
SDDM_THEME_SOURCE="$ROOT/serpantinum/sddm/themes/material-you"
SDDM_THEME_DEST="/usr/share/sddm/themes/material-you"
sudo_backup "$SDDM_THEME_DEST"
sudo install -d -m 755 "$SDDM_THEME_DEST"
sudo cp -r "$SDDM_THEME_SOURCE/." "$SDDM_THEME_DEST/"
sudo find "$SDDM_THEME_DEST" -type d -exec chmod 755 {} +
sudo find "$SDDM_THEME_DEST" -type f -exec chmod 644 {} +

SDDM_FONT_SOURCE="$SDDM_THEME_SOURCE/font/GoogleSans-VariableFont_GRAD,opsz,wght.ttf"
SDDM_FONT_DEST="/usr/share/fonts/TTF/GoogleSans-VariableFont_GRAD,opsz,wght.ttf"
sudo install -d -m 755 /usr/share/fonts/TTF
sudo_backup "$SDDM_FONT_DEST"
sudo install -m 644 "$SDDM_FONT_SOURCE" "$SDDM_FONT_DEST"
fc-cache -f /usr/share/fonts >/dev/null 2>&1 || true

SDDM_CONFIG="/etc/sddm.conf.d/10-material-you.conf"
sudo_backup "$SDDM_CONFIG"
sudo install -d -m 755 /etc/sddm.conf.d
sudo tee "$SDDM_CONFIG" >/dev/null <<'SDDM_EOF'
[Theme]
Current=material-you
ThemeDir=/usr/share/sddm/themes
SDDM_EOF
sudo chmod 644 "$SDDM_CONFIG"
printf '%s\n' "Instalando as sessões do login"
sudo_backup /usr/local/bin/niri-serpantinum-session
sudo_backup /usr/share/wayland-sessions/niri-serpantinum.desktop
sudo install -d -m 755 /usr/local/bin /usr/share/wayland-sessions
sudo install -m 755 "${ROOT}/sessions/niri-serpantinum-session" /usr/local/bin/niri-serpantinum-session
sudo install -m 644 "${ROOT}/sessions/niri-serpantinum.desktop" /usr/share/wayland-sessions/niri-serpantinum.desktop

if command -v niri >/dev/null 2>&1; then
  niri validate -c "${HOME}/.config/serpantinum/niri/config.kdl"
  printf '%s\n' "Configs válidas."
else
  printf '%s\n' "niri não está no PATH. As configs foram copiadas sem validate."
fi

printf '%s\n' "Pronto. Selecione Niri Serpantinum no login."
