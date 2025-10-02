vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Move selected line(s) up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line(s) down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line(s) up" })

-- vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open's netrw" })

-- Save file
vim.keymap.set("n", "<C-s>", vim.cmd.w, { desc = "Save file" })

-- Keep cursor position when joining lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Scroll and center
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Search and center
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Paste without replacing register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without replacing register" })

-- Yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Escape insert mode
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode with Ctrl+C" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode with jk" })

-- Disable Q
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Q" })

-- Open tmux sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Open tmux sessionizer" })

-- Format buffer with LSP
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer" })

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })

-- Location list navigation
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location list item" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location list item" })

-- Search and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
	desc = "Search and replace word under cursor",
})

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", {
	silent = true,
	desc = "Make current file executable",
})

-- Source current file
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end, {
	desc = "Source this file",
})

-- Unbinding the arrow keys, to get used to hjkl navigation on my newer keyboard
vim.keymap.set({ "n", "i", "v" }, "<Up>", "<nop>", { desc = "Disable Up arrow key" })
vim.keymap.set({ "n", "i", "v" }, "<Down>", "<nop>", { desc = "Disable Down arrow key" })
vim.keymap.set({ "n", "i", "v" }, "<Left>", "<nop>", { desc = "Disable Left arrow key" })
vim.keymap.set({ "n", "i", "v" }, "<Right>", "<nop>", { desc = "Disable Right arrow key" })
