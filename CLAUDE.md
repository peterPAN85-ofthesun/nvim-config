# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Neovim configuration built with **lazy.nvim** as the plugin manager. The configuration uses a dual plugin management approach:
- **lazy.nvim**: Modern Lua-based plugin manager (primary)
- **vim-plug**: Legacy plugin manager for a few remaining plugins (tpope/vim-sensible, plenary.nvim, jakemason/ouroboros)

### Directory Structure

```
.
├── init.lua                    # Entry point: loads core, filetypes, lazy, and vim-plug
├── lua/
│   ├── core/
│   │   ├── init.lua           # Loads options, keymaps, headertosource
│   │   ├── options.lua        # Vim options (tabs=2 spaces, clipboard, splits, etc.)
│   │   ├── keymaps.lua        # Core keymaps (leader=<Space>, ;;=exit insert, etc.)
│   │   └── headertosource.lua # F3: Auto-implement C/C++ methods from header to source
│   ├── config/
│   │   ├── lazy.lua           # lazy.nvim setup and plugin directory imports
│   │   └── filetypes.lua      # Custom filetype detection (e.g., .gd -> gdscript)
│   └── plugins/
│       ├── init.lua           # Base plugins (plenary.nvim)
│       ├── lsp/               # LSP configurations
│       │   ├── lspconfig.lua  # LSP configs for Python, Rust, GDScript, custom keymaps
│       │   ├── mason.lua      # LSP server installer
│       │   └── clangd_extensions.lua
│       └── *.lua              # Individual plugin configs (cmake-tools, telescope, etc.)
```

### Key Architectural Components

**Plugin Loading Pattern**: All plugins in `lua/plugins/` and `lua/plugins/lsp/` are automatically imported by lazy.nvim (configured in `lua/config/lazy.lua:19`). Each plugin file returns a lazy.nvim spec table.

**LSP Configuration**: LSPs are configured using the modern `vim.lsp.config()` API (not lspconfig.setup). Auto-enabled via FileType autocmds in `lua/plugins/lsp/lspconfig.lua:279-317`.

**C/C++ Development Workflow**: Uses custom headertosource module that parses method signatures in headers and generates implementations in corresponding .cpp/.c files with proper namespace/class scoping.

## Language Support

This configuration is optimized for:
- **C/C++**: clangd LSP, cmake-tools, custom header-to-source implementation (F3), Ouroboros header/source switching (F4)
- **Python**: pylsp + ruff LSP, black formatting, mypy type checking
- **Rust**: rust-analyzer with clippy and inlay hints
- **GDScript**: Godot LSP integration via TCP (port 6005), requires Godot Editor running
- **Web**: TypeScript, JavaScript, HTML, CSS, Svelte (ts_ls, prettier)

## Common Commands

### Plugin Management
```vim
:Lazy                  " Open lazy.nvim UI
:Lazy sync             " Update and install plugins
:Mason                 " Manage LSP servers, formatters, linters
```

### CMake Workflow (C/C++)
```vim
<C-r>                  " CMakeBuild (keybinding in cmake-tools.lua:156)
<C-p>                  " CMakeRun (keybinding in cmake-tools.lua:162)
:CMakeGenerate         " Generate build files with presets
:CMakeSelectBuildType  " Choose Debug/Release/etc.
```
Build output directory: `out/${variant:buildType}` (configured in cmake-tools.lua:17-22)

### C/C++ Development
```vim
<F3>                   " Implement method under cursor in .cpp/.c file (headertosource.lua:84)
<F4>                   " Switch between header/source (Ouroboros)
<leader>ch             " Switch Source/Header (clangd, lspconfig.lua:135)
```

### LSP Operations
```vim
K                      " Show signature help (cycles through overloads, lspconfig.lua:117)
<leader>K              " Show hover documentation (lspconfig.lua:118)
gd                     " Go to definition (Telescope, lspconfig.lua:93)
gD                     " Go to declaration (lspconfig.lua:92)
gi                     " Go to implementation (Telescope, lspconfig.lua:94)
gR                     " Show references (Telescope, lspconfig.lua:91)
<leader>ca             " Code actions (lspconfig.lua:90)
<leader>rn             " Rename symbol (lspconfig.lua:98)
[d / ]d                " Navigate diagnostics (lspconfig.lua:102-116)
<leader>d              " Show line diagnostics (lspconfig.lua:100)
<leader>F              " Format buffer (lspconfig.lua:119)
```

### File Navigation
```vim
<leader>ff             " Find files (Telescope, telescope.lua:40)
<leader>fg             " Live grep in files (Telescope, telescope.lua:46)
<leader>fb             " Find buffers (Telescope, telescope.lua:52)
<leader>fx             " Grep word under cursor (Telescope, telescope.lua:58)
<S-h> / <S-l>          " Navigate buffers (keymaps.lua:30-31)
```

