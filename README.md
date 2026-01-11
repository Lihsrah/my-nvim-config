# Neovim Configuration

My personal Neovim configuration with LSP, autocompletion, and modern plugins.

## Features

- 🎨 **Catppuccin Mocha** colorscheme with transparent background
- 🔧 **LSP Support** for TypeScript, JavaScript, C/C++, Java, PHP, HTML, CSS
- ✨ **Autocompletion** with nvim-cmp and LuaSnip
- 📁 **Oil.nvim** file explorer
- 🔭 **Telescope** fuzzy finder
- 🎯 **Harpoon** for quick file navigation
- 📝 **Markdown** support with preview and tables
- 🚀 **Flash.nvim** for enhanced motion
- 🎨 **Conform.nvim** for code formatting
- 🔍 **Trouble.nvim** for diagnostics
- 💡 **LSP Saga** for enhanced LSP features

## Installation

### Prerequisites

- Neovim >= 0.9.0
- Git
- A Nerd Font (for icons)
- ripgrep (for Telescope live_grep)
- Node.js (for LSP servers)

### Install

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this config
git clone https://github.com/YOUR_USERNAME/nvim-config.git ~/.config/nvim

# Open Neovim - plugins will auto-install
nvim
```

## Keybindings

**Leader Key:** `<Space>`

### General

| Shortcut | Mode | Description |
|----------|------|-------------|
| `jk` | Insert | Exit insert mode |
| `<Esc>` | Normal | Clear search highlighting |

### Window Management

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>sv` | Normal | Split window vertically |
| `<leader>sh` | Normal | Split window horizontally |
| `<leader>sx` | Normal | Close current split |
| `<leader>se` | Normal | Make splits equal size |
| `<C-h>` | Normal | Move to left window |
| `<C-l>` | Normal | Move to right window |
| `<C-j>` | Normal | Move to window below |
| `<C-k>` | Normal | Move to window above |

### Tab Management

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>to` | Normal | Open new tab |
| `<leader>tn` | Normal | Next tab |
| `<leader>tp` | Normal | Previous tab |
| `<leader>tx` | Normal | Close tab |

### Scrolling & Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<C-u>` | Normal/Visual | Scroll down half page (centered) |
| `<C-i>` | Normal/Visual | Scroll up half page (centered) |
| `<C-p>` | Normal | Jump forward in jumplist |
| `<C-o>` | Normal | Jump back in jumplist |

### Line Movement

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<A-j>` | Normal | Move line down |
| `<A-k>` | Normal | Move line up |
| `<A-j>` | Visual | Move selection down |
| `<A-k>` | Visual | Move selection up |
| `<A-j>` | Insert | Move line down |
| `<A-k>` | Insert | Move line up |

### File Explorer (Oil.nvim)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ee` | Normal | Open file explorer |
| `<CR>` | Oil | Open file/directory |
| `<C-s>` | Oil | Open in vertical split |
| `<C-h>` | Oil | Open in horizontal split |
| `<C-t>` | Oil | Open in new tab |
| `-` | Oil | Go to parent directory |
| `g.` | Oil | Toggle hidden files |

### Telescope (Fuzzy Finder)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Live grep (search in files) |
| `<leader>fb` | Normal | Find buffers |
| `<leader>fh` | Normal | Help tags |
| `<leader>fr` | Normal | Recent files |
| `<leader>fc` | Normal | Commands |
| `<leader>fd` | Normal | Document symbols |
| `<leader>ft` | Normal | Color schemes with preview |

### LSP (Language Server Protocol)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `gd` | Normal | Go to definition |
| `gp` | Normal | Peek definition |
| `K` | Normal | Show hover documentation |
| `<leader>ca` | Normal | Code actions |
| `<leader>rn` | Normal | Rename symbol |
| `gr` | Normal | Find references |
| `<leader>o` | Normal | Toggle outline |

### Diagnostics (Trouble.nvim)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>xx` | Normal | Toggle diagnostics (workspace) |
| `<leader>xX` | Normal | Toggle diagnostics (buffer) |
| `<leader>cs` | Normal | Toggle symbols |
| `<leader>cl` | Normal | Toggle LSP definitions/references |

