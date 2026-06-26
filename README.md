# Configuration Neovim

Configuration Neovim basée sur **lazy.nvim**, pensée pour le développement
C/C++, Python, Rust, GDScript (Godot), C# et le web (TS/JS/HTML/CSS/Svelte).

L'objectif est qu'elle fonctionne sur une nouvelle machine **par simple
`git clone`** : lazy.nvim, les plugins, les serveurs LSP (via Mason) et le
formatter 42 (`c_formatter_42`) s'installent automatiquement au premier
lancement. Il reste cependant quelques **dépendances système** à installer
au préalable (voir ci-dessous).

---

## 1. Prérequis système (obligatoires)

| Dépendance            | Pourquoi                                                                 |
| --------------------- | ----------------------------------------------------------------------- |
| **Neovim ≥ 0.12**     | La config utilise l'API moderne `vim.lsp.config()` et treesitter `main`.|
| **git**               | Clone de la config, de lazy.nvim et des plugins.                        |
| **curl**              | Téléchargements (plugins, registres Mason).                             |
| **gcc / clang + make**| Compilation des parsers treesitter et de `telescope-fzf-native`.        |
| **ripgrep** (`rg`)    | Recherche dans les fichiers (`<leader>fg` live grep de Telescope).      |
| **fd** (`fd-find`)    | Recherche de fichiers rapide pour Telescope (recommandé).               |
| **unzip**             | Décompression de certains paquets Mason.                                |

### Installation des prérequis

**Arch Linux**
```bash
sudo pacman -S neovim git curl base-devel ripgrep fd unzip
```

**Debian / Ubuntu**
```bash
sudo apt install neovim git curl build-essential ripgrep fd-find unzip
# Neovim des dépôts est souvent trop ancien : préférez l'AppImage ou le PPA
# pour obtenir une version >= 0.12.
```

**macOS (Homebrew)**
```bash
brew install neovim git curl ripgrep fd
```

---

## 2. Dépendances par langage (optionnelles)

Mason installe **automatiquement au premier lancement** :

- les **serveurs LSP** listés dans `mason-lspconfig` (`ensure_installed`) ;
- les **formatters / outils** listés dans `mason-tool-installer`
  (`prettier`, `stylua`, `elm-format`, `csharpier`, `gdtoolkit`, `roslyn`,
  `tree-sitter-cli`).

Tout ça est déclaré dans `lua/plugins/lsp/mason.lua` : **rien à installer à la
main côté Neovim**. En revanche, ces serveurs et formatters ont besoin d'un
**runtime système** présent (node, python, dotnet…). N'installez que ce qui
correspond aux langages que vous utilisez.

| Langage / outil | Runtime système requis                      | Outils auto-installés par Mason                 |
| --------------- | ------------------------------------------- | ----------------------------------------------- |
| Web (TS/JS/...) | **node + npm**                              | LSP `ts_ls`, `html`, `cssls`, `svelte`, `graphql`, formatter `prettier` |
| Python          | **python3 + venv/pip**                      | LSP `pylsp`, `ruff` (LSP + formatter)           |
| Rust            | **rustup** (`rustc`, `cargo`, `rustfmt`)    | LSP `rust_analyzer` (`rustfmt` vient de rustup) |
| Lua             | —                                           | Formatter `stylua`                              |
| C#              | **.NET SDK** (`dotnet`)                      | LSP `roslyn`, formatter `csharpier`             |
| GDScript/Godot  | **python3** + **Godot Editor** (port 6005)  | `gdtoolkit` (`gdformat`/`gdlint`)               |
| C/C++ (42)      | **python3** (venv auto)                      | `c_formatter_42` (venv dédié, hors Mason)       |
| Markdown/images | **ImageMagick + luarocks**, terminal **kitty**| Rendu d'images via `image.nvim`               |

### Installation des runtimes

```bash
# Web (pour prettier + serveurs TS/HTML/CSS)
sudo pacman -S nodejs npm          # ou: brew install node

# Python
sudo pacman -S python python-pip   # venv inclus

# Rust (recommandé via rustup ; apporte rustfmt)
sudo pacman -S rustup && rustup default stable

# C# / Godot C#
sudo pacman -S dotnet-sdk

# image.nvim (rendu d'images dans le terminal kitty)
sudo pacman -S imagemagick luarocks
```

> Seul **`rustfmt`** n'est pas géré par Mason : il est fourni par la toolchain
> `rustup`. Tous les autres formatters s'installent tout seuls.

---

## 3. Installation de la config

