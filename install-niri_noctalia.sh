#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -ne 0 ]] || die "Rode como o usuário da sessão; sudo será usado para instalar a sessão."
command -v sudo >/dev/null 2>&1 || die "sudo não encontrado."

backup() {
  local path="$1"
  if [[ -e "$path" ]]; then
    mv -- "$path" "$path.bak.$(date +%Y%m%d%H%M%S).$$"
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
  mkdir -p "$(dirname "$dest")"
  backup "$dest"
  mkdir -p "$dest"
  cp -a "$src/." "$dest/"
}

printf '%s\n' "Baixando mon e wlogout atuais do repositório dot"
bash "$ROOT/scripts/install-dot-tools.sh"

printf '%s\n' "Instalando config Niri Noctalia em ~/.config/niri-noctalia"
copy_dir "$ROOT/niri-noctalia" "$HOME/.config/niri-noctalia"

printf '%s\n' "Configurando o diretório de wallpapers do Noctalia"
NOCTALIA_CONFIG_DIR="$HOME/.config/noctalia"
NOCTALIA_WALLPAPER_CONFIG="$NOCTALIA_CONFIG_DIR/niri-noctalia.toml"
mkdir -p "$NOCTALIA_CONFIG_DIR"
backup "$NOCTALIA_WALLPAPER_CONFIG"
sed "s|@HOME@|${HOME}|g" "$ROOT/niri-noctalia/noctalia/wallpaper.toml" > "$NOCTALIA_WALLPAPER_CONFIG"
chmod 644 "$NOCTALIA_WALLPAPER_CONFIG"

printf '%s\n' "Instalando a sessão Niri Noctalia"
sudo_backup /usr/local/bin/niri-default-session
sudo_backup /usr/share/wayland-sessions/niri.desktop
sudo_backup /usr/local/bin/niri-noctalia-session
sudo_backup /usr/share/wayland-sessions/niri-noctalia.desktop
sudo install -d -m 755 /usr/local/bin /usr/share/wayland-sessions
sudo install -m 755 "$ROOT/sessions/niri-noctalia-session" /usr/local/bin/niri-noctalia-session
sudo install -m 644 "$ROOT/sessions/niri-noctalia.desktop" /usr/share/wayland-sessions/niri-noctalia.desktop

if command -v niri >/dev/null 2>&1; then
  niri validate -c "$HOME/.config/niri-noctalia/config.kdl"
  printf '%s\n' "Config Niri Noctalia válida."
else
  printf '%s\n' "niri não está no PATH; a config foi copiada sem validate."
fi

printf '%s\n' "Pronto. Selecione Niri Noctalia no login."
