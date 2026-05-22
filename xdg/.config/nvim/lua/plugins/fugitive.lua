return {
	"tpope/vim-fugitive",
	keys = {
		{ "<leader>gs", vim.cmd.Git, desc = "Open Git Status" },
		{ "<leader>ga", "<cmd>Git add .<cr>", desc = "Git add" },
		{ "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
		{ "<leader>gg", "<cmd>Git push<cr>", desc = "Git push" },
		{ "<leader>gu", "<cmd>Git pull<cr>", desc = "Git push" },
	},
}
