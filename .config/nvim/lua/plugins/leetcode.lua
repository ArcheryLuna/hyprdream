return {
	"kawre/leetcode.nvim",
	build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
	dependencies = {
		-- include a picker of your choice, see picker section for more details
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	opts = {
		arg = "leetcode.nvim",
		lang = "ts",
		cn = {
			enabled = false,
			translator = true,
			translator_problems = true,
		},
		storage = {
			home = vim.fn.stdpath("data") .. "/leetcode",
			cache = vim.fn.stdpath("cache") .. "/leetcode",
		},
		plugins = {
			non_standalone = false,
		},
	},
}
