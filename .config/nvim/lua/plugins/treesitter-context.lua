return {
  -- Sticky scroll: pin the enclosing class/function signature at the top.
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 4, -- deep nesting otherwise eats the window
      multiline_threshold = 1, -- collapse a long signature to its first line
      separator = "─",
    },
    keys = {
      -- Upstream suggests [c, but gitsigns already owns that for hunk motion.
      { "<leader>ct", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Jump to context" },
    },
  },
}
