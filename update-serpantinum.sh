#!/usr/bin/env bash
# Arch updater for the official user-local Serpantinum installation.
set -euo pipefail

REPO_SLUG="${REPO_SLUG:-ilyamiro/serpantinum}"
REPO="${SERPANTINUM_INSTALLER:-${XDG_CACHE_HOME:-$HOME/.cache}/serpantinum-installer}"
MANUAL="$HOME/.config/serpantinum/update-manual-serpantinum.sh"
TARGET="$HOME/.local/share/serpantinum"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/serpantinum/version"

die() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

command -v pacman >/dev/null || die "pacman nao encontrado; este script e para Arch e derivados."
command -v git >/dev/null || die "git nao encontrado."
[[ -x "$MANUAL" ]] || die "atualizador manual nao encontrado em $MANUAL."

if pacman -Q serpantinum >/dev/null 2>&1; then
    die "Serpantinum ainda esta registrado como pacote local no pacman. Migre para ~/.local/share/serpantinum antes de atualizar; este script nao compila nem instala PKGBUILD/AUR."
fi

if [[ -d "$REPO/.git" ]]; then
    git -C "$REPO" diff --quiet && git -C "$REPO" diff --cached --quiet \
        || die "o clone em $REPO tem alteracoes locais; preservei-as."
    git -C "$REPO" remote set-url origin "https://github.com/$REPO_SLUG.git"
    git -C "$REPO" fetch origin --quiet
else
    mkdir -p "$(dirname "$REPO")"
    git clone --quiet "https://github.com/$REPO_SLUG.git" "$REPO"
fi

REF="$(git -C "$REPO" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)"
if [[ -z "$REF" ]]; then
    for candidate in origin/master origin/main; do
        if git -C "$REPO" rev-parse --verify "$candidate" >/dev/null 2>&1; then
            REF="$candidate"
            break
        fi
    done
fi
[[ -n "$REF" ]] || die "nao encontrei a branch principal do repositorio."
git -C "$REPO" reset --hard "$REF" --quiet

[[ -d "$TARGET" ]] || die "instalacao manual nao encontrada em $TARGET."
[[ -f "$STATE" ]] || die "estado da instalacao nao encontrado em $STATE."
export SERPANTINUM_INSTALLER="$REPO"
exec bash "$MANUAL"
