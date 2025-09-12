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
    {
      "williamboman/mason.nvim",
      version = "*",
    },
    {
      "williamboman/mason-lspconfig.nvim",
      version = "*",
      dependencies = { "neovim/nvim-lspconfig" },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "lua", "python" }, -- 필요 언어 추가
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },

    -- 🌟 Auto-completion & Snippets
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",

    -- 🌟 Linter & Formatter (none-ls)
    -- "jose-elias-alvarez/none-ls.nvim",
    { "nvimtools/none-ls.nvim" },
    { "jay-babu/mason-null-ls.nvim", dependencies = { "nvimtools/none-ls.nvim", "williamboman/mason.nvim" } },

    -- 🌟 Virtual Environment Selector
    {
        "linux-cultist/venv-selector.nvim",
        branch="main",
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
    "b0o/schemastore.nvim",
})

-- 🌟 Mason & LSP auto setup
-- 🌟 Linter & Formatter 
require("user.mason")
require("user.lsp")
require("user.none-ls")

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py" },
  callback = function(ev)
    vim.lsp.buf.format({
      bufnr = ev.buf,
      timeout_ms = 4000,
      filter = function(client)
        return client.name == "ruff"  
      end,
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
