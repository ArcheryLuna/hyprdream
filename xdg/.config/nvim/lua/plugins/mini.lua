return {
	{
		"echasnovski/mini.statusline",
		version = false,
		dependencies = {
			"echasnovski/mini.icons",
		},
		config = function()
			require("mini.statusline").setup({})
		end,
	},
}
