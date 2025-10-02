return {
	"laytan/cloak.nvim",
	opts = {
		enabled = true,
		cloak_character = "*",
		highlighted_group = "Comment",
		patterns = {
			{
				file_pattern = {
					".env*",
					".npmrc",
				},
				cloak_pattern = "=.+",
			},
		},
	},
}
