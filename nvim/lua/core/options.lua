vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.o.exrc = false -- can be toggled off in that file to stop it from searching further
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.hlsearch = true
vim.opt.inccommand = "split"
vim.opt.scrolloff = 20
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.confirm = true
vim.opt.virtualedit = "block"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.wo.number = true
vim.o.mouse = "a"
vim.opt.cpoptions:append("I")
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = "yes"
vim.wo.relativenumber = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = "menu,preview,noselect"
vim.o.termguicolors = true

vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0

vim.diagnostic.config({
  virtual_lines = true,
})
