return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			defaults = {
				prompt_prefix = "🔍 ",
				selection_caret = "➜ ",
				entry_prefix = "  ",
				initial_mode = "insert",
				layout_config = {
					horizontal = { preview_width = 0.6 },
					vertical = { width = 0.8 },
				},
				file_ignore_patterns = {
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
			},
		},
		config = function(_, opts)
			require("telescope").setup(opts)
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {
				desc = "[F]ind [F]iles",
			})
			vim.keymap.set("n", "<C-f>", builtin.git_files, {
				desc = "Find files in git repo",
			})
			vim.keymap.set("n", "<leader>fs", function()
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end, {
				desc = "[F]ind [S]tring",
			})

			vim.keymap.set("n", "<leader>ns", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, {
				desc = "[N]eovim [S]earch files",
			})
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
