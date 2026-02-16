# Neovim Configuration

My personal Neovim configuration with LSP, autocompletion, and modern plugins.

## Features

- **Catppuccin Mocha** colorscheme with transparent background
- **LSP Support** for TypeScript, JavaScript, C/C++, Java, PHP, HTML, CSS
- **Autocompletion** with nvim-cmp and LuaSnip
- **Oil.nvim** file explorer
- **Telescope** fuzzy finder
- **Harpoon** for quick file/terminal navigation (terminal-aware)
- **Neogit** git interface (Magit-style, with diffview)
- **Markdown** support with preview and tables
- **Flash.nvim** for enhanced motion
- **Conform.nvim** for code formatting (folds preserved on save)
- **Trouble.nvim** for diagnostics
- **LSP Saga** for enhanced LSP features
- **Mini.ai** for enhanced text objects (functions, arguments, etc.)
- **Mini.surround** for surrounding text manipulation
- **nvim-ufo** for VSCode-like code folding

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
| `jk` | Terminal | Exit terminal mode (not in lazygit) |
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

### Block Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `%` | Normal | Jump to matching bracket `()`, `[]`, `{}` |
| `[{` | Normal | Jump to opening `{` of current block |
| `]}` | Normal | Jump to closing `}` of current block |
| `[(` | Normal | Jump to opening `(` of current block |
| `])` | Normal | Jump to closing `)` of current block |

### Line Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `0` | Normal | Go to beginning of line |
| `^` | Normal | Go to first non-blank character |
| `$` | Normal | Go to end of line |
| `g_` | Normal | Go to last non-blank character |

### Word Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `w` | Normal | Move to start of next word |
| `W` | Normal | Move to start of next WORD (whitespace-separated) |
| `b` | Normal | Move to start of previous word |
| `B` | Normal | Move to start of previous WORD |
| `e` | Normal | Move to end of next word |
| `E` | Normal | Move to end of next WORD |
| `ge` | Normal | Move to end of previous word |

### File Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `gg` | Normal | Go to first line of file |
| `G` | Normal | Go to last line of file |
| `{n}G` | Normal | Go to line number n (e.g., `50G`) |
| `:{n}` | Normal | Go to line number n (e.g., `:50`) |
| `{` | Normal | Jump to previous empty line |
| `}` | Normal | Jump to next empty line |
| `H` | Normal | Move cursor to top of screen |
| `M` | Normal | Move cursor to middle of screen |
| `L` | Normal | Move cursor to bottom of screen |

### Folding (Collapse/Expand Code Blocks)

Uses **nvim-ufo** with Treesitter (JS/TS) and LSP (other languages) for VSCode-like folding.

**Fold display:** `function foo() { ···` with closing `}` visible on the next line.

**How it works:**
- Press `za` anywhere inside a block — it finds and collapses the innermost enclosing `{}`
- JS/TS object methods (e.g. `reset: function () {}`) are fully foldable
- Folds are preserved when saving (format-on-save does not reopen them)

**Example:**
```javascript
function foo() {     // <- za anywhere inside closes this
    if (condition) { // <- za anywhere inside closes this
        doStuff();
    }
}
```

| Shortcut | Mode | Description |
|----------|------|-------------|
| `za` | Normal | Smart fold toggle — collapses innermost block cursor is inside |
| `zR` | Normal | Open all folds in file |
| `zM` | Normal | Close all folds in file |
| `zr` | Normal | Open folds except certain kinds |
| `zm` | Normal | Close folds by level |
| `zK` | Normal | Peek folded lines without opening |

### Terminal

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>tt` | Normal | Open terminal in current window |
| `<leader>tv` | Normal | Open terminal in vertical split |
| `<leader>th` | Normal | Open terminal in horizontal split |
| `jk` | Terminal | Exit terminal mode (normal terminals only) |

### Git (Neogit)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>lg` | Normal | Open Neogit |

#### Neogit Cheatsheet

Neogit opens as a buffer (Magit-style). Press `q` to close.

**Navigation**

| Key | Description |
|-----|-------------|
| `<Tab>` | Expand / collapse section |
| `j` / `k` | Move down / up |
| `<Enter>` | Open file / go to commit |
| `?` | Open keybindings help |

**Staging & Committing**

| Key | Description |
|-----|-------------|
| `s` | Stage file or hunk |
| `S` | Stage all unstaged files |
| `u` | Unstage file or hunk |
| `U` | Unstage all staged files |
| `x` | Discard change |
| `c` | Open commit popup |
| `cc` | Commit |
| `ca` | Amend last commit |
| `ce` | Extend last commit (no edit) |

**Diff**

| Key | Description |
|-----|-------------|
| `d` | Open diffview for file |
| `<Enter>` | Inline diff expand |

**Branches**

