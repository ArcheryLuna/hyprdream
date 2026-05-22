-- ~/.config/nvim/lua/plugins/lsp.lua
return {
	---------------------------------------------------------------------------
	-- Mason ------------------------------------------------------------------
	---------------------------------------------------------------------------
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		opts = {
			path = "skip",

			ui = {
				package_pending = " ",
				package_installed = " ",
				package_uninstalled = " ",
			},

			max_concurrent_installers = 20,
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = "williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"pyright",
				"lua_ls",
				"ts_ls",
				"html",
				"cssls",
				"clangd",
				"cmake",
				"eslint",
				"tailwindcss",
				"rust_analyzer",
				"biome",
			},
		},
	},
	---------------------------------------------------------------------------
	-- mason-null-ls ---------------------------------------------------------
	---------------------------------------------------------------------------
	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
		opts = {
			ensure_installed = {
				"black",
				"eslint",
				"mypy",
				"ruff",
				"prettier",
				"debugpy",
				"stylua",
				"eslint_d",
				"biome",
			},
			automatic_installation = true,
			methods = {
				diagnostics = true,
				formatting = true,
				code_actions = true,
				completion = true,
				hover = true,
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
	},
	---------------------------------------------------------------------------
	-- LSP‑Zero ---------------------------------------------------------------
	---------------------------------------------------------------------------
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v4.x",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			-- completion
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"L3MON4D3/LuaSnip",
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			local lsp = require("lsp-zero")
			lsp.extend_lspconfig()
			lsp.set_sign_icons({})
			lsp.on_attach(function(_, bufnr)
				local map = vim.keymap.set
				local o = { buffer = bufnr }
				map("n", "gd", vim.lsp.buf.definition, o)
				map("n", "K", vim.lsp.buf.hover, o)
				map("n", "[d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, o)
				map("n", "]d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, o)
				map("n", "<leader>ca", vim.lsp.buf.code_action, o)
				map("i", "<C-h>", vim.lsp.buf.signature_help, o)
			end)
			vim.lsp.config('lua_ls', lsp.nvim_lua_ls())
			vim.lsp.enable('lua_ls')
			lsp.setup()
		end,
	},

	---------------------------------------------------------------------------
	-- LuaSnip & Snippets -----------------------------------------------------
	---------------------------------------------------------------------------
	-- Explicitly include LuaSnip to configure loaders and build JS regexp
	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
		dependencies = {
			-- Pre‑made community snippets
			"rafamadriz/friendly-snippets",
		},
		config = function()
			-- Load vscode‑style snippets from friendly‑snippets (lazy so startup stays fast)
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	---------------------------------------------------------------------------
	-- nvim‑cmp ---------------------------------------------------------------
	---------------------------------------------------------------------------
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"saadparwaiz1/cmp_luasnip", -- ← NEW: source for LuaSnip snippets
		},
		opts = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			return {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),

					-- Use <Tab> and <S-Tab> to navigate the completion menu or jump in snippets
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- ← NEW: show snippet completions
					{ name = "path" },
					{ name = "buffer" },
				},
			}
		end,
	},

	---------------------------------------------------------------------------
	-- none‑ls + extras -------------------------------------------------------
	---------------------------------------------------------------------------
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim", -- ← NEW
			"jay-babu/mason-null-ls.nvim",
			"VonHeikemen/lsp-zero.nvim",
		},
		opts = function()
			local null_ls = require("null-ls")
			local lsp = require("lsp-zero")
			return {
				sources = {
					null_ls.builtins.formatting.stylua,

					null_ls.builtins.formatting.black,
					null_ls.builtins.diagnostics.mypy.with({
						extra_args = { "--ignore-missing-imports" },
					}),
					require("none-ls.diagnostics.ruff"), -- ← NEW
					null_ls.builtins.formatting.prettier,
				},
				on_attach = function(client, bufnr)
					lsp.on_attach(client)
					if client.supports_method("textDocument/formatting") then
						local aug = vim.api.nvim_create_augroup("LspFormat", { clear = true })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = aug,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ async = false })
							end,
						})
					end
				end,
			}
		end,
	},
}
