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
    -- 🌟 LSP & Mason
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    -- 🌟 Auto-completion & Snippets
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",

    -- 🌟 Linter & Formatter (null-ls)
    "jose-elias-alvarez/null-ls.nvim",

    -- 🌟 Virtual Environment Selector
    {
        "linux-cultist/venv-selector.nvim",
        branch="regexp",
    },

    -- 🌟 Navigation & File Search
    "nvim-telescope/telescope.nvim",
    "preservim/tagbar",

    -- 🌟 File Explorer
    "nvim-tree/nvim-tree.lua",

    -- 🌟 Statusline & Git
    "nvim-lualine/lualine.nvim",
    "lewis6991/gitsigns.nvim",
    "lukas-reineke/indent-blankline.nvim",
})

-- 🌟 Mason & LSP auto setup
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "pyright" },  -- Install Pyright automatically
    automatic_installation = true,
})

local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)  -- Go to definition
    vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)  -- Find references
    vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)  -- Show documentation
    vim.keymap.set("n", "<Leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)  -- Code action
    vim.keymap.set("n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)  -- Rename symbol
    vim.keymap.set("n", "<Leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)  -- Format code
end

require("mason-lspconfig").setup_handlers({
    function(server_name)
        lspconfig[server_name].setup({
            on_attach = on_attach
        })
    end,
})

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

-- 🌟 Linter & Formatter 
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.flake8,  -- Linter (syntax checking, unused imports)
        null_ls.builtins.formatting.black,    -- Formatter (PEP8 auto-formatting)
        null_ls.builtins.formatting.isort,    -- Formatter (auto-sort imports)
    },
})

-- 🌟 Virtual Environment Selector
require("venv-selector").setup({
    -- Automatically find virtual environments in workspace
    parents = 2,  -- Search up to 2 parent directories for virtualenvs
    name = { "venv", ".venv", "env", "pyenv" },  -- Search for these names
    fd_binary_name = "fd",  -- Ensure 'fd' is used for searching
    search_paths = {
        os.getenv("CONDA_PREFIX"),                 -- Currently active Conda environment
        os.getenv("HOME") .. "/miniconda3/envs",   -- Miniconda environments path
        os.getenv("HOME") .. "/.conda/envs",       -- Alternative Conda path
    },
    anaconda_base_path = os.getenv("HOME") .. "/miniconda3/envs",  -- Conda environments path
    enable_debug = true,  -- Set to true if you want to debug
})
vim.api.nvim_set_keymap("n", "<Leader>vs", ":VenvSelect<CR>", { noremap = true, silent = true })

-- 🌟 File Explorer (nvim-tree)
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- 🌟 Statusline (lualine)
require("lualine").setup({
    options = { theme = "gruvbox" }
})

-- 🌟 Git signs
require("gitsigns").setup()

-- 🌟 Indentation guide
require("ibl").setup({
    indent = { char = "|" },
})

-- 🌟 Key mappings
vim.api.nvim_set_keymap("n", "<F8>", ":TagbarToggle<CR>", { noremap = true, silent = true })  -- Toggle ctags view
vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope find_files<CR>", { noremap = true, silent = true }) -- File search
vim.api.nvim_set_keymap("n", "<Leader>g", ":Telescope live_grep<CR>", { noremap = true, silent = true }) -- Code search
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true })  -- `jj` -> Escape
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true })  -- `jk` -> Escape
