-- 🌟 Basic settings
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true      -- Show relative line numbers
vim.opt.tabstop = 4                -- Set tab width
vim.opt.shiftwidth = 4             -- Indentation width
vim.opt.expandtab = true           -- Convert tabs to spaces
vim.opt.ignorecase = true          -- Ignore case in search
vim.opt.smartcase = true           -- Case-sensitive when uppercase is used
vim.opt.hidden = true              -- Allow switching buffers without saving
vim.opt.wrapscan = true            -- Wrap search results
vim.opt.syntax = "on"              -- Enable syntax highlighting

-- 🌟 Enable transparent background
vim.cmd [[
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NonText guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
    highlight Folded guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE
]]

-- 🌟 Ensure Lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- 🌟 LSP (Python support)
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    -- 🌟 Auto-completion & Snippets
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",

    -- 🌟 Navigation & File Search
    "nvim-telescope/telescope.nvim",
    "preservim/tagbar",

    -- 🌟 fzf (File search & code search)
    {
        "junegunn/fzf",
        build = "./install --bin",  -- Ensure fzf binary installation
    },
    "junegunn/fzf.vim",

    -- 🌟 Code highlighting & File explorer
    "sheerun/vim-polyglot",
    "preservim/nerdtree",
})

-- 🌟 Configure LSP (Pyright)
local lspconfig = require("lspconfig")
lspconfig.pyright.setup({})

-- 🌟 Auto-completion setup (nvim-cmp)
local cmp = require("cmp")
cmp.setup({
    mapping = {
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
})

-- 🌟 Key mappings
vim.api.nvim_set_keymap("n", "<F8>", ":TagbarToggle<CR>", { noremap = true, silent = true })  -- Toggle ctags view
vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope find_files<CR>", { noremap = true, silent = true }) -- File search
vim.api.nvim_set_keymap("n", "<Leader>g", ":Telescope live_grep<CR>", { noremap = true, silent = true }) -- Code search
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true })  -- `jj` -> Escape
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true })  -- `jk` -> Escape

-- 🌟 LSP key mappings
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })  -- Go to Definition
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = true })  -- Find References
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })  -- Show documentation
vim.api.nvim_set_keymap("n", "<Leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", { noremap = true, silent = true })  -- Code action
