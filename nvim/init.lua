require("core.lze_setup")

require("core.options")
require("core.keymaps")
require("core.autocmds")

require("plugins.ui")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.tools")
require("plugins.mini")

vim.cmd.colorscheme("kanagawa-paper")
-- vim.o.background = "dark"
