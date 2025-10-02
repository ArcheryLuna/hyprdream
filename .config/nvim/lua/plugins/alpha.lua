return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"BlakeJC94/alpha-nvim-fortune",
	},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		local fortune = require("alpha.fortune")

		-- Set header
		dashboard.section.header.val = {
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                     ]],
			[[       ████ ██████           █████      ██                     ]],
			[[      ███████████             █████                             ]],
			[[      █████████ ███████████████████ ███   ███████████   ]],
			[[     █████████  ███    █████████████ █████ ██████████████   ]],
			[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
			[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
			[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                       ]],
		}

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("n", "  > New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("f", "  > Find file", ":Telescope find_files<CR>"),
			dashboard.button("o", "  > Recent", ":Telescope oldfiles<CR>"),
			dashboard.button("q", "󰩈  > Quit NVIM", ":qa<CR>"),
		}

		dashboard.section.footer.val = fortune()

		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[
                autocmd FileType alpha setlocal nofoldenable
                ]])
	end,
}
