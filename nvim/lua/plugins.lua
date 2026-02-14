-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd.colorscheme("kanagawa-lotus")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    config = function()
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

      local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
      local select = function(query, group)
        local group = group or "textobjects"
        select_textobject(query, group)
      end

      vim.keymap.set({ "x", "o" }, "af", function() select("@function.outer") end, {
        desc = "Around Function (TxtObj)",
      })
      vim.keymap.set({ "x", "o" }, "if", function() select("@function.inner") end, {
        desc = "Inside Function (TxtObj)",
      })
      vim.keymap.set({ "x", "o" }, "ac", function() select("@class.outer") end, {
        desc = "Around Class (TxtObj)",
      })
      vim.keymap.set({ "x", "o" }, "ic", function() select("@class.inner") end, {
        desc = "Inside Class (TxtObj)",
      })
      vim.keymap.set({ "x", "o" }, "as", function() select("@local.scope", "locals") end, {
        desc = "Around local Scope (TxtObj)",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
  },
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ts = require("treesitter-modules")
      ts.setup({
        ensure_installed = { 'lua', 'vim', 'c', 'vimdoc', 'query', 'markdown', 'markdown_inline', 'nix' },
        sync_install = true,
        auto_install = false,
        highlight = { enable = true },
        fold = { enable = true },
        indent = { enable = true },
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
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config["clangd"] = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp" },
      }
      vim.lsp.enable("clangd")
    end,
  },
})
