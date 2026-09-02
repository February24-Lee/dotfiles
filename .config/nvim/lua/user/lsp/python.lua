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

-- ruff lives outside mason (`uv tool install ruff`), so mason-lspconfig's
-- automatic_enable never picks it up — enable it here when the binary is on PATH.
if vim.fn.executable("ruff") == 1 then
  vim.lsp.enable("ruff")
end