| Key | Description |
|-----|-------------|
| `b` | Open branch popup |
| `bb` | Checkout branch |
| `bc` | Create branch |
| `bm` | Rename branch |
| `bd` | Delete branch |

**Push / Pull / Fetch**

| Key | Description |
|-----|-------------|
| `p` | Open pull popup |
| `pp` | Pull |
| `P` | Open push popup |
| `PP` | Push |
| `f` | Open fetch popup |
| `ff` | Fetch |

**Stash**

| Key | Description |
|-----|-------------|
| `Z` | Open stash popup |
| `Zz` | Stash |
| `Zp` | Pop stash |

**Log**

| Key | Description |
|-----|-------------|
| `l` | Open log popup |
| `ll` | Log current branch |
| `la` | Log all branches |

**Rebase**

| Key | Description |
|-----|-------------|
| `r` | Open rebase popup |
| `ri` | Interactive rebase |
| `rr` | Continue rebase |
| `ra` | Abort rebase |

### Line Movement

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<A-j>` | Normal/Visual/Insert | Move line/selection down |
| `<A-k>` | Normal/Visual/Insert | Move line/selection up |

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

### Harpoon (Quick File/Terminal Navigation)

Harpoon is terminal-aware — if you mark a terminal buffer, navigating back to it jumps to the live terminal process (or opens a new one if the process has exited).

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>ma` | Normal | Add current file/terminal to harpoon |
| `<leader>mm` | Normal | Toggle harpoon menu |
| `<leader>m1`–`m9` | Normal | Jump to harpoon slot 1–9 |

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

### Mini.ai (Enhanced Text Objects)

Mini.ai enhances Neovim's built-in text objects (`a` = "around", `i` = "inside").

**Usage:** Combine operators (`d`, `c`, `v`, `y`) with `a`/`i` and a text object.

**Available text objects:**
- `(`, `)`, `b` - Parentheses
- `[`, `]` - Square brackets
- `{`, `}`, `B` - Curly braces
- `<`, `>` - Angle brackets
- `'`, `"`, `` ` `` - Quotes
- `t` - HTML/XML tags
- `f` - Function call
- `a` - Function argument
- `q` - Quote (any type)
- `b` - Bracket (any type)

**Examples:**
- `dif` - Delete inside function
- `cia` - Change inside argument
- `viq` - Visually select inside any quote
- `dab` - Delete around any bracket

### Delete / Cut

By default `d`, `c`, `s`, `x` do **not** yank to clipboard (black hole register). Use `<leader>d` variants to cut (yank + delete).

| Shortcut | Mode | Description |
|----------|------|-------------|
| `d` / `dd` / `D` | Normal | Delete without yanking |
| `<leader>d` / `<leader>dd` / `<leader>D` | Normal | Cut (delete + yank) |
| `c` / `cc` / `C` | Normal | Change without yanking |
| `x` | Normal | Delete char without yanking |

### Formatting

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>fm` | Normal/Visual | Format file or range |

Format on save is enabled by default. Folds are preserved across saves.

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
| `<Tab>` | Insert | Expand snippet / jump forward |
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
- [harpoon](https://github.com/ThePrimeagen/harpoon) - Quick file/terminal marks

### Git
- [neogit](https://github.com/NeogitOrg/neogit) - Magit-style git interface
- [diffview.nvim](https://github.com/sindrets/diffview.nvim) - Diff viewer (neogit integration)

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
- [mini.ai](https://github.com/echasnovski/mini.ai) - Enhanced text objects
- [flash.nvim](https://github.com/folke/flash.nvim) - Enhanced motion
- [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) - VSCode-like code folding

### Markdown
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/markdown.nvim) - Modern markdown rendering
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) - Live preview in browser
- [vim-markdown-toc](https://github.com/mzlogin/vim-markdown-toc) - Table of contents generator
- [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode) - Easy markdown tables

## LSP Servers

- **TypeScript/JavaScript** - ts_ls
- **C/C++** - clangd
- **Java** - jdtls
- **PHP** - intelephense
- **HTML** - html
- **CSS** - cssls

## Formatters

Auto-formatting on save (folds preserved):
- JavaScript/TypeScript/JSX/TSX - prettier
- HTML/CSS - prettier
- JSON/YAML/Markdown - prettier
- Lua - stylua
- Python - black
- Java - google-java-format
- C/C++ - clang-format
- PHP - php-cs-fixer

## Tips

- Use `<leader>ff` to quickly find files
- Mark frequently used files **and terminals** with `<leader>ma`, jump with `<leader>m1`–`9`
- Press `K` over any symbol to see documentation
- Use `<leader>ca` for quick code actions
- Flash jump with `zk` for fast navigation
- Format on save is enabled by default — folds stay closed
- Open Neogit with `<leader>lg`, use `s` to stage, `cc` to commit, `PP` to push
- Press `?` inside Neogit to see all available keybindings

## License

Feel free to use and modify as needed!
