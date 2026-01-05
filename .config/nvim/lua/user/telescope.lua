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
