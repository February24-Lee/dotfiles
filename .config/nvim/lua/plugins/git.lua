return {
  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation between hunks
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Next hunk" })

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Previous hunk" })

          -- Hunk actions
          map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
          map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage selected hunk" })
          map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset selected hunk" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
          map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
          map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "Diff this ~" })

          -- Toggle options
          map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
          map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle deleted" })
        end,
      })
    end,
  },

  -- Diff view
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>do", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
      { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
      { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
      { "<leader>dH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (all)" },
    },
    config = function()
      require("diffview").setup({
        use_icons = true,
        view = {
          default = {
            layout = "diff2_horizontal",
          },
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
          },
        },
        file_panel = {
          listing_style = "tree",
          win_config = {
            position = "left",
            width = 35,
          },
        },
        keymaps = {
          view = {
            ["<tab>"] = require("diffview.actions").select_next_entry,
            ["<s-tab>"] = require("diffview.actions").select_prev_entry,
          },
        },
      })
    end,
  },

  -- Neogit (magit-style git interface)
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>ng", "<cmd>Neogit<cr>", desc = "Open Neogit" },
      { "<leader>nc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
      { "<leader>np", "<cmd>Neogit push<cr>", desc = "Neogit push" },
      { "<leader>nl", "<cmd>Neogit pull<cr>", desc = "Neogit pull" },
    },
    config = function()
      require("neogit").setup({
        integrations = {
          diffview = true,
          telescope = true,
        },
        signs = {
          section = { "", "" },
          item = { "", "" },
          hunk = { "", "" },
        },
      })
    end,
  },
}
