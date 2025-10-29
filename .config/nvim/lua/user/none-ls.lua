local null_ls = require("null-ls")

pcall(function()
  require("mason-null-ls").setup({
    ensure_installed = {
      "stylua",     -- Lua formatter
      "prettier",   -- Web formatter 
      "shfmt",      -- Shell formatter
      "shellcheck", -- Shell linter
      "ruff",       -- Python linter & formatter
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

    -- Web 
    null_ls.builtins.formatting.prettier,

    -- Python (using ruff LSP instead of none-ls builtins)
  },
})
