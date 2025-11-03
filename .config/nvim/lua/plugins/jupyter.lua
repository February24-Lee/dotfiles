return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    ft = { "python", "markdown", "quarto", "rmd" },
    config = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          vim.b.molten_cell_delimiter = "# %%"
        end,
      })

      local map = vim.keymap.set
      map("n", "<leader>mi", ":MoltenInit python3<CR>", { desc = "Molten: 커널 시작" })
      map("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { desc = "Molten: 현재 줄 실행" })
      map("v", "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>", { desc = "Molten: 비주얼 실행" })
      map("n", "<leader>mc", ":MoltenEvaluateCell<CR>", { desc = "Molten: 현재 셀 실행" })
      map("n", "<leader>mo", ":MoltenEnterOutput<CR>", { desc = "Molten: 출력 포커스" })
      map("n", "<leader>mk", ":MoltenRestart<CR>", { desc = "Molten: 재시작" })
      map("n", "<leader>mq", ":MoltenShutdown<CR>", { desc = "Molten: 종료" })
      map("n", "<leader>mx", ":MoltenDelete<CR>", { desc = "Molten: 마지막 출력 삭제" })
    end,
  },
}
