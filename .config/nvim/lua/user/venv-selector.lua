-- Detect project root (prefer Git root, fallback to CWD)
local function project_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_root and git_root ~= "" then return git_root end
  return vim.loop.cwd()
end
local ROOT = project_root()

require("venv-selector").setup({
  options = {
    enable_default_searches = true,
    fd_binary_name = "fd",
    search_timeout = 5,
    debug = false,
  },
  search = {
    -- keep workspace off if it's slow for you
    workspace = false,

    -- ✅ include hidden dirs so `.venv` is discovered
    cwd = {
      -- was: ... -I ...
      command = "fd '/(\\.venv|venv)/(bin|Scripts)/(python|python3)(\\.exe)?$' "
        .. "$CWD --full-path --color=never -H -a -L",
    },

    -- (optional) explicitly scan project root (Git root) for .venv
    project_root = {
      command = "fd '/(\\.venv|venv)/(bin|Scripts)/(python|python3)(\\.exe)?$' "
        .. ROOT .. " --full-path --color=never -H -a -L",
    },

    -- conda envs (unchanged)
    conda_envs = (function()
      local home = os.getenv("HOME") or ""
      local conda_root
      if vim.fn.executable("conda") == 1 then
        conda_root = vim.fn.trim(vim.fn.system("conda info --base"))
      elseif vim.loop.fs_stat(home .. "/opt/anaconda3") then
        conda_root = home .. "/opt/anaconda3"
      elseif vim.loop.fs_stat(home .. "/miniconda") then
        conda_root = home .. "/miniconda"
      end
      if conda_root then
        local conda_envs_path = conda_root .. "/envs"
        return {
          command = "fd '/(bin|Scripts)/(python|python3)(\\.exe)?$' "
            .. conda_envs_path .. " --full-path --color=never -H -a -L",
          type = "anaconda",
        }
      end
    end)(),
  },
})

vim.keymap.set("n", "<Leader>vs", ":VenvSelect<CR>", { noremap = true, silent = true })
