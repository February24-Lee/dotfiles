return {
  -- Telescope (Fuzzy Finder)
  "nvim-telescope/telescope.nvim",

  -- Tagbar (Code Outline)
  "preservim/tagbar",

  -- Breadcrumb
  "SmiteshP/nvim-navic",

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        git = {
          enable = true,
          ignore = false,
        },
        filters = {
          dotfiles = false,
          git_ignored = false,
        },
        update_focused_file = {
          enable = true,
          update_root = false,
        },
      })
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox" },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1,
            }
          }
        }
      })
    end,
  },
}