### Harpoon (Quick File Navigation)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ma` | Normal | Add file to harpoon |
| `<leader>mm` | Normal | Toggle harpoon menu |
| `<leader>m1` | Normal | Jump to harpoon file 1 |
| `<leader>m2` | Normal | Jump to harpoon file 2 |
| `<leader>m3` | Normal | Jump to harpoon file 3 |
| `<leader>m4` | Normal | Jump to harpoon file 4 |
| `<leader>m5` | Normal | Jump to harpoon file 5 |
| `<leader>m6` | Normal | Jump to harpoon file 6 |
| `<leader>m7` | Normal | Jump to harpoon file 7 |
| `<leader>m8` | Normal | Jump to harpoon file 8 |
| `<leader>m9` | Normal | Jump to harpoon file 9 |

### Flash.nvim (Enhanced Motion)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `zk` | Normal/Visual/Operator | Flash jump |

### Mini.surround

| Shortcut | Mode | Description |
|----------|------|-------------|
| `sa` | Normal/Visual | Add surrounding |
| `sd` | Normal | Delete surrounding |
| `sr` | Normal | Replace surrounding |
| `sf` | Normal | Find surrounding (right) |
| `sF` | Normal | Find surrounding (left) |
| `sh` | Normal | Highlight surrounding |

### Formatting

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>fm` | Normal/Visual | Format file or range |

### Markdown (only in .md files)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>mp` | Normal | Start markdown preview |
| `<leader>ms` | Normal | Stop markdown preview |
| `<leader>mt` | Normal | Toggle markdown preview |
| `<leader>tm` | Normal | Toggle table mode |
| `<leader>toc` | Normal | Generate table of contents |

### Autocompletion (nvim-cmp)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<C-Space>` | Insert | Trigger completion |
| `<C-j>` | Insert | Next completion item |
| `<C-k>` | Insert | Previous completion item |
| `<CR>` | Insert | Confirm selection |
| `<C-e>` | Insert | Abort completion |
| `<Tab>` | Insert | Expand snippet / Jump forward |
| `<S-Tab>` | Insert | Jump backward in snippet |
| `<C-b>` | Insert | Scroll docs up |
| `<C-f>` | Insert | Scroll docs down |

## Plugins

### Plugin Manager
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Modern plugin manager

### Appearance
- [catppuccin](https://github.com/catppuccin/nvim) - Mocha colorscheme with transparent background
- [smear-cursor](https://github.com/sphamba/smear-cursor.nvim) - Smooth cursor animations
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) - File icons

### File Navigation
- [oil.nvim](https://github.com/stevearc/oil.nvim) - File explorer as a buffer
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [harpoon](https://github.com/ThePrimeagen/harpoon) - Quick file marks

### LSP & Completion
- [mason.nvim](https://github.com/williamboman/mason.nvim) - LSP installer
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configurations
- [lspsaga.nvim](https://github.com/nvimdev/lspsaga.nvim) - Enhanced LSP UI
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) - Autocompletion
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip) - Snippet engine
- [trouble.nvim](https://github.com/folke/trouble.nvim) - Diagnostics list

### Code Editing
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs) - Auto close brackets
- [conform.nvim](https://github.com/stevearc/conform.nvim) - Code formatting
- [mini.surround](https://github.com/echasnovski/mini.surround) - Surround text objects
- [flash.nvim](https://github.com/folke/flash.nvim) - Enhanced motion

### Markdown
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/markdown.nvim) - Modern markdown rendering
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) - Live preview in browser
- [vim-markdown-toc](https://github.com/mzlogin/vim-markdown-toc) - Table of contents generator
- [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode) - Easy markdown tables

## LSP Servers

Configured language servers:
- **TypeScript/JavaScript** - ts_ls
- **C/C++** - clangd
- **Java** - jdtls
- **PHP** - intelephense
- **HTML** - html
- **CSS** - cssls

## Formatters

Auto-formatting on save enabled for:
- JavaScript/TypeScript - prettier
- HTML/CSS - prettier
- JSON/YAML/Markdown - prettier
- Lua - stylua
- Python - black
- Java - google-java-format
- C/C++ - clang-format
- PHP - php-cs-fixer

## Customization

Edit `~/.config/nvim/init.lua` to customize:
- Change colorscheme flavor (line 25)
- Modify LSP servers (line 213)
- Add/remove plugins
- Customize keybindings

After making changes, restart Neovim or run:
```vim
:source ~/.config/nvim/init.lua
```

## Tips

- Use `<leader>ff` to quickly find files
- Mark frequently used files with `<leader>ma` and jump with `<leader>m1-9`
- Press `K` over any symbol to see documentation
- Use `<leader>ca` for quick code actions
- Flash jump with `zk` for fast navigation
- Format on save is enabled by default

## License

Feel free to use and modify as needed!
