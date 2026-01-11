-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim plugins
require("lazy").setup({
  -- Catppuccin colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = true,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Oil.nvim file explorer
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        win_options = {
          wrap = false,
          signcolumn = "no",
          cursorcolumn = false,
          foldcolumn = "0",
          spell = false,
          list = false,
          conceallevel = 3,
          concealcursor = "nvic",
        },
        delete_to_trash = false,
        skip_confirm_for_simple_edits = false,
        prompt_save_on_select_new_entry = true,
        cleanup_delay_ms = 2000,
        lsp_file_methods = {
          timeout_ms = 1000,
          autosave_changes = false,
        },
        constrain_cursor = "editable",
        watch_for_changes = false,
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
        },
        use_default_keymaps = true,
        view_options = {
          show_hidden = true,
          is_hidden_file = function(name, bufnr)
            return vim.startswith(name, ".")
          end,
          is_always_hidden = function(name, bufnr)
            return false
          end,
          sort = {
            { "type", "asc" },
            { "name", "asc" },
          },
        },
        float = {
          padding = 2,
          max_width = 0,
          max_height = 0,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
          override = function(conf)
            return conf
          end,
        },
        preview = {
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = 0.9,
          min_height = { 5, 0.1 },
          height = nil,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
        },
        progress = {
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = { 10, 0.9 },
          min_height = { 5, 0.1 },
          height = nil,
          border = "rounded",
          minimized_border = "none",
          win_options = {
            winblend = 0,
          },
        },
      })
    end,
  },

  -- Mason LSP installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",          -- TypeScript/JavaScript
          "clangd",         -- C/C++
          "jdtls",          -- Java
          "intelephense",   -- PHP
          "html",           -- HTML
          "cssls",          -- CSS
        },
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Disable commit characters to prevent auto-completion on typing
      capabilities.textDocument.completion.completionItem.commitCharactersSupport = false

      -- JavaScript/TypeScript
      vim.lsp.config.ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
        capabilities = capabilities,
        settings = {
          completions = {
            completeFunctionCalls = false,
          },
        },
      }

      -- C/C++
      vim.lsp.config.clangd = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", "Makefile" },
        capabilities = capabilities,
      }

      -- Java
      vim.lsp.config.jdtls = {
        cmd = { "jdtls" },
        filetypes = { "java" },
        root_markers = { "pom.xml", "build.gradle", ".git" },
        capabilities = capabilities,
      }

      -- PHP
      vim.lsp.config.intelephense = {
        cmd = { "intelephense", "--stdio" },
        filetypes = { "php" },
        root_markers = { "composer.json", ".git" },
        capabilities = capabilities,
      }

      -- HTML
      vim.lsp.config.html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      }

      -- CSS
      vim.lsp.config.cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      }

      -- Enable LSP servers
      vim.lsp.enable({ "ts_ls", "clangd", "jdtls", "intelephense", "html", "cssls" })

      -- LSP keybindings (replaced with LSP Saga enhanced versions)
      vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Go to definition" })
      vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition" })
      vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Show hover info" })
      vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code actions" })
      vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Rename symbol" })
      vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", { desc = "Find references" })
      vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { desc = "Toggle outline" })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Load snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = "menu,menuone,noselect", -- Show menu, don't auto-select
        },
        confirmation = {
          get_commit_characters = function(commit_characters)
            return {} -- Disable all commit characters
          end
        },
        preselect = cmp.PreselectMode.None, -- Don't preselect any items
        experimental = {
          ghost_text = false, -- Disable ghost text
        },
        view = {
          entries = {
            name = "custom",
            selection_order = "top_down",
            follow_cursor = false, -- Don't follow cursor movement
          },
        },
        window = {
          completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            col_offset = -3,
            side_padding = 0,
          },
        },
        mapping = {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if cmp.get_selected_entry() then
                cmp.confirm({ select = false })
              else
                cmp.abort()
                fallback()
              end
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources({
          {
            name = "nvim_lsp",
            keyword_length = 2,
          },
          {
            name = "luasnip",
            keyword_length = 2,
          },
        }, {
          {
            name = "buffer",
            keyword_length = 3,
          },
          {
            name = "path",
            keyword_length = 3,
          },
        }),
      })
    end,
  },

  -- Trouble.nvim for better diagnostics and LSP navigation
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        modes = {
          preview_float = {
            mode = "diagnostics",
            preview = {
              type = "float",
              relative = "editor",
              border = "rounded",
              title = "Preview",
              title_pos = "center",
              position = { 0, -2 },
              size = { width = 0.3, height = 0.3 },
              zindex = 200,
            },
          },
        },
      })
    end,
  },

  -- LSP Saga for enhanced LSP features
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        -- Force line numbers in all LSP Saga windows
        winbar = {
          enable = false,
        },
        preview = {
          lines_above = 0,
          lines_below = 10,
        },
        scroll_preview = {
          scroll_down = "<C-j>",
          scroll_up = "<C-k>",
        },
        request_timeout = 2000,
        finder = {
          edit = { "o", "<CR>" },
          vsplit = "s",
          split = "i",
          tabe = "t",
          quit = { "q", "<ESC>" },
        },
        definition = {
          width = 0.6,
          height = 0.5,
          keys = {
            edit = { "o", "<CR>", "go" },
            vsplit = "v",
            split = "s",
            tabe = "t",
            quit = "q",
          },
        },
        code_action = {
          num_shortcut = true,
          show_server_name = false,
          extend_gitsigns = true,
          keys = {
            quit = "q",
            exec = "<CR>",
          },
        },
        lightbulb = {
          enable = true,
          enable_in_insert = true,
          sign = true,
          sign_priority = 40,
          virtual_text = true,
        },
        diagnostic = {
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
          keys = {
            exec_action = "o",
            quit = "q",
          },
        },
        rename = {
          quit = "<C-c>",
          exec = "<CR>",
          mark = "x",
          confirm = "<CR>",
          in_select = true,
        },
        outline = {
          win_position = "right",
          win_with = "",
          win_width = 30,
          show_detail = true,
          auto_preview = true,
          auto_refresh = true,
          auto_close = true,
          custom_sort = nil,
          keys = {
            jump = "o",
            expand_collapse = "u",
            quit = "q",
          },
        },
        callhierarchy = {
          show_detail = false,
          keys = {
            edit = "e",
            vsplit = "s",
            split = "i",
            tabe = "t",
            jump = "o",
            quit = "q",
            expand_collapse = "u",
          },
        },
        symbol_in_winbar = {
          enable = true,
          separator = " ",
          hide_keyword = true,
          show_file = true,
          folder_level = 2,
          respect_root = false,
          color_mode = true,
        },
        ui = {
          theme = "round",
          border = "none",
          winblend = 0,
          expand = "",
          collapse = "",
          preview = " ",
          code_action = "💡",
          diagnostic = "🐞",
          incoming = " ",
          outgoing = " ",
          hover = " ",
          kind = {},
        },
      })

      -- Force line numbers in LSP Saga windows immediately after setup
      vim.schedule(function()
        vim.api.nvim_create_autocmd("User", {
          pattern = "LspsagaReady",
          callback = function()
            vim.wo.number = true
            vim.wo.relativenumber = true
          end,
        })
      end)
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Telescope fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
      }
    },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➤ ",
          path_display = { "truncate" },
          file_ignore_patterns = {
            "node_modules/",
            ".git/",
            ".cache",
            "%.o",
            "%.a",
            "%.out",
            "%.class",
            "%.pdf",
            "%.mkv",
            "%.mp4",
            "%.zip"
          },
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          sorting_strategy = "ascending",
          winblend = 0,
          mappings = {
            i = {
              ["<leader>o"] = "select_tab",
              ["<C-t>"] = "select_tab",
            },
            n = {
              ["<leader>o"] = "select_tab",
              ["<C-t>"] = "select_tab",
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            previewer = false,
            hidden = true,
          },
          live_grep = {
            theme = "ivy",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
            initial_mode = "normal",
            mappings = {
              i = {
                ["<C-d>"] = "delete_buffer",
              },
              n = {
                ["dd"] = "delete_buffer",
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      -- Load extensions
      require("telescope").load_extension("fzf")
    end,
  },

  -- Auto pairs for brackets, quotes, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      local cmp = require("cmp")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")

      npairs.setup({
        check_ts = true, -- Enable treesitter integration
        ts_config = {
          lua = { "string", "source" },
          javascript = { "string", "template_string" },
          java = false, -- Don't add pairs in java
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%)%>%]%)%}%,]]=],
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
        },
      })

      -- Integration with nvim-cmp
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

    end,
  },

  -- Harpoon for quick file navigation
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup()
    end,
  },

  -- Conform.nvim for code formatting
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          lua = { "stylua" },
          python = { "black" },
          java = { "google-java-format" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          php = { "php-cs-fixer" },
        },
        format_on_save = {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>fm", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  },

  -- Markdown.nvim - Modern markdown rendering
  {
    "MeanderingProgrammer/markdown.nvim",
    name = "render-markdown",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup({
        enabled = true,
        max_file_size = 10.0,
        debounce = 100,
        render_modes = { "n", "c" },
        anti_conceal = {
          enabled = true,
        },
        heading = {
          enabled = true,
          sign = true,
          icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        },
        code = {
          enabled = true,
          sign = true,
          style = "full",
          position = "left",
          width = "full",
          left_pad = 0,
          right_pad = 0,
          min_width = 0,
          border = "thin",
          highlight = "RenderMarkdownCode",
        },
        bullet = {
          enabled = true,
          icons = { "●", "○", "◆", "◇" },
        },
        checkbox = {
          enabled = true,
          unchecked = {
            icon = "󰄱 ",
          },
          checked = {
            icon = "󰱒 ",
          },
        },
        quote = {
          enabled = true,
          icon = "▋",
        },
        pipe_table = {
          enabled = true,
          style = "full",
          cell = "padded",
        },
        callout = {
          note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
          tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
          important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
          warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
          caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
        },
        link = {
          enabled = true,
          image = "󰥶 ",
          hyperlink = "󰌹 ",
        },
        sign = {
          enabled = true,
        },
      })
    end,
  },

  -- Markdown Preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {}
      }
      vim.g.mkdp_markdown_css = ""
      vim.g.mkdp_highlight_css = ""
      vim.g.mkdp_port = ""
      vim.g.mkdp_page_title = "${name}"
      vim.g.mkdp_theme = "dark"
    end,
  },

  -- Markdown TOC generator
  {
    "mzlogin/vim-markdown-toc",
    ft = { "markdown" },
  },

  -- Markdown tables made easy
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    config = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
    end,
  },

  -- Flash.nvim for enhanced motion
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "zk",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
    },
  },

  -- Mini.surround for surrounding text objects
  {
    "echasnovski/mini.surround",
    version = "*",
    config = function()
      require("mini.surround").setup({
        mappings = {
          add = "sa",            -- Add surrounding in Normal and Visual modes
          delete = "sd",         -- Delete surrounding
          find = "sf",           -- Find surrounding (to the right)
          find_left = "sF",      -- Find surrounding (to the left)
          highlight = "sh",      -- Highlight surrounding
          replace = "sr",        -- Replace surrounding
          update_n_lines = "sn", -- Update `n_lines`
        },
      })
    end,
  },

  -- Smear cursor for smooth cursor animations
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      -- Cursor color. Defaults to Normal gui foreground color
      cursor_color = "#d9e0ee",

      -- Background color. Defaults to Normal gui background color
      normal_bg = "#1e1e2e",

      -- Smear cursor when switching buffers
      smear_between_buffers = true,

      -- Smear cursor when moving within line or to neighbor lines
      smear_between_neighbor_lines = true,

      -- Use floating windows to display smears outside buffers
      use_floating_windows = true,

      -- Set to `true` if your font supports legacy computing symbols (block unicode symbols)
      legacy_computing_symbols_support = false,

      -- Smooth animation settings for good fps feel
      stiffness = 0.7,      -- Balanced speed and smoothness
      trailing_stiffness = 0.4,  -- Smooth trailing effect
      trailing_exponent = 0.1,   -- Smoother trail fade
      gamma = 2.2,          -- Better gamma correction for smoothness
      distance_stop_animating = 0.5,
      hide_target_hack = false,
    },
  },
})

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic Neovim settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- Disable mouse to prevent hover selection in completion menu
vim.opt.mouse = ""

