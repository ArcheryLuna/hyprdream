return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		lazy = false,
		priority = 1000,
		-- neo-tree will lazily load itself
		---@module "neo-tree"
		---@type neotree.Config
		opts = {
			close_if_last_window = true,
			popup_border_style = "NC",
			enable_git_status = true,
			enable_diagnostics = true,
			open_files_using_relative_paths = false,
			sort_case_insensitive = true,
			sort_function = nil,
			bind_to_cwd = true,
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)

			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			-- Open Neotree
			vim.keymap.set("n", "<leader>n", "<cmd> Neotree toggle<CR>", {
				desc = "Open Neotree on the left",
			})
		end,
	},
	--[[
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		--- @module "nvim-tree"
		--- @type nvim-tree.setup
		opts = {
			filters = { dotfiles = false },
			disable_netrw = true,
			hijack_cursor = true,
			sync_root_with_cwd = true,
			reload_on_bufenter = true,
			update_focused_file = {
				enable = true,
				update_root = true,
			},
			view = {
				width = 30,
				preserve_window_proportions = true,
			},
			renderer = {
				root_folder_label = false,
				highlight_git = true,
				indent_markers = { enable = true },
				icons = {
					git = { unmerged = "" },
				},
			},
		},
		config = function(_, opts)
			require("nvim-tree").setup(opts)

			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			vim.keymap.set("n", "<leader>n", "<cmd> NvimTreeToggle <CR>", { desc = "Open Neovim Tree" })
		end,
	},
	--]]
}
