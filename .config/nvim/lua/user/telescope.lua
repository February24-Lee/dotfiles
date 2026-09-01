-- Telescope configuration
require("telescope").setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/",
      ".next/",
      "__pycache__/",
      "%.pyc",
    },
  },
})

-- Peek a definition in the preview pane instead of jumping to it. jump_type
-- "never" is required: telescope jumps straight to a lone result otherwise,
-- which is the whole thing this mapping exists to avoid.
vim.keymap.set("n", "gp", function()
  require("telescope.builtin").lsp_definitions({ jump_type = "never" })
end, { desc = "Peek definition" })
