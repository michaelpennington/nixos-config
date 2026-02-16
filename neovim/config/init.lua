-- NOTE: Welcome to your neovim configuration!
-- The first 100ish lines are setup,
-- the rest is usage of lze and various core plugins!
vim.loader.enable() -- <- bytecode caching
do
  -- Set up a global in a way that also handles non-nix compat
  local ok
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
  if not ok then
    package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
      __call = function (_, default) return default end
    })
    _G.nixInfo = require(vim.g.nix_info_plugin_name)
    -- If you always use the fetcher function to fetch nix values,
    -- rather than indexing into the tables directly,
    -- it will use the value you specified as the default
    -- TODO: for non-nix compat, vim.pack.add in another file and require here.
  end
  nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
  ---@module 'lzextras'
  ---@type lzextras | lze
  nixInfo.lze = setmetatable(require('lze'), getmetatable(require('lzextras')))
  function nixInfo.get_nix_plugin_path(name)
    return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
  end
end
nixInfo.lze.register_handlers {
  {
    -- adds an `auto_enable` field to lze specs
    -- if true, will disable it if not installed by nix.
    -- if string, will disable if that name was not installed by nix.
    -- if a table of strings, it will disable if any were not.
    spec_field = "auto_enable",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        if type(plugin.auto_enable) == "table" then
          for _, name in pairs(plugin.auto_enable) do
            if not nixInfo.get_nix_plugin_path(name) then
              plugin.enabled = false
              break
            end
          end
        elseif type(plugin.auto_enable) == "string" then
          if not nixInfo.get_nix_plugin_path(plugin.auto_enable) then
            plugin.enabled = false
          end
        elseif type(plugin.auto_enable) == "boolean" and plugin.auto_enable then
          if not nixInfo.get_nix_plugin_path(plugin.name) then
            plugin.enabled = false
          end
        end
      end
      return plugin
    end,
  },
  nixInfo.lze.lsp,
}

nixInfo.lze.h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixInfo.get_nix_plugin_path "nvim-lspconfig"
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    return (ok and cfg or {}).filetypes or {}
  else
    return (vim.lsp.config[name] or {}).filetypes or {}
  end
end)

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.o.exrc = false -- can be toggled off in that file to stop it from searching further

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.opt.inccommand = 'split'
vim.opt.scrolloff = 20
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.virtualedit = "block"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.wo.number = true
vim.o.mouse = 'a'
vim.opt.cpoptions:append('I')
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
vim.wo.signcolumn = 'yes'
vim.wo.relativenumber = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menu,preview,noselect'
vim.o.termguicolors = true

vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "r", "o" })
  end,
})

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.g.netrw_liststyle=0
vim.g.netrw_banner=0

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll Down' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll Up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next Search Result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous Search Result' })

vim.keymap.set("n", "H", "<cmd>bprev<CR>", { desc = 'Previous buffer' })
vim.keymap.set("n", "L", "<cmd>bnext<CR>", { desc = 'Next buffer' })
vim.keymap.set("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = 'Last buffer' })
vim.keymap.set("n", "<leader><leader>d", "<cmd>bdelete<CR>", { desc = 'delete buffer' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set({"v", "x", "n"}, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({"n", "v", "x"}, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({'n', 'v', 'x'}, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+', { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' })
vim.keymap.set("x", "<leader>P", '"_dP', { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' })

nixInfo.lze.load {
  {
    "kanagawa.nvim",
    colorscheme = {"kanagawa-lotus"},
    after = function()
      require("kanagawa").load("lotus")
    end,
  },
  {
    "nvim-treesitter",
    lazy = false,
  },
  {
    "nvim-treesitter-textobjects",
    lazy = false,
    after = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          enable = true,
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = '<c-v>',
          },
          include_surrounding_whitespace = true,
        }
      })
      
      local select = require("nvim-treesitter-textobjects.select").select_textobject
      vim.keymap.set(
        { "x", "o" },
        "af",
        function() select("@function.outer", "textobjects") end,
        { desc = "Around Function (TxtObj)" }
      )
      vim.keymap.set(
        { "x", "o" },
        "if",
        function() select("@function.inner", "textobjects") end,
        { desc = "Inside Function (TxtObj)" }
      )
      vim.keymap.set(
        { "x", "o" },
        "ac",
        function() select("@class.outer", "textobjects") end,
        { desc = "Around Class (TxtObj)" }
      )
      vim.keymap.set(
        { "x", "o" },
        "ic",
        function() select("@class.inner", "textobjects") end,
        { desc = "Inside Class (TxtObj)" }
      )
      vim.keymap.set(
        { "x", "o" },
        "as",
        function() select("@local.scope", "locals") end,
        { desc = "Around local Scope (TxtObj)" }
      )
    end,
  },
  {
    "treesitter-modules.nvim",
    lazy = false,
    after = function()
      local ts = require("treesitter-modules")
      ts.setup({
        sync_install = false,
        auto_install = false,
        highlight = { enable = true },
        fold = { enable = true },
        indent = { enable = true},
      })
      vim.keymap.set("n", "<Leader>ss", ts.init_selection, {
        desc = "Start selecting nodes with treesitter-modules"
      })
      vim.keymap.set("x", "<Leader>si", ts.node_incremental, {
        desc = "Increment selection to named node"
      })
      vim.keymap.set("x", "<Leader>sc", ts.scope_incremental, {
        desc = "Increment selection to surrounding scope"
      })
      vim.keymap.set("x", "<Leader>sd", ts.node_decremental, {
        desc = "Shrink selection to previous named node"
      })

    end,
  },
}

vim.cmd.colorscheme("kanagawa-lotus")
