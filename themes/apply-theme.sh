#!/usr/bin/env bash
set -euo pipefail
profile="${1:?usage: apply-theme.sh gtktheme-NAME}"
dir="$HOME/.config/themes/$profile"
for key in font themes icons cursor; do
  [[ -r "$dir/$key" ]] || { echo "Missing $dir/$key" >&2; exit 1; }
done
font=$(<"$dir/font")
theme=$(<"$dir/themes")
icons=$(<"$dir/icons")
cursor=$(<"$dir/cursor")
python3 - "$font" "$theme" "$icons" "$cursor" <<'PY'
from pathlib import Path
import sys
font, theme, icons, cursor = sys.argv[1:]
updates = {
    "gtk-font-name": font,
    "gtk-theme-name": theme,
    "gtk-icon-theme-name": icons,
    "gtk-cursor-theme-name": cursor,
    "gtk-cursor-theme-size": "24",
    "gtk-application-prefer-dark-theme": "1",
}
for target in (Path.home()/".config/gtk-3.0/settings.ini", Path.home()/".config/gtk-4.0/settings.ini"):
    target.parent.mkdir(parents=True, exist_ok=True)
    lines = target.read_text().splitlines() if target.exists() else []
    out, pending = [], dict(updates)
    in_settings = False
    found_settings = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            if in_settings:
                out.extend(f"{key}={value}" for key, value in pending.items())
                pending.clear()
            in_settings = stripped == "[Settings]"
            found_settings |= in_settings
            out.append(line)
        elif in_settings and "=" in line and line.split("=", 1)[0].strip() in pending:
            key = line.split("=", 1)[0].strip()
            out.append(f"{key}={pending.pop(key)}")
        else:
            out.append(line)
    if in_settings:
        out.extend(f"{key}={value}" for key, value in pending.items())
    elif not found_settings:
        if out and out[-1] != "": out.append("")
        out.append("[Settings]")
        out.extend(f"{key}={value}" for key, value in pending.items())
    target.write_text("\n".join(out) + "\n")
PY
if gsettings list-schemas 2>/dev/null | grep -qx org.gnome.desktop.interface; then
  gsettings set org.gnome.desktop.interface font-name "$font" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface gtk-theme "$theme" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "$icons" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-theme "$cursor" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
fi
