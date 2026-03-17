-- Set leader key before lazy so plugins pick it up at setup time
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

	-- Which-key: shows available keybindings in a popup when you pause after <leader>
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({ delay = 500 })
			-- Register key group labels so the popup shows meaningful names
			wk.add({
				{ "<leader>f",  group = "find (telescope)" },
				{ "<leader>g",  group = "git / github" },
				{ "<leader>gp", group = "pull requests" },
				{ "<leader>gi", group = "issues" },
				{ "<leader>gr", group = "reviews" },
				{ "<leader>h",  group = "hunks (gitsigns)" },
				{ "<leader>m",  group = "marks (harpoon)" },
				{ "<leader>t",  group = "tabs / terminal" },
				{ "<leader>s",  group = "splits" },
				{ "<leader>x",  group = "diagnostics (trouble)" },
				{ "<leader>c",  group = "code" },
			})
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
					"ts_ls",        -- TypeScript/JavaScript
					"clangd",       -- C/C++
					"jdtls",        -- Java
					"intelephense", -- PHP
					"html",         -- HTML
					"cssls",        -- CSS
					"lua_ls",       -- Lua
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

			-- Lua
			vim.lsp.config.lua_ls = {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
						diagnostics = { globals = { "vim" } },
						telemetry = { enable = false },
					},
				},
			}

			-- Enable LSP servers
			vim.lsp.enable({ "ts_ls", "clangd", "jdtls", "intelephense", "html", "cssls", "lua_ls" })

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
					end,
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

	-- Spectre: project-wide search and replace
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Spectre",
		config = function()
			require("spectre").setup()
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
					enable = false,
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

	-- Treesitter for syntax highlighting and folding
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"javascript",
					"typescript",
					"html",
					"css",
					"json",
					"c",
					"cpp",
					"java",
					"php",
					"markdown",
					"markdown_inline",
				},
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					disable = function(_, buf)
						return vim.api.nvim_buf_line_count(buf) > 10000
							or (vim.fn.getfsize(vim.api.nvim_buf_get_name(buf)) > 1024 * 1024)
					end,
				},
				indent = {
					enable = true,
				},
			})
		end,
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
				build = "make",
			},
		},
		config = function()
			require("telescope").setup({
				defaults = {
					prompt_prefix = "🔍 ",
					selection_caret = "➤ ",
					path_display = { "absolute" },
					vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
				},
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
						"%.zip",
					},
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.35,
							results_width = 0.65,
						},
						vertical = {
							mirror = false,
						},
						width = 0.97,
						height = 0.90,
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

	-- Neogit - Git interface
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("neogit").setup({
				kind = "replace",
				graph_style = "ascii",
				status = {
					recent_commit_count = 10,
				},
				integrations = {
					diffview = true,
					telescope = true,
				},
			})
		end,
	},

	-- Gitsigns - git status in the gutter and hunk operations
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add          = { text = "▎" },
					change       = { text = "▎" },
					delete       = { text = "" },
					topdelete    = { text = "" },
					changedelete = { text = "▎" },
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local map = function(mode, l, r, desc)
						vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
					end
					-- Navigate hunks
					map("n", "]h", gs.next_hunk, "Next hunk")
					map("n", "[h", gs.prev_hunk, "Prev hunk")
					-- Stage / reset
					map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
					map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
					map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
					map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
					-- Blame
					map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
					map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle inline blame")
					-- Preview hunk diff
					map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
					-- Diff current file
					map("n", "<leader>hd", gs.diffthis, "Diff this file")
				end,
			})
		end,
	},

	-- Octo - GitHub integration (PRs, issues, reviews)
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup()
		end,
	},

	-- Harpoon for quick file navigation
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon").setup()

			-- Patch nav_file to handle terminal buffers; harpoon's default
			-- nav_file treats term:// paths as files causing an empty buffer
			local ui = require("harpoon.ui")
			local original_nav_file = ui.nav_file
			ui.nav_file = function(idx)
				local mark = require("harpoon.mark")
				local filename = nil
				local ok, item = pcall(mark.get_marked_file, idx)
				if ok and item then filename = item.filename end
				if not filename then
					local nok, name = pcall(mark.get_marked_file_name, idx)
					if nok then filename = name end
				end

				if filename and filename:match("term://") then
					local home = vim.fn.expand("~")
					local stored = filename:gsub("^term://~", "term://" .. home)
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
							local buf_name = vim.api.nvim_buf_get_name(buf)
							local buf_norm = buf_name:gsub("^term://~", "term://" .. home)
							if buf_norm == stored or buf_name == filename then
								vim.api.nvim_set_current_buf(buf)
								vim.cmd("startinsert")
								return
							end
						end
					end
					-- Terminal process is gone, open a fresh one
					vim.cmd("terminal")
					return
				end

				original_nav_file(idx)
			end
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
				toc = {},
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
					add = "sa", -- Add surrounding in Normal and Visual modes
					delete = "sd", -- Delete surrounding
					find = "sf", -- Find surrounding (to the right)
					find_left = "sF", -- Find surrounding (to the left)
					highlight = "sh", -- Highlight surrounding
					replace = "sr", -- Replace surrounding
					update_n_lines = "sn", -- Update `n_lines`
				},
			})
		end,
	},

	-- Mini.ai for enhanced text objects
	{
		"echasnovski/mini.ai",
		version = "*",
		config = function()
			require("mini.ai").setup({
				-- Number of lines within which textobject is searched
				n_lines = 500,

				-- Custom textobjects (default includes: brackets, quotes, function calls, tags, etc.)
				custom_textobjects = nil,
			})
		end,
	},

	-- UFO for VSCode-like folding
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			-- Fold consecutive single-line comment blocks
			local function get_comment_ranges(bufnr)
				local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
				local cms = vim.bo[bufnr].commentstring or "// %s"
				local prefix = vim.trim(cms:match("^(.-)%s*%%s") or "//")
				if prefix == "" then return {} end
				local ranges, start = {}, nil
				for i, line in ipairs(lines) do
					local trimmed = vim.trim(line)
					if trimmed ~= "" and vim.startswith(trimmed, prefix) then
						start = start or (i - 1)
					else
						if start ~= nil then
							if (i - 2) > start then
								table.insert(ranges, { startLine = start, endLine = i - 2 })
							end
							start = nil
						end
					end
				end
				if start ~= nil and (#lines - 1) > start then
					table.insert(ranges, { startLine = start, endLine = #lines - 1 })
				end
				return ranges
			end

			local function merge_comment_ranges(ranges, comment_ranges)
				local seen = {}
				for _, r in ipairs(ranges or {}) do
					seen[r.startLine .. ":" .. r.endLine] = true
				end
				local result = vim.deepcopy(ranges or {})
				for _, cr in ipairs(comment_ranges) do
					if not seen[cr.startLine .. ":" .. cr.endLine] then
						table.insert(result, cr)
					end
				end
				return result
			end

			-- Generic brace fold provider: works for any language.
			-- Detects {} blocks by checking if a node's first child is "{" and last is "}".
			-- No hardcoded node-type lists — C++, Java, Lua, PHP, etc. all work automatically.
			local function brace_fold_provider(bufnr)
				local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
				if not ok or not parser then return nil end
				local trees = parser:parse()
				if not trees or not trees[1] then return nil end
				local ranges = {}
				local function walk(node)
					local count = node:child_count()
					if count >= 2 then
						local first = node:child(0)
						local last  = node:child(count - 1)
						if first and last and first:type() == "{" and last:type() == "}" then
							local sr, _, er, _ = node:range()
							if er - 1 > sr then
								table.insert(ranges, { startLine = sr, endLine = er - 1 })
							end
						end
					end
					for child in node:iter_children() do
						walk(child)
					end
				end
				walk(trees[1]:root())
				return ranges
			end

			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					local has_ts = pcall(vim.treesitter.get_parser, bufnr)
					if has_ts then
						return function(bufnr)
							local ranges = brace_fold_provider(bufnr)
							return merge_comment_ranges(ranges or {}, get_comment_ranges(bufnr))
						end
					end
					return { "lsp", "indent" }
				end,
			})
		end,
	},

	-- Bufferline: visual tab bar for open buffers
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					separator_style = "thick",
					show_buffer_close_icons = true,
					show_close_icon = false,
				show_tab_indicators = false,
					diagnostics = "nvim_lsp",
				diagnostics_indicator = function() return "" end,
					indicator = { style = "underline" },
					custom_filter = function(buf_number)
						return vim.bo[buf_number].buftype ~= "terminal"
					end,
				},
				highlights = {
					-- Active tab: brighter background + colored underline, text unchanged
					buffer_selected = {
						bg = "#313244",
						underline = true,
						sp = "#89b4fa", -- blue underline (catppuccin mocha)
					},
					-- Inactive tabs: slightly dimmed background
					buffer_visible = { bg = "#1e1e2e" },
					background       = { bg = "#1e1e2e" },
				},
			})
		end,
	},

	-- Persistence: save and restore sessions (buffers survive restarts)
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		config = function()
			require("persistence").setup({
				dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
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
			stiffness = 0.7, -- Balanced speed and smoothness
			trailing_stiffness = 0.4, -- Smooth trailing effect
			trailing_exponent = 0.1, -- Smoother trail fade
			gamma = 2.2, -- Better gamma correction for smoothness
			distance_stop_animating = 0.5,
			hide_target_hack = false,
		},
	},
})

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
vim.opt.fileformat = "unix" -- write files with LF line endings to avoid ^M
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true    -- search is case-insensitive by default
vim.opt.smartcase = true     -- ...unless you type a capital letter, then it becomes case-sensitive
vim.opt.scrolloff = 8        -- always keep 8 lines visible above/below the cursor when scrolling
vim.opt.splitbelow = true    -- horizontal splits (:split) open below instead of above
vim.opt.splitright = true    -- vertical splits (:vsplit) open to the right instead of left
vim.opt.undofile = true      -- save undo history to disk so you can undo even after closing a file
vim.opt.updatetime = 500     -- milliseconds before CursorHold fires; balance between responsiveness and CPU (default is 4000)