-- Tab management keybindings
vim.keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })

-- Window splitting keybindings
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })

-- Window navigation keybindings
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })

-- File explorer keybinding
vim.keymap.set("n", "<leader>ee", "<CMD>Oil<CR>", { desc = "Open file explorer" })

-- Trouble keybindings for diagnostics
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
vim.keymap.set("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP Definitions / references / ... (Trouble)" })

-- Half-page scrolling keybindings with centering
vim.keymap.set("n", "<C-u>", "<C-d>zz", { desc = "Scroll down half page" })
vim.keymap.set("n", "<C-i>", "<C-u>zz", { desc = "Scroll up half page" })
vim.keymap.set("v", "<C-u>", "<C-d>zz", { desc = "Scroll down half page" })
vim.keymap.set("v", "<C-i>", "<C-u>zz", { desc = "Scroll up half page" })

-- Telescope keybindings
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Commands" })
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" })
vim.keymap.set("n", "<leader>ft", "<cmd>Telescope colorscheme enable_preview=true<cr>", { desc = "Color schemes with preview" })

-- Insert mode escape keybinding
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Move lines up and down with Alt+j/k
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down (insert mode)" })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up (insert mode)" })

-- Swap jumplist navigation keybindings
vim.keymap.set("n", "<C-p>", "<C-i>", { desc = "Jump forward in jumplist" })
vim.keymap.set("n", "<C-o>", "<C-o>", { desc = "Jump back in jumplist" })

