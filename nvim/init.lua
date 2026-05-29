-- Neovim Entry Point
-- This file orchestrates the loading of core settings, keymaps, and plugins.

-- Core configurations
require("core.lze_setup")
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Plugin modules
require("plugins.ui")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.tools")
require("plugins.mini")

-- Finalize UI
vim.cmd.colorscheme("kanagawa-paper")
