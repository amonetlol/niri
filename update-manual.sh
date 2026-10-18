#!/usr/bin/env bash
# update-manual.sh — atualiza o serpantinum preservando as configs do usuário
# Replica o caminho de update do instalador oficial (deploy_package em modo
# update): só mexe em bin/ e src/, nunca em ~/.config.
set -euo pipefail

REPO="${SERPANTINUM_INSTALLER:-${XDG_CACHE_HOME:-$HOME/.cache}/serpantinum-installer}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/serpantinum"
STATE="$STATE_DIR/version"
TARGET="$HOME/.local/share/serpantinum"
REPO_SLUG="${REPO_SLUG:-ilyamiro/serpantinum}"

die() { echo "Erro: $*" >&2; exit 1; }

[ -d "$REPO/.git" ]  || die "clone do instalador não encontrado em $REPO (ajuste SERPANTINUM_INSTALLER)"
[ -f "$STATE" ]      || die "arquivo de estado não encontrado em $STATE"
[ -d "$TARGET" ]     || die "instalação não encontrada em $TARGET"

OLD=$(grep "^SERPANTINUM_COMMIT="  "$STATE" | cut -d= -f2- | tr -d '"' || true)
CURV=$(grep "^SERPANTINUM_VERSION=" "$STATE" | cut -d= -f2- | tr -d '"' || true)
[ -n "$OLD" ] || die "commit instalado não encontrado no estado"
echo "==> Instalado: versão ${CURV:-?} (commit ${OLD:0:7})"

echo "==> Atualizando clone do instalador ($REPO_SLUG)..."
git -C "$REPO" fetch origin --quiet
BRANCH=$(git -C "$REPO" symbolic-ref --short HEAD 2>/dev/null || echo master)
git -C "$REPO" reset --hard "origin/$BRANCH" --quiet

NEW=$(git -C "$REPO" rev-parse HEAD)
VER=$(cat "$REPO/version.txt" 2>/dev/null || echo "desconhecida")

if [ "$OLD" = "$NEW" ]; then
    echo "==> Você já está na versão mais recente ($VER). Nada a fazer."
    exit 0
fi
echo "==> Atualizando para a versão $VER (commit ${NEW:0:7})..."

changed=$(git -C "$REPO" diff --name-only --no-renames --diff-filter=AM "$OLD" "$NEW" 2>/dev/null || true)
deleted=$(git -C "$REPO" diff --name-only --no-renames --diff-filter=D  "$OLD" "$NEW" 2>/dev/null || true)

# --- remoções: apenas bin/ e src/ -----------------------------------------
n_del=0
if [ -n "$deleted" ]; then
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        case "$f" in
            bin/*|src/*)
                rm -f "$TARGET/$f"
                n_del=$((n_del + 1)) ;;
        esac
    done <<< "$deleted"
fi

# --- cópias: apenas bin/ e src/ (configs do usuário preservadas) -----------
n_chg=0
if [ -n "$changed" ]; then
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        case "$f" in
            bin/*)
                mkdir -p "$(dirname "$TARGET/$f")"
                cp "$REPO/$f" "$TARGET/$f"
                chmod +x "$TARGET/$f" 2>/dev/null || true
                n_chg=$((n_chg + 1)) ;;
            src/*)
                mkdir -p "$(dirname "$TARGET/$f")"
                cp "$REPO/$f" "$TARGET/$f"
                case "$f" in *.sh) chmod +x "$TARGET/$f" 2>/dev/null || true ;; esac
                n_chg=$((n_chg + 1)) ;;
        esac
    done <<< "$changed"
fi

find "$TARGET/src/scripts" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
echo "==> $n_chg arquivo(s) atualizado(s), $n_del removido(s). Configs do usuário intactas."

# --- grava o novo estado preservando telemetria e compositores -------------
TEL_ID=$(grep "^TELEMETRY_ID="         "$STATE" | cut -d= -f2- | tr -d '"' || true)
TEL_EN=$(grep "^ENABLE_TELEMETRY="     "$STATE" | cut -d= -f2- | tr -d '"' || true)
COMPS=$(grep  "^SELECTED_COMPOSITORS=" "$STATE" | cut -d= -f2- | tr -d '"' || true)
tmp="$STATE.tmp.$$"
printf 'SERPANTINUM_VERSION="%s"\nSERPANTINUM_COMMIT="%s"\nTELEMETRY_ID="%s"\nENABLE_TELEMETRY="%s"\nSELECTED_COMPOSITORS="%s"\n' \
    "$VER" "$NEW" "$TEL_ID" "$TEL_EN" "$COMPS" > "$tmp"
mv -f "$tmp" "$STATE"
echo "==> Estado gravado: $STATE"

# --- recarrega o shell se houver sessão gráfica ativa ----------------------
if pgrep -x quickshell >/dev/null 2>&1; then
    RUN_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export XDG_RUNTIME_DIR="$RUN_DIR"
    export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$RUN_DIR/bus}"
    # detecta o socket wayland da sessão ativa
    WL=$(ls "$RUN_DIR" 2>/dev/null | grep -E '^wayland-[0-9]+$' | head -n 1 || true)
    [ -n "$WL" ] && export WAYLAND_DISPLAY="$WL"
    if [ -n "$WL" ] && "$HOME/.local/bin/serpantinum" reload >/dev/null 2>&1; then
            echo "==> Shell recarregado com a nova versão."
        else
            echo "==> Aviso: não consegui recarregar o shell automaticamente ( rode 'serpantinum reload' na sessão gráfica )."
        fi
else
    echo "==> Shell não está em execução; será iniciado já na nova versão."
fi

echo "==> Concluído: serpantinum $VER."
