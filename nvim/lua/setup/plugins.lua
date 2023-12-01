return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.2",
		dependencies = { "nvim-lua/plenary.nvim" },
		lazy = false,
		priority = 900,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme rose-pine-dawn]])
		end,
	},
	{

		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		priority = 1,

		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "python", "javascript", "typescript", "lua", "sql", "markdown", "markdown_inline" },
				sync_install = false,
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
				playground = {
					enable = true,
					disable = {},
					updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
					persist_queries = false, -- Whether the query persists across vim sessions
					keybindings = {
						toggle_query_editor = "o",
						toggle_hl_groups = "i",
						toggle_injected_languages = "t",
						toggle_anonymous_nodes = "a",
						toggle_language_display = "I",
						focus_language = "f",
						unfocus_language = "F",
						update = "R",
						goto_node = "<cr>",
						show_help = "?",
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/playground",
		priority = 2,
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		lazy = true,
		config = function()
			-- This is where you modify the settings for lsp-zero
			-- Note: autocompletion settings will not take effect

			require("lsp-zero.settings").preset({})
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{ "L3MON4D3/LuaSnip" },
		},
		config = function()
			-- Here is where you configure the autocompletion settings.
			-- The arguments for .extend() have the same shape as `manage_nvim_cmp`:
			-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#manage_nvim_cmp

			require("lsp-zero.cmp").extend()

			-- And you can configure cmp even more, if you want to.
			local cmp = require("cmp")
			local cmp_action = require("lsp-zero.cmp").action()
			local lspkind = require("lspkind")

			cmp.setup({
				-- sources = { { name = "vim-dadbod-completion" } },
				mapping = {
					-- ["<Tab>"] = cmp_action.luasnip_supertab(),
					-- ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
					-- ['<C-Space>'] = cmp.mapping.complete(),
					-- ['<C-f>'] = cmp_action.luasnip_jump_forward(),
					-- ['<C-b>'] = cmp_action.luasnip_jump_backward(),
					-- ['<CR>'] = cmp_action.luasnip(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol", -- show only symbol annotations
						maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

						-- The function below will be called before any actual modifications from lspkind
						-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
					}),
				},
			})
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		cmd = "LspInfo",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "williamboman/mason.nvim" },
		},
		config = function()
			-- This is where all the LSP shenanigans will live

			local lsp = require("lsp-zero")

			lsp.on_attach(function(client, bufnr)
				-- see :help lsp-zero-keybindings
				-- to learn the available actions
				-- lsp.default_keymaps({buffer = bufnr})
				local opts = { buffer = bufnr }
				vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
				vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
				vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
				vim.keymap.set("n", "<leader>vca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

				-- vim.api.nvim_create_autocmd("CursorHold", {
				-- 	callback = function()
				-- 		vim.lsp.buf.document_highlight()
				-- 	end,
				-- })
				--
				-- vim.api.nvim_create_autocmd("CursorHoldI", {
				-- 	callback = function()
				-- 		vim.lsp.buf.document_highlight()
				-- 	end,
				-- })
				--
				-- vim.api.nvim_create_autocmd("CursorMoved", {
				-- 	callback = function()
				-- 		vim.lsp.buf.clear_references()
				-- 	end,
				-- })
			end)

			lsp.set_server_config({
				capabilities = {
					textDocument = {
						foldingRange = {
							dynamicRegistration = false,
							lineFoldingOnly = true,
						},
					},
				},
			})

			-- (Optional) Configure lua language server for neovim
			require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

			lsp.ensure_installed("pyright")
			lsp.ensure_installed("tsserver")
			lsp.setup()
		end,
	},

	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		config = function()
			require("lspsaga").setup({})
			vim.keymap.set("n", "<leader>lp", "<cmd>Lspsaga peek_definition<cr>")
			vim.keymap.set("n", "<leader>lo", "<cmd>Lspsaga outline<cr>")
			vim.keymap.set("n", "<leader>lr", "<cmd>Lspsaga rename<cr>")
			vim.keymap.set("n", "<leader>lf", "<cmd>Lspsaga finder<cr>")
			vim.keymap.set("n", "<leader>la", "<cmd>Lspsaga code_action<cr>")
			vim.keymap.set("n", "<leader>lci", "<cmd>Lspsaga incoming_calls<cr>")
			vim.keymap.set("n", "<leader>lco", "<cmd>Lspsaga outgoing_calls<cr>")
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter", -- optional
			"nvim-tree/nvim-web-devicons", -- optional
		},
	},

	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			local ufo = require("ufo")

			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
			-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

			-- Using ufo provider need remap `zR` and `zM`.
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

			local handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = ("  %d "):format(endLnum - lnum)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						-- str width returned from truncate() may less than 2nd argument, need padding
						if curWidth + chunkWidth < targetWidth then
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end
			ufo.setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
				fold_virt_text_handler = handler,
			})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		opts = {
			buftype_exclude = {
				"nofile",
				"terminal",
			},
			filetype_exclude = {
				"help",
				"startify",
				"aerial",
				"alpha",
				"dashboard",
				"lazy",
				"neogitstatus",
				"NvimTree",
				"neo-tree",
				"Trouble",
			},
			show_trailing_blankline_indent = false,
			use_treesitter = true,
			char = "▏",
			context_char = "▏",
			show_current_context = true,
		},
	},
	{
		"onsails/lspkind.nvim",
		priority = 2,
	},
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local mark = require("harpoon.mark")
			local ui = require("harpoon.ui")

			vim.keymap.set("n", "<leader>a", mark.add_file)
			vim.keymap.set("n", "<C-s>", ui.toggle_quick_menu)

			vim.keymap.set("n", "<C-h>", function()
				ui.nav_file(1)
			end)
			vim.keymap.set("n", "<C-j>", function()
				ui.nav_file(2)
			end)
			vim.keymap.set("n", "<C-k>", function()
				ui.nav_file(3)
			end)
			vim.keymap.set("n", "<C-l>", function()
				ui.nav_file(4)
			end)
			-- vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
		end,
	},
	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

			vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
			vim.opt.undofile = true
		end,
	},
	{
		"mfussenegger/nvim-lint",
	},
	{
		"elentok/format-on-save.nvim",
		lazy = false,
		config = function()
			local format_on_save = require("format-on-save")
			local formatters = require("format-on-save.formatters")

			format_on_save.setup({
				auto_commands = true,
				formatter_by_ft = {
					lua = formatters.stylua,
					python = formatters.shell({ cmd = { "black", "--stdin-filename", "%", "--quiet", "-" } }),
					typescript = formatters.prettierd,
					typescriptreact = formatters.prettierd,
				},
				run_with_sh = true,
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				hover = false,
				signature = false,

				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
			-- add any options here
		},
		cmdline = {
			enable = false,
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	-- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
		lazy = false,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {}, -- this is equalent to setup({}) function
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		config = function()
			require("gitsigns").setup({
				current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					map("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					-- Actions
					map("n", "<leader>hs", gs.stage_hunk)
					map("n", "<leader>hr", gs.reset_hunk)
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("n", "<leader>hS", gs.stage_buffer)
					map("n", "<leader>hu", gs.undo_stage_hunk)
					map("n", "<leader>hR", gs.reset_buffer)
					map("n", "<leader>hp", gs.preview_hunk)
					map("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gs.toggle_current_line_blame)
					map("n", "<leader>hd", gs.diffthis)
					map("n", "<leader>hD", function()
						gs.diffthis("~")
					end)
					-- map("n", "<leader>td", gs.toggle_deleted)

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	},
	{ "tpope/vim-fugitive" },
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup({ timeout = 100000 })
		end,
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",

			"nvim-neotest/neotest-python",
			"nvim-neotest/neotest-jest",
		},
		config = function()
			local neotest = require("neotest")
			vim.keymap.set("n", "<leader>tt", function()
				neotest.summary.toggle()
			end)
			vim.keymap.set("n", "<leader>tw", function()
				neotest.watch.toggle()
			end)
			vim.keymap.set("n", "<leader>tn", function()
				neotest.run.run()
			end)
			vim.keymap.set("n", "<leader>to", function()
				neotest.output_panel.toggle()
			end)

			neotest.setup({
				adapters = {
					require("neotest-python")({
						runner = "pytest",
						python = "python",
					}),
					require("neotest-jest")({
						runner = "npm test --",
					}),
				},
				highlights = {

					adapter_name = "LspSagaCodeActionTitle",
					border = "NeotestBorder",
					dir = "Boolean",
					failed = "DiffDelete",
					passed = "DiffAdd",
					file = "Directory",
					focused = "TargetWord",
					indent = "NeotestIndent",
					marked = "NeotestMarked",
					namespace = "subtle",
					running = "NeotestRunning",
					select_win = "NeotestWinSelect",
					skipped = "NeotestSkipped",
					target = "NeotestTarget",
					test = "NonText",
					unknown = "NeotestUnknown",
					watching = "NeotestWatching",
				},
			})
		end,
	},
	{
		"folke/neodev.nvim",
		opts = {
			library = {
				plugins = {
					"neotest",
				},
				types = true,
			},
		},
	},
	{
		"Pocco81/true-zen.nvim",
		config = function()
			vim.api.nvim_set_keymap("n", "<leader>z", ":TZMinimalist<CR>", {})
			local truezen = require("true-zen")
			truezen.setup({
				modes = { -- configurations per mode
					ataraxis = {
						shade = "dark", -- if `dark` then dim the padding windows, otherwise if it's `light` it'll brighten said windows
						backdrop = 0, -- percentage by which padding windows should be dimmed/brightened. Must be a number between 0 and 1. Set to 0 to keep the same background color
						minimum_writing_area = { -- minimum size of main window
							width = 70,
							height = 44,
						},
						quit_untoggles = true, -- type :q or :qa to quit Ataraxis mode
						padding = { -- padding windows
							left = 52,
							right = 52,
							top = 0,
							bottom = 0,
						},
						callbacks = { -- run functions when opening/closing Ataraxis mode
							open_pre = nil,
							open_pos = nil,
							close_pre = nil,
							close_pos = nil,
						},
					},
					minimalist = {
						ignored_buf_types = { "nofile" }, -- save current options from any window except ones displaying these kinds of buffers
						options = { -- options to be disabled when entering Minimalist mode
							number = false,
							relativenumber = true,
							showtabline = 0,
							signcolumn = "no",
							statusline = "",
							cmdheight = 1,
							laststatus = 0,
							showcmd = false,
							showmode = false,
							ruler = false,
							numberwidth = 1,
						},
						callbacks = { -- run functions when opening/closing Minimalist mode
							open_pre = nil,
							open_pos = nil,
							close_pre = nil,
							close_pos = nil,
						},
					},
					narrow = {
						--- change the style of the fold lines. Set it to:
						--- `informative`: to get nice pre-baked folds
						--- `invisible`: hide them
						--- function() end: pass a custom func with your fold lines. See :h foldtext
						folds_style = "informative",
						run_ataraxis = true, -- display narrowed text in a Ataraxis session
						callbacks = { -- run functions when opening/closing Narrow mode
							open_pre = nil,
							open_pos = nil,
							close_pre = nil,
							close_pos = nil,
						},
					},
					focus = {
						callbacks = { -- run functions when opening/closing Focus mode
							open_pre = nil,
							open_pos = nil,
							close_pre = nil,
							close_pos = nil,
						},
					},
				},
				integrations = {
					tmux = false, -- hide tmux status bar in (minimalist, ataraxis)
					kitty = { -- increment font size in Kitty. Note: you must set `allow_remote_control socket-only` and `listen_on unix:/tmp/kitty` in your personal config (ataraxis)
						enabled = true,
						font = "+3",
					},
					twilight = false, -- enable twilight (ataraxis)
					lualine = false, -- hide nvim-lualine (ataraxis)
				},
			})
		end,
	},
	{ "tpope/vim-projectionist", lazy = false },
	{ "tpope/vim-dispatch", lazy = false },
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
		end,
	},
	{
		"geg2102/nvim-python-repl",
		config = function()
			require("nvim-python-repl").setup({
				execute_on_send = false,
				vsplit = false,
				spawn_command = {
					python = "ipython",
					scala = "sbt console",
					lua = "ilua",
				},
			})

			vim.keymap.set("v", "<leader>e", function()
				require("nvim-python-repl").send_visual_to_repl()
			end, { desc = "Send visual selection to REPL" })
		end,
	},
	{ "sindrets/diffview.nvim" },

	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				-- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
				-- Set to false if you still want to use netrw.
				default_file_explorer = true,
				-- Id is automatically added at the beginning, and name at the end
				-- See :help oil-columns
				columns = {
					"icon",
					-- "permissions",
					-- "size",
					-- "mtime",
				},
				-- Buffer-local options to use for oil buffers
				buf_options = {
					buflisted = false,
					bufhidden = "hide",
				},
				-- Window-local options to use for oil buffers
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
				-- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
				delete_to_trash = false,
				-- Skip the confirmation popup for simple operations
				skip_confirm_for_simple_edits = false,
				-- Change this to customize the command used when deleting to trash
				trash_command = "trash-put",
				-- Selecting a new/moved/renamed file or directory will prompt you to save changes first
				prompt_save_on_select_new_entry = true,
				-- Oil will automatically delete hidden buffers after this delay
				-- You can set the delay to false to disable cleanup entirely
				-- Note that the cleanup process only starts when none of the oil buffers are currently displayed
				cleanup_delay_ms = 2000,
				-- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
				-- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
				-- Additionally, if it is a string that matches "actions.<name>",
				-- it will use the mapping at require("oil.actions").<name>
				-- Set to `false` to remove a keymap
				-- See :help oil-actions for a list of all available actions
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
				},
				-- Set to false to disable all of the above keymaps
				use_default_keymaps = true,
				view_options = {
					-- Show files and directories that start with "."
					show_hidden = false,
					-- This function defines what is considered a "hidden" file
					is_hidden_file = function(name, bufnr)
						return vim.startswith(name, ".")
					end,
					-- This function defines what will never be shown, even when `show_hidden` is set
					is_always_hidden = function(name, bufnr)
						return false
					end,
					sort = {
						-- sort order can be "asc" or "desc"
						-- see :help oil-columns to see which columns are sortable
						{ "type", "asc" },
						{ "name", "asc" },
					},
				},
				-- Configuration for the floating window in oil.open_float
				float = {
					-- Padding around the floating window
					padding = 2,
					max_width = 0,
					max_height = 0,
					border = "rounded",
					win_options = {
						winblend = 0,
					},
					-- This is the config that will be passed to nvim_open_win.
					-- Change values here to customize the layout
					override = function(conf)
						return conf
					end,
				},
				-- Configuration for the actions floating preview window
				preview = {
					-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
					-- min_width and max_width can be a single value or a list of mixed integer/float types.
					-- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
					max_width = 0.9,
					-- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
					min_width = { 40, 0.4 },
					-- optionally define an integer/float for the exact width of the preview window
					width = nil,
					-- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
					-- min_height and max_height can be a single value or a list of mixed integer/float types.
					-- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
					max_height = 0.9,
					-- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
					min_height = { 5, 0.1 },
					-- optionally define an integer/float for the exact height of the preview window
					height = nil,
					border = "rounded",
					win_options = {
						winblend = 0,
					},
				},
				-- Configuration for the floating progress window
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
}
