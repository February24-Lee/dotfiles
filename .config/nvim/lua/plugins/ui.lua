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
      local api = require("nvim-tree.api")

      local function on_attach(bufnr)
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- 기본 매핑 적용
        api.config.mappings.default_on_attach(bufnr)

        -- 커스텀 매핑
        vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
      end

      require("nvim-tree").setup({
        on_attach = on_attach,
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
