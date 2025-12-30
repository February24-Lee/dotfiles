-- TypeScript/JavaScript LSP configuration

vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
  },
})

vim.lsp.config("eslint", {
  settings = {
    workingDirectories = { mode = "auto" },
  },
})

-- Format on save for JS/TS files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.vue", "*.json", "*.css", "*.scss", "*.html" },
  callback = function(ev)
    -- ESLint fix all
    vim.lsp.buf.code_action({
      context = { only = { "source.fixAll.eslint" } },
      apply = true,
    })

    -- Format with prettier (via null-ls) or eslint
    vim.lsp.buf.format({
      bufnr = ev.buf,
      timeout_ms = 3000,
      filter = function(client)
        return client.name == "null-ls" or client.name == "eslint"
      end,
    })
  end,
})
