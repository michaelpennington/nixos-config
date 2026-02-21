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
      __call = function(_, default) return default end
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
  {
    -- we made an options.settings.cats with the value of enable for our top level specs
    -- give for_cat = "name" to disable if that one is not enabled
    spec_field = "for_cat",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        if type(plugin.for_cat) == "string" then
          plugin.enabled = nixInfo(false, "settings", "cats", plugin.for_cat)
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

vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0

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

vim.keymap.set({ "v", "x", "n" }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+',
  { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' })
vim.keymap.set("x", "<leader>P", '"_dP',
  { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' })

nixInfo.lze.load {
  {
    "kanagawa.nvim",
    colorscheme = { "kanagawa-lotus" },
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
    before = function()
      vim.g.no_plugin_maps = true
    end,
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
    "nvim-lspconfig",
    auto_enable = true,
    -- NOTE: define a function for lsp,
    -- and it will run for all specs with type(plugin.lsp) == table
    -- when their filetype trigger loads them
    lsp = function(plugin)
      local current = type(vim.lsp.config) == "table" and vim.lsp.config[plugin.name] or {}
      local merged_opts = vim.tbl_deep_extend("force", current, plugin.lsp or {})
      if type(vim.lsp.config) == "table" then
        vim.lsp.config[plugin.name] = merged_opts
      else
        vim.lsp.config(plugin.name, merged_opts)
      end
      vim.lsp.enable(plugin.name)
    end,
    -- set up our on_attach function once before the spec loads
    before = function(_)
      vim.lsp.config('*', {
        on_attach = function(_, bufnr)
          -- we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local nmap = function(keys, func, desc)
            if desc then
              desc = 'LSP: ' .. desc
            end
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
          end

          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          -- nmap('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
          -- nmap('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
          -- nmap('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')
          -- nmap('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')

          -- See `:help K` for why this keymap
          nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          nmap('<leader>td', vim.lsp.buf.signature_help, 'Signature Documentation')

          -- Lesser used LSP functionality
          nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          -- Create a command `:Format` local to the LSP buffer
          vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
            vim.lsp.buf.format()
          end, { desc = 'Format current buffer with LSP' })
        end
      })
    end,
  },
  {
    -- lazydev makes your lua lsp load only the relevant definitions for a file.
    -- It also gives us a nice way to correlate globals we create with files.
    "lazydev.nvim",
    ft = "lua",
    dep_of = { "lua_ls" },
    after = function(_)
      local lze_path = nixInfo.get_nix_plugin_path("lze")
      local lzextras_path = nixInfo.get_nix_plugin_path("lzextras")
      local lib_paths = {}
      if lze_path then
        table.insert(lib_paths, { words = { "nixInfo%.lze" }, path = lze_path .. '/lua' })
      end
      if lzextras_path then
        table.insert(lib_paths, { words = { "nixInfo%.lze" }, path = lzextras_path .. '/lua' })
      end
      require('lazydev').setup({
        library = lib_paths,
      })
    end,
  },
  {
    -- name of the lsp
    "lua_ls",
    for_cat = "lua",
    -- provide a table containing filetypes,
    -- and then whatever your functions defined in the function type specs expect.
    -- in our case, it just expects the normal lspconfig setup options,
    -- but with a default on_attach and capabilities
    lsp = {
      -- if you provide the filetypes it doesn't ask lspconfig for the filetypes
      -- (meaning it doesn't call the callback function we defined in the main init.lua)
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            pathStrict = false,
          },
          workspace = {
            checkThirdParty = false,
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            disable = { 'missing-fields' },
          },
        },
      },
    },
    -- also these are regular specs and you can use before and after and all the other normal fields
  },
  {
    "nixd",
    enabled = nixInfo.isNix, -- mason doesn't have nixd
    for_cat = "nix",
    lsp = {
      filetypes = { "nix" },
      settings = {
        nixd = {
          nixpkgs = {
            expr = [[import <nixpkgs> {}]],
          },
          options = {
          },
          formatting = {
            command = { "nixfmt" }
          },
          diagnostic = {
            suppress = {
              "sema-escaping-with"
            }
          }
        }
      },
    },
  },
  {
    "blink.cmp",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require("blink.cmp").setup({
        keymap = {
          preset = 'super-tab'
        },
        appearance = {
          nerd_font_variant = "normal"
        },

        completion = { documentation = { auto_show = true } },

        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          per_filetype = {
            lua = { inherit_defaults = true, "lazydev" },
          },
          providers = {
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
      })
    end,
  },
  {
    "gitsigns.nvim",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          -- Actions
          -- visual mode
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'reset git hunk' })
          -- normal mode
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git blame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'git diff against last commit' })

          -- Toggles
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
        end,
      })
      vim.cmd([[hi GitSignsAdd guifg=#04de21]])
      vim.cmd([[hi GitSignsChange guifg=#83fce6]])
      vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    end,
  },
  {
    "snacks.nvim",
    auto_enable = true,
    -- snacks makes a global, and then lazily loads itself
    lazy = false,
    after = function(_)
      require('snacks').setup({
        lazygit = {
          config = {
            os = {
              editPreset = "nvim-remote",
              edit = vim.v.progpath ..
                  [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}})<CR>']=],
              editAtLine = vim.v.progpath ..
                  [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}}, {{line}})<CR>']=],
              openDirInEditor = vim.v.progpath ..
                  [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{dir}})<CR>']=],
              -- this one isnt a remote command, make sure it gets our config regardless of if we name it nvim or not
              editAtLineAndWait = nixInfo(vim.v.progpath, "progpath") .. " +{{line}} {{filename}}",
            },
          },
        },
      })
      -- Handle the backend of those remote commands.
      -- hopefully this can be removed one day
      nixInfo.lazygit_fix = function(path, line)
        local prev = vim.fn.bufnr("#")
        local prev_win = vim.fn.bufwinid(prev)
        vim.api.nvim_feedkeys("q", "n", false)
        if line then
          vim.api.nvim_buf_call(prev, function()
            vim.cmd.edit(path)
            local buf = vim.api.nvim_get_current_buf()
            vim.schedule(function()
              if buf then
                vim.api.nvim_win_set_buf(prev_win, buf)
                vim.api.nvim_win_set_cursor(0, { line or 0, 0 })
              end
            end)
          end)
        else
          vim.api.nvim_buf_call(prev, function()
            vim.cmd.edit(path)
            local buf = vim.api.nvim_get_current_buf()
            vim.schedule(function()
              if buf then
                vim.api.nvim_win_set_buf(prev_win, buf)
              end
            end)
          end)
        end
      end
      vim.keymap.set("n", "<leader>_", function() Snacks.lazygit.open() end, { desc = 'Snacks LazyGit' })
    end
  },
  {
    "smart-splits.nvim",
    auto_enable = true,
    lazy = false,
    after = function(_)
      local ss = require('smart-splits')
      ss.setup({})
      vim.keymap.set('n', '<A-h>', ss.resize_left, { desc = "Resize split left", silent = true })
      vim.keymap.set('n', '<A-j>', ss.resize_down, { desc = "Resize split down", silent = true })
      vim.keymap.set('n', '<A-k>', ss.resize_up, { desc = "Resize split up", silent = true })
      vim.keymap.set('n', '<A-l>', ss.resize_right, { desc = "Resize split right", silent = true })
      -- moving between splits
      vim.keymap.set('n', '<C-h>', ss.move_cursor_left, { desc = "Switch to window to the left", silent = true })
      vim.keymap.set('n', '<C-j>', ss.move_cursor_down, { desc = "Switch to window below", silent = true })
      vim.keymap.set('n', '<C-k>', ss.move_cursor_up, { desc = "Switch to window above", silent = true })
      vim.keymap.set('n', '<C-l>', ss.move_cursor_right, { desc = "Switch to window to the right", silent = true })
      vim.keymap.set('n', '<C-\\>', ss.move_cursor_previous, { desc = "Switch to previous window", silent = true })
      -- swapping buffers between windows
      vim.keymap.set('n', '<leader><leader>h', ss.swap_buf_left, { desc = "Swap with window to the left", silent = true })
      vim.keymap.set('n', '<leader><leader>j', ss.swap_buf_down, { desc = "Swap with window below", silent = true })
      vim.keymap.set('n', '<leader><leader>k', ss.swap_buf_up, { desc = "Swap with window above", silent = true })
      vim.keymap.set('n', '<leader><leader>l', ss.swap_buf_right, { desc = "Swap with window to the right", silent = true })
    end,
  },
  {
    "nvim-web-devicons",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require('nvim-web-devicons').setup({})
    end,
  },
}

vim.cmd.colorscheme("kanagawa-lotus")
vim.diagnostic.config({
  virtual_lines = true,
})
