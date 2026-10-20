# Niri

Configs e sessões do Niri baseadas no VM#00:

- **Niri Serpantinum**: `~/.config/serpantinum/niri`, com o shell Serpantinum.
- **Niri Noctalia**: `~/.config/niri-noctalia`, com a topbar Noctalia.
- **Niri DMS**: `~/.config/niri-dms`, com a topbar DankMaterialShell.

Rode o instalador da sessão desejada como usuário normal:

```bash
chmod +x ./install-serpantinum.sh ./install-niri_noctalia.sh ./install-niri_dms.sh
./install-serpantinum.sh
# ou
./install-niri_noctalia.sh
# ou
./install-niri_dms.sh
```

Os instaladores preservam configs e entradas de sessão anteriores com sufixo `.bak.<data>.<pid>`. Eles não instalam Niri, Serpantinum, Noctalia nem DMS; esses componentes precisam estar disponíveis no sistema. O instalador Serpantinum também instala o tema Material You do SDDM.

A sessão Serpantinum espera Alacritty, Firefox, Nautilus, cliphist, EasyEffects, `serpantinum` e o cursor Vimix. Em `serpantinum/settings.json`, `@HOME@` é substituído pelo home do usuário; o monitor configurado é `Virtual-1` em 1920x1080, com teclado `br` `abnt2` e idioma `pt_BR.UTF-8`.

Cada instalador baixa as versões atuais de `mon` e `wlogout` diretamente de `amonetlol/dot` para `~/.local/bin`, para usar os scripts mantidos naquele repositório.

As sessões do login ficam em `/usr/share/wayland-sessions` e seus lançadores em `/usr/local/bin`.

O instalador Serpantinum também instala `update-serpantinum.sh` em `~/.local/bin` e `update-manual-serpantinum.sh` em `~/.config/serpantinum`. Para atualizar a instalação do Serpantinum, rode:

```bash
update-serpantinum.sh
```

O atualizador manual altera os arquivos do Serpantinum em `bin/` e `src/` e preserva as configurações do usuário.