-- Harpoon keybindings (with proper initialization)
vim.keymap.set("n", "<leader>ma", function()
  local ok, harpoon = pcall(require, "harpoon")
  if not ok then
    vim.notify("Harpoon not loaded", vim.log.levels.WARN)
    return
  end

  harpoon.setup() -- Ensure it's set up
  local mark = require("harpoon.mark")
  mark.add_file()
  vim.notify("File added to harpoon!", vim.log.levels.INFO)
end, { desc = "Add file to harpoon" })

vim.keymap.set("n", "<leader>mm", function()
  local ok, harpoon = pcall(require, "harpoon")
  if not ok then
    vim.notify("Harpoon not loaded", vim.log.levels.WARN)
    return
  end

  harpoon.setup() -- Ensure it's set up
  local ui = require("harpoon.ui")
  ui.toggle_quick_menu()
end, { desc = "Toggle harpoon menu" })

-- Simple navigation keybindings
vim.keymap.set("n", "<leader>m1", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(1)
  end
end, { desc = "Harpoon file 1" })

vim.keymap.set("n", "<leader>m2", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(2)
  end
end, { desc = "Harpoon file 2" })

vim.keymap.set("n", "<leader>m3", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(3)
  end
end, { desc = "Harpoon file 3" })

vim.keymap.set("n", "<leader>m4", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(4)
  end
end, { desc = "Harpoon file 4" })