-- Normalize pasted CRLF text (common from browsers) to LF so ^M is not inserted.
local _original_paste = vim.paste
vim.paste = function(lines, phase)
    for i, line in ipairs(lines) do
        lines[i] = line:gsub("\r$", "")
    end
    return _original_paste(lines, phase)
end

-- Disable mouse to prevent hover selection in completion menu
vim.opt.mouse = ""

-- Folding configuration (nvim-ufo for VSCode-like folding)
vim.opt.foldcolumn = "1" -- Show fold column
vim.opt.foldlevel = 99 -- Start with all folds open
vim.opt.foldlevelstart = 99 -- Start with all folds open for new buffers
vim.opt.foldenable = true -- Enable folding
vim.opt.foldopen = "search,tag,quickfix" -- Only auto-open folds for search matches, not cursor movement

-- Folding keybindings (using nvim-ufo)
vim.keymap.set("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
vim.keymap.set("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
vim.keymap.set("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Open folds except kinds" })
vim.keymap.set("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Close folds with level" })
vim.keymap.set("n", "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, { desc = "Peek fold" })

-- Fold-aware e / w: never enters a closed fold.
-- Case 1 – cursor IS on the fold header  → navigate within that line only.
-- Case 2 – cursor is before a fold       → do normal motion, then if we
--           accidentally entered a fold (it opened), close it and skip past.
local function is_word_char(c)
	return type(c) == "string" and c:match("[%w_]") ~= nil
end

local function next_word_end_in_line(line, col)
	local n = #line
	local i = col
	-- Mid-word → go to end of current word
	if is_word_char(line:sub(i + 1, i + 1)) and is_word_char(line:sub(i + 2, i + 2)) then
		while i + 1 < n and is_word_char(line:sub(i + 2, i + 2)) do i = i + 1 end
		return i
	end
	-- Otherwise advance and find the next word end
	i = i + 1
	while i < n and not is_word_char(line:sub(i + 1, i + 1)) do i = i + 1 end
	if i >= n then return nil end
	while i + 1 < n and is_word_char(line:sub(i + 2, i + 2)) do i = i + 1 end
	return is_word_char(line:sub(i + 1, i + 1)) and i or nil
end

local function next_word_start_in_line(line, col)
	local n = #line
	local i = col
	while i < n and is_word_char(line:sub(i + 1, i + 1)) do i = i + 1 end
	while i < n and not is_word_char(line:sub(i + 1, i + 1)) do i = i + 1 end
	return (i < n and is_word_char(line:sub(i + 1, i + 1))) and i or nil
end

local function fold_safe_motion(motion_key, find_in_line)
	return function()
		local lnum = vim.fn.line(".")
		local col  = vim.fn.col(".") - 1
		local buf_count = vim.api.nvim_buf_line_count(0)

		-- Case 1: cursor is on the header of a closed fold
		local fold_end = vim.fn.foldclosedend(lnum)
		if fold_end ~= -1 then
			local line = vim.api.nvim_get_current_line()
			local target = find_in_line(line, col)
			if target then
				vim.api.nvim_win_set_cursor(0, { lnum, target })
			else
				local skip = fold_end + 1
				if skip <= buf_count then
					vim.api.nvim_win_set_cursor(0, { skip, 0 })
					vim.cmd("normal! " .. motion_key)
				end
			end
			return
		end

		-- Case 2: not on a fold — snapshot the nearest closed fold ahead so
		-- we can detect if the motion accidentally enters it.
		local near_start, near_end = -1, -1
		for l = lnum, math.min(lnum + 200, buf_count) do
			local fs = vim.fn.foldclosed(l)
			if fs ~= -1 then
				near_start = fs
				near_end   = vim.fn.foldclosedend(l)
				break
			end
		end

		vim.cmd("normal! " .. motion_key)

		local new_lnum = vim.fn.line(".")
		if near_start ~= -1 and new_lnum ~= lnum
			and new_lnum >= near_start and new_lnum <= near_end then
			-- Motion entered a fold and opened it → close it and skip past
			vim.api.nvim_win_set_cursor(0, { near_start, 0 })
			vim.cmd("normal! zc")
			local skip = near_end + 1
			if skip <= buf_count then
				vim.api.nvim_win_set_cursor(0, { skip, 0 })
				vim.cmd("normal! " .. motion_key)
			end
		end
	end
end

vim.keymap.set("n", "e", fold_safe_motion("e", next_word_end_in_line),   { desc = "Word end (fold-aware)" })
vim.keymap.set("n", "w", fold_safe_motion("w", next_word_start_in_line), { desc = "Word forward (fold-aware)" })

-- CRLF-safe put: only active in normal file buffers so plugins like Neogit keep their p/P keys.
local function put_without_cr(after)
    local reg = vim.v.register
    if reg == "" then reg = '"' end
    local regtype = vim.fn.getregtype(reg)
    local lines = vim.fn.getreg(reg, 1, true)
    if type(lines) ~= "table" then lines = { tostring(lines) } end
    for i, line in ipairs(lines) do
        lines[i] = line:gsub("\r$", "")
    end
    for _ = 1, vim.v.count1 do
        vim.api.nvim_put(lines, regtype:sub(1, 1), after, true)
    end
end

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if vim.bo.buftype == "" and vim.bo.modifiable then
            vim.keymap.set("n", "p", function() put_without_cr(true) end, { buffer = true, desc = "Put after (CRLF-safe)" })
            vim.keymap.set("n", "P", function() put_without_cr(false) end, { buffer = true, desc = "Put before (CRLF-safe)" })
        end
    end,
})

