--
vim.g.python3_host_prog = vim.fn.expand("$HOME/miniconda/bin/python")

-- Basic settings
vim.lsp.log.set_level(vim.log.levels.DEBUG)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hidden = true
vim.opt.wrapscan = true
vim.opt.syntax = "on"

-- Transparent background
vim.cmd [[
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NonText guibg=NONE ctermbg=NONE
    highlight Folded guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE
]]

-- Ensure Lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/
require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
})

-- Load user configuration modules
require("user.mason")
require("user.lsp")
require("user.none-ls")
require("user.venv-selector")
require("user.telescope")

-- Python auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.py" },
    callback = function(ev)
        vim.lsp.buf.code_action({
            context = { only = { "source.fixAll" } },
            apply = true,
        })
        vim.lsp.buf.format({
            bufnr = ev.buf,
            timeout_ms = 4000,
            filter = function(client)
                return client.name == "ruff" or client.name == "null-ls"
            end,
        })
    end,
})

-- Key mappings
-- LSP rename
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })

-- File explorer
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer", silent = true })
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>", { desc = "Focus File Explorer", silent = true })

-- Tagbar
vim.keymap.set("n", "<F8>", "<cmd>TagbarToggle<CR>", { desc = "Toggle Tagbar", silent = true })

-- Telescope
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Find files", silent = true })
vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<CR>", { desc = "Live grep", silent = true })

-- Insert mode escape
vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape" })

-- Molten (Jupyter) key mappings
vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", { desc = "Initialize Molten", silent = true })
vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { desc = "Evaluate Operator", silent = true })
vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { desc = "Evaluate Line", silent = true })
vim.keymap.set("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Evaluate Visual", silent = true })
vim.keymap.set("n", "<leader>mo", ":MoltenShowOutput<CR>", { desc = "Show Output", silent = true })
vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { desc = "Hide Output", silent = true })
vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "Delete Molten Cell", silent = true })

-- Image preview with viu
vim.keymap.set("n", "<leader>ip", ":!viu -w 80 %<CR>", { desc = "Preview Image" })
