return {
  -- Auto-tag closing for React/HTML
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = {
          "html", "javascript", "typescript",
          "javascriptreact", "typescriptreact"
        }
      })
    end,
  },

  -- Indentation guide
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "|" },
      })
    end,
  },

  -- JSON Schema Store
  "b0o/schemastore.nvim",
}
