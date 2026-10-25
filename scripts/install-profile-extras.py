#!/usr/bin/env python3
"""Install profile helpers and resolve portable paths after the base config copy."""
from pathlib import Path
import datetime
import shutil
import sys

profile = sys.argv[1]
repo = Path(__file__).resolve().parent.parent
home = Path.home()
destinations = {
    'niri-noctalia': home / '.config/niri-noctalia',
    'niri-dms': home / '.config/niri-dms',
    'serpantinum': home / '.config/serpantinum',
}
target = destinations[profile]
stamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')


def copy_with_backup(source, destination):
    if destination.exists():
        destination.rename(str(destination) + '.bak.' + stamp)
    destination.parent.mkdir(parents=True, exist_ok=True)
    if source.is_dir():
        shutil.copytree(source, destination)
    else:
        shutil.copy2(source, destination)


if profile == 'serpantinum':
    for name in ('kitty', 'rofi', 'scripts', 'BINDS.txt', 'starship-serpantinum.toml'):
        copy_with_backup(repo / profile / name, target / name)
    copy_with_backup(repo / profile / 'themes/Vviva.json', home / '.local/state/serpantinum/themes/Vviva.json')
    copy_with_backup(repo / 'themes/assets/Serpantinum-Vviva', home / '.themes/Serpantinum-Vviva')

for path in target.rglob('*'):
    if not path.is_file() or any('.bak.' in part for part in path.parts):
        continue
    try:
        text = path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        continue
    if '@HOME@' in text:
        path.write_text(text.replace('@HOME@', str(home)), encoding='utf-8')
    if text.startswith('#!'):
        path.chmod(0o755)

theme_profile = {
    'niri-noctalia': 'gtktheme-Niri-Noctalia',
    'niri-dms': 'gtktheme-Niri-DMS',
    'serpantinum': 'gtktheme-Niri-Serpantinum',
}[profile]
copy_with_backup(repo / 'themes' / theme_profile, home / '.config/themes' / theme_profile)
apply_theme = home / '.config/themes/apply-theme.sh'
copy_with_backup(repo / 'themes/apply-theme.sh', apply_theme)
apply_theme.chmod(0o755)
print('Profile helpers installed:', target)
