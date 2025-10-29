-- Detect fd binary (Ubuntu often ships it as `fdfind`)
local FD = (vim.fn.executable("fd") == 1) and "fd" or "fdfind"

require("venv-selector").setup({
  -- Look for virtualenv folders with these names
  name = { ".venv", "venv" },

  -- Search up to N parent directories from the current working directory
  parents = 2,

  -- Core options
  options = {
    fd_binary_name = FD,       -- important: use `fdfind` when `fd` is unavailable
    enable_default_searches = true, -- rely on plugin's built-in searches
    search_timeout = 5,        -- seconds; increase if your repo is huge
    debug = false,             -- set true temporarily to inspect :messages output
  },

  -- Keep workspace-wide search off if it's slow on your machine
  search = {
    workspace = false,
    -- We don't override `cwd`/`project_root` commands here to avoid brittle quoting/regex issues.
    -- The built-in search works well for standard .venv layouts.
  },
})

-- Optional: keymap to open the venv picker quickly
vim.keymap.set("n", "<Leader>vs", "<cmd>VenvSelect<CR>", { noremap = true, silent = true })
