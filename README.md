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
- **Octo.nvim** GitHub integration (PRs, issues, reviews — no browser needed)
- **kubectl.nvim** interactive Kubernetes cluster manager
- **gcp.nvim** (local module) — GCP Artifact Registry image/vuln browser + Secret Manager
- **Markdown** support with preview and tables
- **Flash.nvim** for enhanced motion
- **Conform.nvim** for code formatting (folds preserved on save)
- **Trouble.nvim** for diagnostics
- **LSP Saga** for enhanced LSP features
- **Mini.ai** for enhanced text objects (functions, arguments, etc.)
- **Mini.surround** for surrounding text manipulation
- **nvim-ufo** for VSCode-like code folding
- **Bufferline** for visual buffer tabs (like Notepad/browser tabs)
- **Persistence** for session save/restore across restarts
- **Notes system** — quick access to todo, brainstorm, and dated scratch notes

## Installation

### Prerequisites

- Neovim >= 0.9.0
- Git
- A Nerd Font (for icons)
- ripgrep (for Telescope live_grep)
- Node.js (for LSP servers)
- [gh CLI](https://cli.github.com/) (for Octo.nvim GitHub integration) — `brew install gh && gh auth login`

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
| `jk` | Terminal | Exit terminal mode |
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

### Buffer Tabs (Bufferline)

Buffers are shown as visual tabs at the top of the screen.

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>to` | Normal | Open new empty buffer tab |
| `<leader>tn` | Normal | Next buffer tab |
| `<leader>tp` | Normal | Previous buffer tab |
| `<leader>tx` | Normal | Close current buffer tab |
| `<S-l>` | Normal | Next buffer tab |
| `<S-h>` | Normal | Previous buffer tab |
| `<S-x>` | Normal | Close buffer |

### Notes

Quick access to persistent notes. All files live in `~/notes/`.

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>nt` | Normal | Open `todo.md` |
| `<leader>nb` | Normal | Open `brainstorm.md` |
| `<leader>nn` | Normal | New dated scratch note (e.g. `scratch-20260304-143012.md`) |
| `<leader>nf` | Normal | Fuzzy find inside `~/notes/` |
| `<leader>ng` | Normal | Grep inside `~/notes/` |

### Session (Persistence)

Sessions are auto-saved per directory on exit and can be restored.

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>qs` | Normal | Restore session for current directory |
| `<leader>ql` | Normal | Restore last session |
| `<leader>qd` | Normal | Don't save session on exit |

### Scrolling & Navigation

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<C-d>` | Normal | Scroll down half page |
| `<C-u>` | Normal | Scroll up half page |
| `<C-f>` | Normal | Scroll down full page |
| `<C-b>` | Normal | Scroll up full page |
| `<C-o>` | Normal | Jump back in jumplist |
| `<C-i>` | Normal | Jump forward in jumplist |

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
| `<leader>tt` | Normal | Open terminal in current window (Neovim cwd) |
| `<leader>tv` | Normal | Open terminal in vertical split (Neovim cwd) |
| `<leader>th` | Normal | Open terminal in horizontal split (Neovim cwd) |
| `<leader>tct` | Normal | Open terminal in current window (current file's dir) |
| `<leader>tcv` | Normal | Open terminal in vertical split (current file's dir) |
| `<leader>tch` | Normal | Open terminal in horizontal split (current file's dir) |
| `jk` | Terminal | Exit terminal mode (normal terminals only) |

### Git (Neogit)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>lg` | Normal | Open Neogit (in current working directory's git repo) |
| `<leader>lG` | Normal | Open Neogit (in current file's directory) |

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
| `ff` | Fetch current remote |
| `fa` | Fetch all remotes (full sync with repo) |

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

### Git Hunks (Gitsigns)

Stage, reset, and navigate individual changed hunks inline without leaving the buffer.

| Shortcut | Mode | Description |
|----------|------|-------------|
| `]h` | Normal | Jump to next hunk |
| `[h` | Normal | Jump to previous hunk |
| `<leader>hs` | Normal/Visual | Stage hunk (or selected range) |
| `<leader>hr` | Normal/Visual | Reset hunk (or selected range) |
| `<leader>hp` | Normal | Preview hunk |
| `<leader>hd` | Normal | Diff current file |
| `<leader>hb` | Normal | Blame current line (full) |
| `<leader>hB` | Normal | Toggle inline line blame |

### Diffview (Side-by-side diffs & file history)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>dv` | Normal | Diff working tree vs HEAD |
| `<leader>db` | Normal | Diff vs a branch (prompts for branch name) |
| `<leader>dh` | Normal | File history for current file |
| `<leader>dH` | Normal | File history for whole repo |
| `<leader>dc` | Normal | Close diffview |
| `<leader>dt` | Normal | Toggle diff between open split windows |

**Inside diffview:**

| Key | Description |
|-----|-------------|
| `]c` / `[c` | Next / prev change |
| `<Tab>` / `<S-Tab>` | Next / prev file in file panel |
| `q` | Close |

### GitHub (Octo.nvim)

Requires `gh` CLI authenticated (`gh auth login`). Open a PR/issue first with the list commands, then use the action shortcuts.

**Pull Requests (`<leader>gp`)**

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>gpc` | Normal | Create PR |
| `<leader>gpl` | Normal | List PRs |
| `<leader>gpm` | Normal | Merge PR |
| `<leader>gpC` | Normal | Checkout PR branch locally |
| `<leader>gpk` | Normal | PR checks / CI status |
| `<leader>gpr` | Normal | Mark PR as ready (convert from draft) |
| `<leader>gpx` | Normal | Close PR |
| `<leader>gpb` | Normal | Open PR in browser |

**Issues (`<leader>gi`)**

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>gic` | Normal | Create issue |
| `<leader>gil` | Normal | List issues |
| `<leader>gix` | Normal | Close issue |

**Reviews (`<leader>gr`)**

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>grs` | Normal | Start review |
| `<leader>grr` | Normal | Resume existing pending review |
| `<leader>grS` | Normal | Submit review (approve / request changes / comment) |
| `<leader>grD` | Normal | Discard review |

**Misc**

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>gco` | Normal | Add comment |
| `<leader>gra` | Normal | Add reviewer |
| `<leader>gla` | Normal | Add label |

**Workflow: view a PR, check approval, then merge**

1. **View / open a PR** — press `<leader>gpl` to list PRs, then `<CR>` on one to open it (or run `:Octo pr edit <number>` directly). The PR buffer opens showing the title, description, reviews, and status at the top.
2. **Check if it's approved** — look at the **Reviewers** section in the PR buffer header: each reviewer shows `APPROVED`, `CHANGES_REQUESTED`, or `PENDING`. The PR is mergeable once it shows `APPROVED` with no outstanding change requests.
3. **Check CI status** — press `<leader>gpk` to see PR checks / CI. Make sure required checks are green before merging.
4. **Merge it** — once approved and checks pass, press `<leader>gpm` to merge the PR (you'll be prompted for the merge method: merge / squash / rebase).

> Prefer the browser? `<leader>gpb` opens the current PR on GitHub, where the approval badge and merge button are also visible.

### Kubernetes (kubectl.nvim)

Interactive cluster manager. Uses your current `~/.kube/config` context. Ships a pre-built Rust backend binary (downloaded automatically on first load — **no `cargo`/Rust toolchain required**).

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>k` | Normal | Toggle the kubectl view |

**Inside the kubectl view:**

| Key | Description |
|-----|-------------|
| `1`–`6` | Jump to Deployments / Pods / ConfigMaps / Secrets / Services / Ingresses |
| `<CR>` | Select / drill into resource |
| `<BS>` | Go back to previous view |
| `gd` | Describe resource |
| `gl` | View logs |
| `gp` | Port forward |
| `gr` | Refresh view |
| `?` | Show all available keymaps for the current view |

**Commands:** `:Kubectl` (run/view, e.g. `:Kubectl get endpoints`), `:Kubens` (switch namespace), `:Kubectx` (switch context).

> Requires the `kubectl` CLI installed and a valid kubeconfig. The view always reflects your active context — switch it with `:Kubectx`.

### GCP — Artifact Registry & Secret Manager (gcp.nvim)

A small **local module** (`lua/gcp/`) that drives the `gcloud` CLI. Every action starts by letting you **switch GCP project**, so it works across projects without `gcloud config set`. Requires `gcloud` installed + authenticated. For image vulnerabilities, the project must have **Artifact Analysis / Container Scanning** enabled.

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>K` | Normal | Artifact Registry browser (`:Gar`) — pick project → repo → images |
| `<leader>G` | Normal | Secret Manager browser (`:Gsm`) — pick project → secrets → versions |

**Artifact Registry flow:** pick a project → pick a Docker repo → pick a **package** (image name) → image table. This follows Artifact Registry's real hierarchy (`repo → package → versions`), so you scope to one image instead of every image in the repo. (If a repo has only one package, the picker is skipped.) The table shows the full **tag(s)** (column sizes to fit — no truncation), short digest, created time, and a **vulnerability column** that fills in lazily (`C:`/`H:`/`M:`/`L:` counts, `clean`, or `—` if unscanned). Sorted by version tag by default.

To stay fast, it fetches the **newest N images** (default 50) for the package rather than everything, and the header shows `showing N (newest first) · more available`. Use `]` / `[` to load more / fewer. Tune the default with `require("gcp").setup({ image_limit = 50, page_size = 50 })`.

| Key (image table) | Description |
|-----|-------------|
| `<CR>` | Show the image's CVEs (severity, CVE id, package, affected → fixed, CVSS) |
| `st` / `sc` / `sv` | Sort by version / created / vulnerability severity |
| `]` / `[` | Load more / fewer images (raise/lower the fetch limit) |
| `gk` / `gr` / `gp` | Back to packages / repos / projects |
| `r` | Refresh |
| `y` | Yank the full `image@sha256:…` ref |
| `q` | Close |

**Secret Manager flow:** pick a project → secret table → `<CR>` for versions → `<CR>` to reveal a value.

| Key (secrets / versions) | Description |
|-----|-------------|
| `<CR>` | Secrets: open versions · Versions: reveal value |
| `a` | Add a **new secret** (prompts for name, then a compose buffer for the value) |
| `u` | Add a **new version** to the secret under cursor (update its value) |
| `r` / `gp` | Refresh · switch project |
| `b` | (versions view) back to secrets · `q` close |

When adding/updating, a scratch **compose buffer** opens — type the value (multi-line ok) and submit with `<C-s>` or `:w` (`q` cancels). Revealed secret values open in an **in-memory buffer** (no swap, wiped on close); press `y` to copy to clipboard.

> Commands: `:Gar`, `:Gsm`, `:GarRepos`. Requires the `gcloud` CLI authenticated (`gcloud auth login`). Secret values are sensitive — they are never written to disk by this module, but `y` copies to your system clipboard.

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
| `<BS>` | Oil | Close Oil (return to previous file) |
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

### Spectre (Search & Replace)

Project-wide search and replace with regex support.

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<leader>S` | Normal | Toggle Spectre panel |
| `<leader>sw` | Normal | Search word under cursor |
| `<leader>sw` | Visual | Search selected text |
| `<leader>sf` | Normal | Search & replace in current file only |

**Inside Spectre:** `<CR>` confirm replace · `dd` exclude match · `R` replace all

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

### Multiple Cursors (vim-visual-multi)

| Shortcut | Mode | Description |
|----------|------|-------------|
| `<C-n>` | Normal | Select word under cursor / add next occurrence |
| `<C-n>` | Visual | Select all occurrences of selection |
| `<C-Up>` / `<C-Down>` | Normal | Add cursor above / below |
| `n` / `N` | VM | Next / previous match |
| `q` | VM | Skip current and go to next |
| `Q` | VM | Remove current cursor |
| `<Esc>` | VM | Exit multi-cursor mode |

**Tip:** `<C-n>` then `A` selects all occurrences at once. Then type to replace them all.

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
- [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) - Visual buffer tab bar
- [smear-cursor](https://github.com/sphamba/smear-cursor.nvim) - Smooth cursor animations
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) - File icons

### Productivity
- [persistence.nvim](https://github.com/folke/persistence.nvim) - Session save/restore

### File Navigation
- [oil.nvim](https://github.com/stevearc/oil.nvim) - File explorer as a buffer
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [harpoon](https://github.com/ThePrimeagen/harpoon) - Quick file/terminal marks

### Git
- [neogit](https://github.com/NeogitOrg/neogit) - Magit-style git interface
- [diffview.nvim](https://github.com/sindrets/diffview.nvim) - Diff viewer (neogit integration)
- [octo.nvim](https://github.com/pwntester/octo.nvim) - GitHub PRs, issues, and reviews inside Neovim

### LSP & Completion
- [mason.nvim](https://github.com/williamboman/mason.nvim) - LSP installer
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configurations
- [lspsaga.nvim](https://github.com/nvimdev/lspsaga.nvim) - Enhanced LSP UI
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) - Autocompletion
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip) - Snippet engine
- [trouble.nvim](https://github.com/folke/trouble.nvim) - Diagnostics list

### Search & Replace
- [nvim-spectre](https://github.com/nvim-pack/nvim-spectre) - Project-wide search and replace

### Code Editing
- [vim-visual-multi](https://github.com/mg979/vim-visual-multi) - Multiple cursors
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
- Use `<leader>nn` to open a fresh dated scratch note anytime — persists across restarts
- Restore your last session with `<leader>ql` when you reopen Neovim
- Format on save is enabled by default — folds stay closed
- Open Neogit with `<leader>lg`, use `s` to stage, `cc` to commit, `PP` to push
- Press `?` inside Neogit to see all available keybindings

## License

Feel free to use and modify as needed!
