return {
  -- Virtual Environment Selector
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
  },

  -- Jupyter Integration (molten-nvim)
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
    end,
  },
}
