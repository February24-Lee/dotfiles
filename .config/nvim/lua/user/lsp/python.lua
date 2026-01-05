vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        -- pytest conftest fixture 인식
        extraPaths = {},
        diagnosticSeverityOverrides = {
          reportUnknownParameterType = "none",
          reportUnknownArgumentType = "none",
        },
        -- pytest stub 활성화
        stubPath = "typings",
      },
    },
  },
})

vim.lsp.config("ruff", {})
