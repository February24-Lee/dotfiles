local lspconfig = require("lspconfig")

lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    print("Pyright attached to buffer " .. bufnr)
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})