-- Smart fold: fold from { to its exact matching } using % matching (same as bracket jump).
-- If no { on/after cursor, jump to enclosing { first.
vim.keymap.set("n", "za", function()
	local lnum = vim.fn.line(".")
	local col = vim.fn.col(".") -- 1-indexed
	local line = vim.api.nvim_get_current_line()

	-- If already on a closed fold, open it and return
	if vim.fn.foldclosed(lnum) ~= -1 then
		vim.cmd("normal! zo")
		return
	end

	-- Find { on or after cursor on this line
	local rest = line:sub(col)
	local brace_offset = rest:find("{", 1, true)
	if not brace_offset then
		-- No { on this line: jump to enclosing {
		vim.cmd("normal! [{")
		lnum = vim.fn.line(".")
		line = vim.api.nvim_get_current_line()
		col = 1
		brace_offset = line:find("{", 1, true)
		if not brace_offset then return end
	end

	-- Move cursor to the { so % finds the exact matching }
	local brace_col = col + brace_offset - 2 -- 0-indexed for nvim_win_set_cursor
	vim.api.nvim_win_set_cursor(0, { lnum, brace_col })

	-- Use % to jump to the matching }
	vim.cmd("normal! %")
	local end_lnum = vim.fn.line(".")

	-- Restore cursor to the opening {
	vim.api.nvim_win_set_cursor(0, { lnum, brace_col })

	-- Create fold from { line to } line
	if end_lnum > lnum then
		vim.cmd(lnum .. "," .. end_lnum .. "fold")
	end
end, { desc = "Smart fold: toggle block using % matching" })

-- Tab management keybindings
vim.keymap.set("n", "<leader>to", ":enew<CR>",                       { desc = "Open new buffer tab" })
vim.keymap.set("n", "<leader>tn", ":BufferLineCycleNext<CR>",         { desc = "Next buffer tab" })
vim.keymap.set("n", "<leader>tp", ":BufferLineCyclePrev<CR>",         { desc = "Prev buffer tab" })
vim.keymap.set("n", "<leader>tx", ":bdelete<CR>",                     { desc = "Close buffer tab" })

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
vim.keymap.set("n", "<leader>ee", function()
	local buf = vim.api.nvim_get_current_buf()
	-- Only track normal file buffers (not Oil, terminal, etc.)
	if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
		vim.g._pre_oil_buf = buf
	end
	vim.cmd("Oil")
end, { desc = "Open file explorer" })

-- Spectre keybindings
vim.keymap.set("n", "<leader>S",  function() require("spectre").toggle() end,                              { desc = "Toggle Spectre" })
vim.keymap.set("n", "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end,   { desc = "Search current word" })
vim.keymap.set("v", "<leader>sw", function() require("spectre").open_visual() end,                         { desc = "Search selection" })
vim.keymap.set("n", "<leader>sf", function() require("spectre").open_file_search({ select_word = true }) end, { desc = "Search in current file" })

-- Trouble keybindings for diagnostics
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>xX",
	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Buffer Diagnostics (Trouble)" }
)
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>cl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "LSP Definitions / references / ... (Trouble)" }
)

-- Half-page scrolling keybindings with centering

-- Telescope keybindings
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Commands" })
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" })
vim.keymap.set(
	"n",
	"<leader>ft",
	"<cmd>Telescope colorscheme enable_preview=true<cr>",
	{ desc = "Color schemes with preview" }
)

-- Insert mode escape keybinding
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Suppress Neovim's built-in search count (it caps at 99 and shows ">99").
-- We replace it with our own exact count in the statusline.
vim.opt.shortmess:append("S")

_G.SearchCount = function()
  if vim.v.hlsearch == 0 then return "" end
  -- recompute=1 forces a fresh count with maxcount=0 (no cap)
  local ok, count = pcall(vim.fn.searchcount, { maxcount = 0, recompute = 1 })
  if not ok or not count or (count.total or 0) == 0 then return "" end
  if count.incomplete == 1 then return "[?/?] " end -- timed out
  return string.format("[%d/%d] ", count.current, count.total)
end

vim.opt.statusline = "%f %h%m%r %= %{v:lua.SearchCount()}%l:%c "

-- Delete without copying to register (use black hole register)
vim.keymap.set("n", "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set("n", "D", '"_D', { desc = "Delete to end of line without yanking" })
vim.keymap.set("v", "d", '"_d', { desc = "Delete selection without yanking" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete char without yanking" })

-- Change without copying to register (use black hole register)
vim.keymap.set("n", "c", '"_c', { desc = "Change without yanking" })
vim.keymap.set("n", "cc", '"_cc', { desc = "Change line without yanking" })
vim.keymap.set("n", "C", '"_C', { desc = "Change to end of line without yanking" })
vim.keymap.set("v", "c", '"_c', { desc = "Change selection without yanking" })
vim.keymap.set("n", "s", '"_s', { desc = "Substitute char without yanking" })
vim.keymap.set("n", "S", '"_S', { desc = "Substitute line without yanking" })
vim.keymap.set("v", "s", '"_s', { desc = "Substitute selection without yanking" })

-- Leader + d to cut (delete with yanking, like normal d behavior)
vim.keymap.set("n", "<leader>d", "d", { desc = "Cut (delete with yank)" })
vim.keymap.set("n", "<leader>dd", "dd", { desc = "Cut line (delete with yank)" })
vim.keymap.set("n", "<leader>D", "D", { desc = "Cut to end of line (delete with yank)" })
vim.keymap.set("v", "<leader>d", "d", { desc = "Cut selection (delete with yank)" })

-- Move lines up and down with Alt+j/k
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down (insert mode)" })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up (insert mode)" })


-- Terminal open in split
vim.keymap.set("n", "<leader>tt", ":terminal<CR>")
vim.keymap.set("n", "<leader>tv", ":botright vsplit | terminal<CR>")
vim.keymap.set("n", "<leader>th", ":botright split | terminal<CR>")
-- jk exits terminal mode; wipe buffer when window closes (removes from bufferline)
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(args)
		vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = args.buf })
		vim.bo[args.buf].bufhidden = "wipe"
	end,
})