### Terminal
```vim
<leader>t              " Open terminal in split (keymaps.lua:34)
<ESC>                  " Exit terminal mode (keymaps.lua:35)
```

## Important Configuration Details

### Editor Settings (core/options.lua)
- **Indentation**: 2 spaces, tabs NOT expanded to spaces (expandtab=false)
- **Clipboard**: Uses system clipboard by default
- **Leader key**: Space (set in core/keymaps.lua:2)
- **Exit insert mode**: Type `;;` instead of ESC (keymaps.lua:8)

### LSP Signature Help Behavior
The `K` keybinding uses a custom function `show_signature_next()` (lspconfig.lua:5-73) that cycles through function overloads. Falls back to hover if no signature help is available.

### Format on Save
Enabled via conform.nvim (conform.lua:30-34) with 1000ms timeout. Language-specific formatters configured in `formatters_by_ft` table.

### Godot Integration
- GDScript filetype auto-detection for `.gd` files (filetypes.lua)
- LSP connects to Godot Editor on `127.0.0.1:6005` (lspconfig.lua:306)
- Requires `project.godot` in project root
- C# support via omnisharp (mason.lua:45)

### clangd Configuration
Configured with:
- Background indexing
- clang-tidy integration
- IWYU header insertion
- Function argument placeholders
- Detailed completion style

Root detection: `compile_commands.json`, `CMakeLists.txt`, Makefile, `.git` (lspconfig.lua:137-149)

## Development Workflow Notes

1. **Adding new plugins**: Create a new file in `lua/plugins/` returning a lazy.nvim spec. It will be auto-imported.

2. **LSP installation**: Add server name to `mason.lua:31-46` ensure_installed list for portability.

3. **Custom keybindings**: Global keymaps go in `core/keymaps.lua`, plugin-specific keymaps in the plugin's config file.

4. **C++ method implementation**: Position cursor on method declaration in header, press F3. The method will be generated in the corresponding .cpp file with class scope and skeleton implementation.

## CRITICAL: Keybinding Documentation Update - AUTOMATIC EXECUTION REQUIRED

**MANDATORY RULE FOR CLAUDE CODE**: Whenever you (Claude) add, modify, or remove keybindings in the Neovim configuration, you MUST **IMMEDIATELY AND AUTOMATICALLY** execute the `:UpdateBindings` command to update `binding_list.csv`. This is NOT optional.

### Automatic Update System
The configuration includes a custom Lua module (`lua/core/binding_updater.lua`) that automatically detects keybinding changes using `git diff` and updates `binding_list.csv` accordingly.

### STRICT EXECUTION PROTOCOL for Claude Code:

**YOU MUST FOLLOW THIS WORKFLOW EVERY SINGLE TIME:**

1. After adding, modifying, or removing ANY keybinding in ANY `.lua` file
2. IMMEDIATELY execute this Bash command (no exceptions):
   ```bash
   nvim --headless -c "UpdateBindings" -c "qa" 2>&1 | grep -A 20 "Analyzing git diff"
   ```
3. Verify the output shows the binding was detected and added/updated
4. NEVER skip this step, even for a single keybinding change

### What triggers automatic execution:
- ✅ Adding new `vim.keymap.set()` or `keymap()` calls
- ✅ Modifying existing keybindings (changing key, mode, or description)
- ✅ Removing keybindings
- ✅ ANY change to files containing `vim.keymap.set()` or `keymap()`

### How it works:
1. Running `git diff` to detect modified `.lua` files
2. Parsing added/modified lines containing `vim.keymap.set()` or `keymap()` calls
3. Extracting binding information (key, mode, description, source file)
4. Automatically updating or adding entries to `binding_list.csv`

### Example of CORRECT workflow:
```
1. You edit lua/plugins/foo.lua and add: keymap("n", "<leader>x", ":Foo<CR>", { desc = "Run Foo" })
2. YOU IMMEDIATELY run: nvim --headless -c "UpdateBindings" -c "qa" 2>&1 | grep -A 20 "Analyzing git diff"
3. You verify output: "Found 1 new/modified keybinding(s)" and "Successfully updated binding_list.csv"
4. You inform the user that the binding_list.csv has been updated
```

### Manual usage (for the user):
- **From Neovim**: Type `:UpdateBindings` or press `<leader>bu`
- **From CLI**: `nvim --headless -c "UpdateBindings" -c "qa"`

**CRITICAL**: This system only detects changes in uncommitted modifications (git diff). The CSV is updated BEFORE committing, so git diff can detect the changes.

**DO NOT** manually edit `binding_list.csv` - always use the automated system to ensure consistency and completeness.
