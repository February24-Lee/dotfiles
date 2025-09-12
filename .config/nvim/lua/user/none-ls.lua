local null_ls = require("null-ls")

pcall(function()
  require("mason-null-ls").setup({
    ensure_installed = {
      "stylua",     -- Lua formatter
      "prettier",   -- Web formatter 
      "shfmt",      -- Shell formatter
      "shellcheck", -- Shell linter
    },
    automatic_installation = true,
  })
end)

null_ls.setup({
  sources = {
    -- Lua
    null_ls.builtins.formatting.stylua,

    -- Shell
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.formatting.shfmt,

    -- Web 
    null_ls.builtins.formatting.prettier,
  },
})
