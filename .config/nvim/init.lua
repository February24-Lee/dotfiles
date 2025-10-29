-- 🌟 Basic settings
vim.lsp.log.set_level(vim.log.levels.DEBUG)    -- Enable LSP debug logging
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
-- test code
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
    {
      "nvimtools/none-ls.nvim",
      dependencies = { "gbprod/none-ls-shellcheck.nvim" },
    },
    -- 🌟 Virtual Environment Selector
    {
        "linux-cultist/venv-selector.nvim",
        branch="main",
    },

    -- 🌟 Jupyter Integration (molten-nvim)
    {
        "benlubas/molten-nvim",
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        init = function()
            vim.g.molten_output_win_max_height = 20
            vim.g.molten_auto_open_output = false
            vim.g.molten_wrap_output = true
            vim.g.molten_virt_text_output = true
        end,
    },

    -- 🌟 Navigation & File Search
    "nvim-telescope/telescope.nvim",
    "preservim/tagbar",
    "SmiteshP/nvim-navic",

    -- 🌟 File Explorer
    "nvim-tree/nvim-tree.lua",

    -- 🌟 Statusline & Git
    "nvim-lualine/lualine.nvim",
    "lewis6991/gitsigns.nvim",
    "lukas-reineke/indent-blankline.nvim",
    "b0o/schemastore.nvim",
    {
      "sindrets/diffview.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },  -- optional for icons
      cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
      config = function()
        require("diffview").setup({
          use_icons = true,
          view = {
            default = {
              layout = "diff2_horizontal",  -- 예: 가로 두 패널
            },
            merge_tool = {
              layout = "diff3_horizontal",
              disable_diagnostics = true,    -- merge중 diagnostics 방해되면 끄기
            },
          },
          file_panel = {
            listing_style = "tree",
            win_config = {
              position = "left",
              width = 35,
            },
          },
          keymaps = {
            view = {
              ["<tab>"] = require("diffview.actions").select_next_entry,
              ["<s-tab>"] = require("diffview.actions").select_prev_entry,
            },
          },
        })
      end,
    },
    {
      "NeogitOrg/neogit",
        dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim"        -- optional - Diff Integration
        }
    },
})

-- 🌟 Mason & LSP auto setup
-- 🌟 Linter & Formatter 
require("user.mason")
require("user.lsp")
require("user.none-ls")
require("user.venv-selector")

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py" },
  callback = function(ev)
    -- Auto-fix with ruff
    vim.lsp.buf.code_action({
      context = { only = { "source.fixAll" } },
      apply = true,
    })
    
    -- Format with ruff
    vim.lsp.buf.format({
      bufnr = ev.buf,
      timeout_ms = 4000,
      filter = function(client)
        return client.name == "ruff" or client.name == "null-ls"
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
-- local home = os.getenv("HOME") or ""
-- local conda_root = nil
--
-- if vim.fn.executable("conda") == 1 then
--   -- If conda is available in PATH, retrieve its base directory using "conda info --base"
--   local conda_base = vim.fn.system("conda info --base")
--   conda_root = vim.fn.trim(conda_base)
-- elseif vim.loop.fs_stat(home .. "/opt/anaconda3") then
--   -- Use $HOME/opt/anaconda3 if it exists
--   conda_root = home .. "/opt/anaconda3"
-- elseif vim.loop.fs_stat(home .. "/miniconda") then
--   -- Fallback to $HOME/miniconda if none of the above conditions match
--   conda_root = home .. "/miniconda"
-- end

-- Use conda_root/envs as the environments path if conda_root is determined
-- local conda_envs_path = conda_root and (conda_root .. "/envs") or nil
-- Virtual Environment Selector configuration
-- require("venv-selector").setup({
--     parents = 0,  -- Only search current directory
--     name = { ".venv", "venv" },
--     fd_binary_name = "fd",
--     search = false,  -- Disable auto workspace search
--     search_workspace = false,
--     search_paths = vim.tbl_filter(function(path)
--         return path ~= nil
--     end, {
--         os.getenv("CONDA_PREFIX"),
--         conda_envs_path,
--     }),
--     anaconda_base_path = conda_envs_path,
--     enable_debug = false,
-- })
-- vim.api.nvim_set_keymap("n", "<Leader>vs", ":VenvSelect<CR>", { noremap = true, silent = true })

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
-- LSP rename
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })

-- File explorer
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer", silent = true })
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>",  { desc = "Focus File Explorer",  silent = true })

-- Tagbar
vim.keymap.set("n", "<F8>", "<cmd>TagbarToggle<CR>", { desc = "Toggle Tagbar", silent = true })

-- Telescope
vim.keymap.set("n", "<C-p>",     "<cmd>Telescope find_files<CR>", { desc = "Find files",  silent = true })
vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<CR>",  { desc = "Live grep",   silent = true })

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