-- Notes keybindings
vim.fn.mkdir(vim.fn.expand("~/notes"), "p")
vim.keymap.set("n", "<leader>nt", ":e ~/notes/todo.md<CR>",        { desc = "Open todo" })
vim.keymap.set("n", "<leader>nb", ":e ~/notes/brainstorm.md<CR>",  { desc = "Open brainstorm" })
vim.keymap.set("n", "<leader>nn", function()
	vim.cmd(":e ~/notes/scratch-" .. os.date("%Y%m%d-%H%M%S") .. ".md")
end, { desc = "New scratch note" })
vim.keymap.set("n", "<leader>nf", ":Telescope find_files cwd=~/notes<CR>", { desc = "Find notes" })
vim.keymap.set("n", "<leader>ng", ":Telescope live_grep cwd=~/notes<CR>",  { desc = "Grep notes" })

-- Session keybindings (persistence.nvim)
vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end,            { desc = "Restore session" })
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end,            { desc = "Don't save session on exit" })

-- Bufferline keybindings
vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Prev buffer tab" })
vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next buffer tab" })
vim.keymap.set("n", "<S-x>", ":bdelete<CR>",             { desc = "Close buffer" })

-- Neogit
vim.keymap.set("n", "<leader>lg", function()
	require("neogit").open({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Open Neogit" })

-- Octo (GitHub) keybindings
-- PRs
vim.keymap.set("n", "<leader>gpc", "<cmd>Octo pr create<cr>", { desc = "Create PR" })
vim.keymap.set("n", "<leader>gpl", "<cmd>Octo pr list<cr>", { desc = "List PRs" })
vim.keymap.set("n", "<leader>gpm", "<cmd>Octo pr merge<cr>", { desc = "Merge PR" })
vim.keymap.set("n", "<leader>gpC", "<cmd>Octo pr checkout<cr>", { desc = "Checkout PR branch" })
vim.keymap.set("n", "<leader>gpk", "<cmd>Octo pr checks<cr>", { desc = "PR checks / CI status" })
vim.keymap.set("n", "<leader>gpr", "<cmd>Octo pr ready<cr>", { desc = "Mark PR as ready (convert from draft)" })
vim.keymap.set("n", "<leader>gpx", "<cmd>Octo pr close<cr>", { desc = "Close PR" })
-- Issues
vim.keymap.set("n", "<leader>gic", "<cmd>Octo issue create<cr>", { desc = "Create issue" })
vim.keymap.set("n", "<leader>gil", "<cmd>Octo issue list<cr>", { desc = "List issues" })
vim.keymap.set("n", "<leader>gix", "<cmd>Octo issue close<cr>", { desc = "Close issue" })
-- Reviews
vim.keymap.set("n", "<leader>grs", "<cmd>Octo review start<cr>", { desc = "Start review" })
vim.keymap.set("n", "<leader>grr", "<cmd>Octo review resume<cr>", { desc = "Resume existing pending review" })
vim.keymap.set("n", "<leader>grS", "<cmd>Octo review submit<cr>", { desc = "Submit review (approve/comment/request changes)" })
vim.keymap.set("n", "<leader>grD", "<cmd>Octo review discard<cr>", { desc = "Discard review" })
-- Misc
vim.keymap.set("n", "<leader>gco", "<cmd>Octo comment add<cr>", { desc = "Add comment" })
vim.keymap.set("n", "<leader>gra", "<cmd>Octo reviewer add<cr>", { desc = "Add reviewer" })
vim.keymap.set("n", "<leader>gla", "<cmd>Octo label add<cr>", { desc = "Add label" })

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

-- Terminal-aware harpoon navigation:
-- if the stored entry is a terminal (term://...), jump to the live buffer if it
-- still exists, otherwise open a fresh terminal instead of an empty text file
local function nav_harpoon(idx)
	local ok, harpoon = pcall(require, "harpoon")
	if not ok then return end
	harpoon.setup()
	require("harpoon.ui").nav_file(idx)
end

-- Navigation keybindings
vim.keymap.set("n", "<leader>m1", function() nav_harpoon(1) end, { desc = "Harpoon file 1" })
vim.keymap.set("n", "<leader>m2", function() nav_harpoon(2) end, { desc = "Harpoon file 2" })
vim.keymap.set("n", "<leader>m3", function() nav_harpoon(3) end, { desc = "Harpoon file 3" })
vim.keymap.set("n", "<leader>m4", function() nav_harpoon(4) end, { desc = "Harpoon file 4" })
vim.keymap.set("n", "<leader>m5", function() nav_harpoon(5) end, { desc = "Harpoon file 5" })
vim.keymap.set("n", "<leader>m6", function() nav_harpoon(6) end, { desc = "Harpoon file 6" })
vim.keymap.set("n", "<leader>m7", function() nav_harpoon(7) end, { desc = "Harpoon file 7" })
vim.keymap.set("n", "<leader>m8", function() nav_harpoon(8) end, { desc = "Harpoon file 8" })
vim.keymap.set("n", "<leader>m9", function() nav_harpoon(9) end, { desc = "Harpoon file 9" })

-- When a real file is opened after using Oil, delete the buffer that was open before Oil.
-- This prevents files from accumulating in bufferline when navigating via Oil.
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local pre = vim.g._pre_oil_buf
		if not pre then return end
		local cur = vim.api.nvim_get_current_buf()
		-- Only act when we land on a normal file buffer (not Oil, terminal, quickfix, etc.)
		if vim.bo[cur].buftype ~= "" then return end
		if cur == pre then vim.g._pre_oil_buf = nil; return end
		-- Delete the pre-Oil buffer if it has no unsaved changes and isn't visible anywhere
		vim.g._pre_oil_buf = nil
		if vim.api.nvim_buf_is_valid(pre)
			and not vim.bo[pre].modified
			and #vim.fn.win_findbuf(pre) == 0
		then
			pcall(vim.api.nvim_buf_delete, pre, { force = false })
		end
	end,
})

-- Enable line numbers in LSP Saga floating windows
vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		if vim.api.nvim_win_get_config(0).relative ~= "" then
			vim.wo.number = true
			vim.wo.relativenumber = true
		end
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
		vim.keymap.set(
			"n",
			"<leader>ms",
			"<cmd>MarkdownPreviewStop<CR>",
			{ buffer = true, desc = "Stop Markdown Preview" }
		)
		vim.keymap.set(
			"n",
			"<leader>mt",
			"<cmd>MarkdownPreviewToggle<CR>",
			{ buffer = true, desc = "Toggle Markdown Preview" }
		)

		-- Table mode toggle
		vim.keymap.set("n", "<leader>tm", "<cmd>TableModeToggle<CR>", { buffer = true, desc = "Toggle Table Mode" })

		-- Generate TOC
		vim.keymap.set("n", "<leader>toc", "<cmd>GenTocGFM<CR>", { buffer = true, desc = "Generate TOC (GitHub)" })
	end,
})

