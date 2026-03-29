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
      require("nvim-treesitter").setup()
      -- Install parsers
      local parsers = { "lua", "python", "typescript", "tsx", "javascript", "json", "css", "html", "markdown", "markdown_inline" }
      local installed = require("nvim-treesitter").get_installed()
      local to_install = vim.tbl_filter(function(p)
        return not vim.tbl_contains(installed, p)
      end, parsers)
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end
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