> ⚠️ **Sauvegardez d'abord toute config Neovim existante** si vous en avez une :
> ```bash
> mv ~/.config/nvim ~/.config/nvim.bak
> mv ~/.local/share/nvim ~/.local/share/nvim.bak   # données/plugins
> ```

Clonez ce dépôt dans `~/.config/nvim` :

```bash
git clone <URL_DU_DEPOT> ~/.config/nvim
```

Lancez Neovim :

```bash
nvim
```

Au premier démarrage, automatiquement :

1. **lazy.nvim** se clone tout seul (`lua/config/lazy.lua`).
2. Tous les plugins sont téléchargés et installés.
3. **Mason** installe les serveurs LSP (`clangd`, `lua_ls`, `pylsp`, `ruff`,
   `rust_analyzer`, `ts_ls`, `html`, `cssls`…) **et** les formatters/outils
   (`prettier`, `stylua`, `csharpier`, `gdtoolkit`, `roslyn`, `tree-sitter-cli`).
4. **Treesitter** compile les parsers (C, C++, Lua, Python, Rust, GDScript, C#…).
5. **`c_formatter_42`** s'installe dans un venv dédié
   (`~/.local/share/c_formatter_42_venv`) la première fois qu'un `.c`/`.h` est ouvert.

Laissez les installations se terminer (suivez la progression avec `:Lazy` et
`:Mason`), puis **redémarrez Neovim**.

### Vérification

```vim
:checkhealth      " diagnostic global de Neovim
:Lazy             " état des plugins
:Mason            " état des serveurs LSP / outils
:checkhealth nvim-treesitter
```

---

## 4. Notes spécifiques

### Godot / GDScript
Le LSP GDScript se connecte à l'éditeur Godot via TCP sur `127.0.0.1:6005`.
Il faut donc **lancer Godot Editor** sur le projet (présence de `project.godot`)
pour avoir l'autocomplétion. Voir `lua/plugins/godotdev.lua` et
`lua/plugins/lsp/lspconfig.lua`.

### Norme 42 (C/C++)
- Le header 42 utilise `$USER` ; définissez si besoin `vim.g.user42` /
  `vim.g.mail42` (voir `lua/plugins/42norm.lua`).
- `<leader>4t` (ou `:Norm42Toggle`) active le format-on-save à la norme 42.
- `c_formatter_42` est installé automatiquement dans un venv dédié pour ne pas
  toucher au Python système (cassé/externally-managed sur Arch & co).

### image.nvim
Le rendu d'images n'est actif que dans un terminal compatible (**kitty** par
défaut) et nécessite ImageMagick + le rock `magick` (via luarocks). En dehors,
le plugin se désactive silencieusement (pas d'erreur).

---

## 5. Reproductibilité des versions

Le fichier `lazy-lock.json` est **versionné** (suivi par git) : il fige le
commit exact de chaque plugin. Sur une nouvelle machine, après le clone,
lancez `:Lazy restore` pour réinstaller **exactement les mêmes versions** que
sur la machine d'origine.

Pour mettre les plugins à jour : `:Lazy update`, puis committez le
`lazy-lock.json` modifié. Vos mises à jour restent ainsi volontaires et tracées.

---

## 6. Dépannage rapide

| Symptôme                                   | Piste                                                            |
| ------------------------------------------ | --------------------------------------------------------------- |
| Erreurs treesitter au démarrage            | `gcc`/`make` manquant, ou Neovim < 0.12. Relancez `:TSUpdate`.  |
| `live grep` / `find files` ne marche pas   | Installez `ripgrep` et `fd`.                                    |
| LSP non démarré                            | `:Mason` pour vérifier l'install ; runtime du langage présent ? |
| Formatter inactif (prettier, csharpier…)   | Runtime manquant (node/dotnet…). Vérifiez l'install via `:Mason`.|
| C# / Godot C# sans complétion              | Installez le **.NET SDK**.                                      |
| Pas de rendu d'images                      | Terminal kitty + ImageMagick + luarocks requis.                |

---

## 7. Le formateur 42

### À quoi ça sert

Le formateur 42 met automatiquement un fichier **C** en conformité avec le
style de codage de l'école 42 (la « Norm »), ce qui évite de repositionner à la
main l'indentation, les alignements et les espaces. Il repose sur deux briques :

- **`c_formatter_42`** : le formateur de fond ;
- **`norm42_align`** : un pré-processeur propre à cette config qui affine
  certains détails (alignement des déclarations, accolades) avant de passer la
  main à `c_formatter_42`.

### Principales fonctionnalités

- Réindentation avec **tabulations** à la bonne profondeur ;
- **Alignement** des déclarations de variables (type / nom) sur des colonnes ;
- **Accolades style Allman** (accolade ouvrante sur sa propre ligne) ;
- **Espacement** normalisé (par ex. une espace après les virgules) ;
- **Mise à jour automatique** de la date / du login dans le header 42 à la
  sauvegarde (si un header est déjà présent) ;
- Activable à la demande : `<leader>4t` (toggle format-on-save),
  `<leader>4f` (formater maintenant), `<leader>4r` / `<leader>4d`
  (compiler & exécuter avec les flags 42).

### Ce que le formateur 42 n'est PAS

Pour éviter tout malentendu sur la finalité de l'outil :

- **Ce n'est pas un générateur de code.** Il ne rédige ni logique, ni
  algorithme, ni solution : il **ré-agence un code existant**, sans jamais en
  modifier le comportement.
- **Ce n'est pas un substitut à l'apprentissage de la Norm.** La compréhension
  et la maîtrise des règles restent indispensables ; l'outil n'est qu'un confort
  de mise en forme.
- **Ce n'est pas un moyen de « faire passer » un travail.** La forme change, le
  fond reste celui de l'auteur — le code doit demeurer une œuvre personnelle.

---

## 8. Crédits & remerciements

Cette configuration n'est qu'un assemblage : le mérite revient aux auteurs des
outils ci-dessous. Merci à eux. (Identifiants = comptes GitHub.)

### Spécifique 42

| Outil | Auteur | Rôle |
| ----- | ------ | ---- |
| **42header** | **[`42paris`](https://github.com/42paris/42header)** (organisation officielle de l'école 42) | Header 42 (`<F1>`, mise à jour auto) |
| **c_formatter_42** | **[`peterPAN85-ofthesun`](https://github.com/peterPAN85-ofthesun)** (paquet PyPI `c-formatter-42`) | Formateur C à la Norm 42 |
| **Intégration 42-norm** (`norm42_align` + workflow) | **[`peterPAN85-ofthesun`](https://github.com/peterPAN85-ofthesun)** | Pré-processeur d'alignement & raccourcis (cf. `lua/plugins/42norm.lua`) |

### Plugins Neovim

| Domaine | Plugins (auteur GitHub) |
| ------- | ----------------------- |
| Gestionnaire | lazy.nvim (`folke`) |
| LSP | nvim-lspconfig (`neovim`), mason.nvim & mason-lspconfig.nvim (`mason-org`), mason-tool-installer.nvim (`WhoIsSethDaniel`), clangd_extensions.nvim (`p00f`), roslyn.nvim (`seblyng`), lazydev.nvim (`folke`), nvim-lsp-file-operations (`antosha417`) |
| Complétion | nvim-cmp & cmp-* (`hrsh7th`), LuaSnip (`L3MON4D3`), cmp_luasnip (`saadparwaiz1`), friendly-snippets (`rafamadriz`), lspkind.nvim (`onsails`) |
| Formatage / Syntaxe | conform.nvim (`stevearc`), nvim-treesitter (`nvim-treesitter`) |
| Navigation | telescope.nvim & telescope-fzf-native (`nvim-telescope`), plenary.nvim (`nvim-lua`), nvim-tree.lua & nvim-web-devicons (`nvim-tree`), nvim-window-picker (`s1n7ax`) |
| Interface | cyberdream.nvim (`scottmckendry`), tokyonight.nvim (`folke`), lualine.nvim (`nvim-lualine`), bufferline.nvim (`akinsho`), alpha-nvim (`goolord`), noice.nvim & which-key.nvim & trouble.nvim & todo-comments.nvim (`folke`), nui.nvim (`MunifTanjim`), nvim-notify (`rcarriga`), indent-blankline.nvim (`lukas-reineke`), rainbow-delimiters.nvim (`hiphish`), satellite.nvim (`lewis6991`), profile.nvim (`Kurama622`), image.nvim (`3rd`) + magick (`leafo`), cord.nvim (`vyfor`) |
| Édition | Comment.nvim (`numToStr`), nvim-autopairs (`windwp`), gitsigns.nvim (`lewis6991`) |
| C / C++ | ouroboros (`jakemason`) |
| Godot / Debug | godotdev.nvim (`Mathijs-Bakker`), nvim-dap (`mfussenegger`), nvim-dap-ui (`rcarriga`), nvim-nio (`nvim-neotest`) |

### Outils en ligne de commande (LSP / formatters)

clangd (`LLVM`), rust-analyzer (`rust-lang`), ruff (`astral-sh`),
prettier (`prettier`), stylua (`JohnnyMorganz`), rustfmt (`rust-lang`),
csharpier (`belav`), gdtoolkit / gdformat (`Scony`), tree-sitter (`tree-sitter`).
