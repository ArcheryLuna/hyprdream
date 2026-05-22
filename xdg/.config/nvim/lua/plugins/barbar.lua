return {
	"romgrk/barbar.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local opts = { noremap = true, silent = true }

		-- Move to previous/next

		vim.keymap.set("n", "<leader>,", vim.cmd.BufferPrevious, opts)
		vim.keymap.set("n", "<leader>.", vim.cmd.BufferNext, opts)

		-- Re-order to previous/next

		vim.keymap.set("n", "<leader><", vim.cmd.BufferMovePrevious, opts)
		vim.keymap.set("n", "<leader>>", vim.cmd.BufferMoveNext, opts)

		vim.keymap.set("n", "<leader>bp", vim.cmd.BufferPin, opts)

		-- Close buffer

		vim.keymap.set("n", "<leader>cl", vim.cmd.BufferClose, opts)
		-- Wipeout buffer
		--                 :BufferWipeout
		-- Close commands
		--                 :BufferCloseAllButCurrent
		--                 :BufferCloseAllButPinned
		--                 :BufferCloseAllButCurrentOrPinned
		--                 :BufferCloseBuffersLeft
		--                 :BufferCloseBuffersRight
		-- Magic buffer-picking mode

		vim.keymap.set("n", "<C-s>", vim.cmd.BufferPick, opts)
		-- Sort automatically by...

		vim.keymap.set("n", "<Space>bd", vim.cmd.BufferOrderByDirectory, opts)
		vim.keymap.set("n", "<Space>bl", vim.cmd.BufferOrderByLanguage, opts)
		vim.keymap.set("n", "<Space>bw", vim.cmd.BufferOrderByWindowNumber, opts)
		-- Other:
		-- :BarbarEnable - enables barbar (enabled by default)
		-- :BarbarDisable - very bad command, should never be used
		require("barbar").setup({

			-- Enable/disable animations
			animation = true,

			-- Automatically hide the tabline when there are this many buffers left.
			-- Set to any value >=0 to enable.
			auto_hide = false,

			-- Enable/disable current/total tabpages indicator (top right corner)
			tabpages = true,

			-- Enables/disable clickable tabs
			--  - left-click: go to buffer
			--  - middle-click: delete buffer
			clickable = true,

			-- A buffer to this direction will be focused (if it exists) when closing the current buffer.
			-- Valid options are 'left' (the default), 'previous', and 'right'
			focus_on_close = "left",

			-- Sets the maximum padding width with which to surround each tab
			maximum_padding = 1,

			-- Sets the minimum padding width with which to surround each tab
			minimum_padding = 1,

			-- Sets the maximum buffer name length.
			maximum_length = 30,

			-- Sets the minimum buffer name length.
			minimum_length = 0,

			-- Set the filetypes which barbar will offset itself for
			sidebar_filetypes = {
				-- Use the default values: {event = 'BufWinLeave', text = '', align = 'left'}
				NvimTree = true,
				-- Or, specify the text used for the offset:
				undotree = {
					text = "undotree",
					align = "center", -- *optionally* specify an alignment (either 'left', 'center', or 'right')
				},
				-- Or, specify the event which the sidebar executes when leaving:
				["neo-tree"] = { event = "BufWipeout" },
				-- Or, specify all three
				Outline = { event = "BufWinLeave", text = "symbols-outline", align = "right" },
			},
			-- sorting options
			sort = {
				-- tells barbar to ignore case differences while sorting buffers
				ignore_case = true,
			},
		})
	end,
}
