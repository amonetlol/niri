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

A sessão Serpantinum espera Kitty, Firefox, Nautilus, cliphist, EasyEffects, `serpantinum` e o cursor Vimix. Em `serpantinum/settings.json`, `@HOME@` é substituído pelo home do usuário; o monitor configurado é `Virtual-1` em 1920x1080, com teclado `br` `abnt2` e idioma `pt_BR.UTF-8`.

Cada instalador baixa as versões atuais de `mon` e `wlogout` diretamente de `amonetlol/dot` para `~/.local/bin`, para usar os scripts mantidos naquele repositório.

As sessões do login ficam em `/usr/share/wayland-sessions` e seus lançadores em `/usr/local/bin`.

O instalador Serpantinum também instala `update-serpantinum.sh` em `~/.local/bin` e `update-manual-serpantinum.sh` em `~/.config/serpantinum`. Para atualizar a instalação do Serpantinum, rode:

```bash
update-serpantinum.sh
```

O atualizador manual altera os arquivos do Serpantinum em `bin/` e `src/` e preserva as configurações do usuário.

## Configurações sincronizadas da VM one

As três sessões têm cópias independentes do Kitty, usando Bash e 0xProto Nerd Font 11:

| Sessão | Configuração do Kitty | Tema |
| --- | --- | --- |
| Noctalia | `~/.config/niri-noctalia/kitty` | Kitten |
| DMS | `~/.config/niri-dms/kitty` | Monochrome |
| Serpantinum | `~/.config/serpantinum/kitty` | Vviva, com fundo `#303446` |

Os atalhos de terminal usam o lançador de cada perfil. A barra do Kitty aparece com duas ou mais abas, nomeadas `tab N`, e a decoração da janela fica oculta. Atalhos: `Alt+←/→` troca de aba, `Alt+↑` cria, `Alt+↓` fecha, `Alt+1..9` seleciona a aba e `Ctrl+Shift+F1` abre o guia em Rofi.

No Noctalia e no Serpantinum, `Super+F1` abre o guia de atalhos em Rofi e `Super+F2` abre o guia nativo do Niri. Os guias e temas Rofi ficam dentro do perfil.

Os presets Starship de Noctalia e Serpantinum ficam dentro de suas configurações e são carregados pelo Kitty correspondente. O preset Vviva do Serpantinum também é instalado em `~/.local/state/serpantinum/themes`.

Os instaladores resolvem `@HOME@`, tornam os auxiliares executáveis e instalam o perfil GTK correspondente em `~/.config/themes`. O tema GTK personalizado Serpantinum-Vviva é incluído em `themes/assets`; Colloid Grey Dark GTK e os ícones Colloid Grey Dark são dependências externas para os perfis que os utilizam. As configurações não instalam Kitty, Rofi, Starship nem as fontes.

Na VM, o Noctalia usa `~/.config/niri`; neste repositório e no instalador, os caminhos são adaptados para `~/.config/niri-noctalia`.