vim.keymap.set("n", "<leader>m5", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(5)
  end
end, { desc = "Harpoon file 5" })

vim.keymap.set("n", "<leader>m6", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(6)
  end
end, { desc = "Harpoon file 6" })

vim.keymap.set("n", "<leader>m7", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(7)
  end
end, { desc = "Harpoon file 7" })

vim.keymap.set("n", "<leader>m8", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(8)
  end
end, { desc = "Harpoon file 8" })

vim.keymap.set("n", "<leader>m9", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.setup()
    require("harpoon.ui").nav_file(9)
  end
end, { desc = "Harpoon file 9" })

-- Enable line numbers in LSP Saga floating windows
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sagafinder", "sagaoutline", "lspsagafinder" },
  callback = function()
    vim.wo.number = true
    vim.wo.relativenumber = true
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype

    -- Check for various LSP Saga buffer patterns
    if filetype == "sagafinder" or
       filetype == "lspsagafinder" or
       filetype == "sagaoutline" or
       string.match(bufname, "lspsaga://") or
       string.match(bufname, "Lspsaga") or
       vim.api.nvim_win_get_config(0).relative ~= "" then -- floating window
      vim.wo.number = true
      vim.wo.relativenumber = true
    end
  end,
})

-- Alternative approach: Force line numbers in all floating windows
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "*",
  callback = function()
    local win_config = vim.api.nvim_win_get_config(0)
    if win_config.relative ~= "" then -- This is a floating window
      vim.wo.number = true
      vim.wo.relativenumber = true
    end
  end,
})

-- Force line numbers in all new windows (catches LSP Saga popups)
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    vim.schedule(function()
      local win_config = vim.api.nvim_win_get_config(0)
      if win_config.relative ~= "" then
        vim.wo.number = true
        vim.wo.relativenumber = true
      end
    end)
  end,
})

-- Hook into LSP Saga's window creation
vim.api.nvim_create_autocmd("User", {
  pattern = "LspsagaUpdateFloatWinOptions",
  callback = function()
    vim.wo.number = true
    vim.wo.relativenumber = true
  end,
})

-- Auto-continue markdown bullets
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.formatoptions:append("ro")
    vim.opt_local.comments = "fb:*,fb:-,fb:+,n:>"
  end,
})

-- Markdown keybindings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Markdown Preview
    vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { buffer = true, desc = "Markdown Preview" })
    vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", { buffer = true, desc = "Stop Markdown Preview" })
    vim.keymap.set("n", "<leader>mt", "<cmd>MarkdownPreviewToggle<CR>", { buffer = true, desc = "Toggle Markdown Preview" })

    -- Table mode toggle
    vim.keymap.set("n", "<leader>tm", "<cmd>TableModeToggle<CR>", { buffer = true, desc = "Toggle Table Mode" })

    -- Generate TOC
    vim.keymap.set("n", "<leader>toc", "<cmd>GenTocGFM<CR>", { buffer = true, desc = "Generate TOC (GitHub)" })
  end,
})