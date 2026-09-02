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

      -- The `main` branch no longer wires up highlighting; Neovim only starts it
      -- from its bundled ftplugins (lua, vim, markdown, ...). Start it ourselves
      -- for any filetype whose parser actually loads, so the parsers above get used.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
        callback = function(ev)
          if vim.treesitter.highlighter.active[ev.buf] then
            return
          end
          local lang = vim.treesitter.language.get_lang(ev.match)
          if lang and vim.treesitter.language.add(lang) then
            pcall(vim.treesitter.start, ev.buf, lang)
          end
        end,
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
