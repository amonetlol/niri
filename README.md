# niri

Configs de niri e o instalador delas.

Duas entradas no login:

- **Niri** usa `~/.config/niri`. A sessão limpa `NIRI_CONFIG`.
- **Niri Serpantinum** usa `~/.config/serpantinum/niri/config.kdl` e sobe o shell.

```bash
chmod +x ./install.sh
./install.sh
```

O script pede sudo para gravar:

- `/usr/local/bin/niri-default-session`
- `/usr/local/bin/niri-serpantinum-session`
- `/usr/share/wayland-sessions/niri.desktop`
- `/usr/share/wayland-sessions/niri-serpantinum.desktop`
- `/usr/share/sddm/themes/material-you`
- `/usr/share/fonts/TTF/GoogleSans-VariableFont_GRAD,opsz,wght.ttf`
- `/etc/sddm.conf.d/10-material-you.conf`

Configs que já existam em `~/.config/niri`, `~/.config/serpantinum/niri`, `settings.json` e `~/.local/bin/mon` são movidas para um `.bak.<data>`. Um `~/.bin/mon` legado também é preservado como backup.

O instalador não instala pacotes. Também instala o tema SDDM Material You do Serpantinum (MIT conforme metadata.desktop; commit upstream 4d54b886979aebac6d1c4245d5ea4a06c4fa1c04). A sessão Serpantinum espera o `serpantinum`, Alacritty, Firefox, Nautilus, wlogout, cliphist, EasyEffects e o cursor Vimix. Em `serpantinum/settings.json`, `@HOME@` vira o home de quem roda o script. O monitor da sessão Serpantinum é `Virtual-1` em 1920x1080, teclado `br` `abnt2` e idioma `pt_BR.UTF-8`.

Atualização do Serpantinum: https://github.com/ilyamiro/serpantinum. O script ./update.sh atualiza bin/ e src/ e preserva as configurações pessoais.
