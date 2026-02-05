return {
  -- LSP Config
  "neovim/nvim-lspconfig",

  -- Mason (Language Server Installer)
  {
    "williamboman/mason.nvim",
    version = "*",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    version = "*",
    dependencies = { "neovim/nvim-lspconfig" },
  },

  -- Treesitter (Syntax Highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "typescript", "tsx", "javascript", "json", "css", "html" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- None-ls (Linter & Formatter)
  { "nvimtools/none-ls.nvim" },
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = { "nvimtools/none-ls.nvim", "williamboman/mason.nvim" },
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "gbprod/none-ls-shellcheck.nvim" },
  },
}
