require("mason").setup({
  PATH = "prepend", -- Mason bin을 PATH에 추가
})

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  ensure_installed = {
    -- Python
    "pyright",
    "ruff",
    -- Lua
    "lua_ls",
    -- Shell
    "bashls",
    -- JSON
    "jsonls",
    -- TypeScript/JavaScript
    "ts_ls",
    "eslint",
  },
  automatic_enable = true,
})

local lspconfig = require("lspconfig")

local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = vim.lsp.protocol.make_client_capabilities()
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local on_attach = function(_, bufnr)
  local o = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
  vim.keymap.set("n", "K",  vim.lsp.buf.hover, o)
  vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, o)
  vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, o)
  vim.keymap.set("n", "<Leader>f", function() vim.lsp.buf.format({ async = true }) end, o)
  -- 분할 창으로 정의 열기
  vim.keymap.set("n", "gvd", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", o)
  vim.keymap.set("n", "gsd", "<cmd>split | lua vim.lsp.buf.definition()<cr>", o)
  vim.keymap.set("n", "gtd", "<cmd>tab split | lua vim.lsp.buf.definition()<cr>", o)
end

vim.lsp.config("*", {
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      diagnostics = { globals = { "vim" } },
    },
  },
})

vim.lsp.config("jsonls", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.config("ruff", {
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    settings = {
      args = {}, 
    },
  },
})
