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

Configs que já existam em `~/.config/niri`, `~/.config/serpantinum/niri`, `settings.json` e `~/.bin/mon` são movidas para um `.bak.<data>`.

O instalador não instala pacotes. A sessão Serpantinum espera o `serpantinum`, Alacritty, Firefox, Nautilus, wlogout, cliphist, EasyEffects e o cursor Vimix. Em `serpantinum/settings.json`, `@HOME@` vira o home de quem roda o script. O monitor da sessão Serpantinum é `Virtual-1` em 1920x1080, teclado `br` `abnt2` e idioma `pt_BR.UTF-8`.

serpatium update: https://github.com/ilyamiro/serpantinum
