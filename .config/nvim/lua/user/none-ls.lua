local null_ls = require("null-ls")

pcall(function()
  require("mason-null-ls").setup({
    ensure_installed = {
      -- Lua
      "stylua",
      -- Shell
      "shfmt",
      "shellcheck",
      -- Python
      "ruff",
      -- Web (JS/TS/CSS/HTML)
      "prettier",
      "eslint_d",
    },
    automatic_installation = true,
  })
end)

null_ls.setup({
  sources = {
    -- Lua
    null_ls.builtins.formatting.stylua,

    -- Shell
    null_ls.builtins.formatting.shfmt,
    require("none-ls-shellcheck.diagnostics"),

    -- Web (JS/TS/CSS/HTML/JSON)
    null_ls.builtins.formatting.prettier.with({
      filetypes = {
        "javascript", "javascriptreact", "typescript", "typescriptreact",
        "vue", "css", "scss", "html", "json", "yaml", "markdown",
      },
    }),

    -- Python (using ruff LSP instead of none-ls builtins)
  },
})
