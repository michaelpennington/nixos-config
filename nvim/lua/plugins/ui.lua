nixInfo.lze.load({
  {
    "kanagawa.nvim",
    colorscheme = { "kanagawa-lotus" },
    after = function()
      require("kanagawa").load("lotus")
    end,
  },
  {
    "nvim-web-devicons",
    auto_enable = true,
    dep_of = { "barbar.nvim", "oil.nvim", "snacks.nvim" },
    after = function(_)
      require("nvim-web-devicons").setup({})
    end,
  },
  {
    "mini.icons",
    auto_enable = true,
    dep_of = { "oil.nvim", "snacks.nvim" },
    after = function(_)
      require("mini.icons").setup({})
    end,
  },
  {
    "smart-splits.nvim",
    auto_enable = true,
    lazy = false,
    after = function(_)
      local ss = require("smart-splits")
      ss.setup({})
      vim.keymap.set("n", "<A-h>", ss.resize_left, { desc = "Resize split left", silent = true })
      vim.keymap.set("n", "<A-j>", ss.resize_down, { desc = "Resize split down", silent = true })
      vim.keymap.set("n", "<A-k>", ss.resize_up, { desc = "Resize split up", silent = true })
      vim.keymap.set("n", "<A-l>", ss.resize_right, { desc = "Resize split right", silent = true })
      -- moving between splits
      vim.keymap.set(
        "n",
        "<C-h>",
        ss.move_cursor_left,
        { desc = "Switch to window to the left", silent = true }
      )
      vim.keymap.set(
        "n",
        "<C-j>",
        ss.move_cursor_down,
        { desc = "Switch to window below", silent = true }
      )
      vim.keymap.set(
        "n",
        "<C-k>",
        ss.move_cursor_up,
        { desc = "Switch to window above", silent = true }
      )
      vim.keymap.set(
        "n",
        "<C-l>",
        ss.move_cursor_right,
        { desc = "Switch to window to the right", silent = true }
      )
      vim.keymap.set(
        "n",
        "<C-\\>",
        ss.move_cursor_previous,
        { desc = "Switch to previous window", silent = true }
      )
      -- swapping buffers between windows
      vim.keymap.set(
        "n",
        "<leader><leader>h",
        ss.swap_buf_left,
        { desc = "Swap with window to the left", silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader><leader>j",
        ss.swap_buf_down,
        { desc = "Swap with window below", silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader><leader>k",
        ss.swap_buf_up,
        { desc = "Swap with window above", silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader><leader>l",
        ss.swap_buf_right,
        { desc = "Swap with window to the right", silent = true }
      )
    end,
  },
  {
    "barbar.nvim",
    lazy = false,
    before = function(_)
      vim.g.barbar_auto_setup = false
    end,
    after = function(_)
      require("barbar").setup({
        animation = false,
        icons = {
          -- Configure the base icons on the bufferline.
          -- Valid options to display the buffer index and -number are `true`, 'superscript' and 'subscript'
          buffer_index = false,
          buffer_number = false,
          button = " ",
          -- Enables / disables diagnostic symbols
          diagnostics = {
            [vim.diagnostic.severity.ERROR] = { enabled = true, icon = " " },
            [vim.diagnostic.severity.WARN] = { enabled = false },
            [vim.diagnostic.severity.INFO] = { enabled = false },
            [vim.diagnostic.severity.HINT] = { enabled = true },
          },
          gitsigns = {
            added = { enabled = true, icon = "+" },
            changed = { enabled = true, icon = "~" },
            deleted = { enabled = true, icon = "-" },
          },
          filetype = {
            -- Sets the icon's highlight group.
            -- If false, will use nvim-web-devicons colors
            custom_colors = false,

            -- Requires `nvim-web-devicons` if `true`
            enabled = true,
          },
          separator = { left = "▎", right = "" },

          -- If true, add an additional separator at the end of the buffer list
          separator_at_end = true,

          -- Configure the icons on the bufferline when modified or pinned.
          -- Supports all the base icon options.
          modified = { button = "●" },
          pinned = { button = "", filename = true },

          -- Use a preconfigured buffer appearance— can be 'default', 'powerline', or 'slanted'
          preset = "default",

          -- Configure the icons on the bufferline based on the visibility of a buffer.
          -- Supports all the base icon options, plus `modified` and `pinned`.
          alternate = { filetype = { enabled = false } },
          current = { buffer_index = true },
          inactive = { button = "×" },
          visible = { modified = { buffer_number = false } },
        },
      })
      vim.keymap.set("n", "H", "<cmd>BufferPrevious<CR>", { desc = "Previous buffer" })
      vim.keymap.set("n", "L", "<cmd>BufferNext<CR>", { desc = "Next buffer" })
    end,
  },
  {
    "gitsigns.nvim",
    auto_enable = true,
    lazy = false,
    dep_of = { "barbar.nvim" },
    after = function(_)
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ "n", "v" }, "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to next hunk" })

          map({ "n", "v" }, "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to previous hunk" })

          -- Actions
          -- visual mode
          map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "stage git hunk" })
          map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "reset git hunk" })
          -- normal mode
          map("n", "<leader>gs", gs.stage_hunk, { desc = "git stage hunk" })
          map("n", "<leader>gr", gs.reset_hunk, { desc = "git reset hunk" })
          map("n", "<leader>gS", gs.stage_buffer, { desc = "git Stage buffer" })
          map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
          map("n", "<leader>gR", gs.reset_buffer, { desc = "git Reset buffer" })
          map("n", "<leader>gp", gs.preview_hunk, { desc = "preview git hunk" })
          map("n", "<leader>gb", function()
            gs.blame_line({ full = false })
          end, { desc = "git blame line" })
          map("n", "<leader>gd", gs.diffthis, { desc = "git diff against index" })
          map("n", "<leader>gD", function()
            gs.diffthis("~")
          end, { desc = "git diff against last commit" })

          -- Toggles
          map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
          map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
        end,
      })
      vim.cmd([[hi GitSignsAdd guifg=#04de21]])
      vim.cmd([[hi GitSignsChange guifg=#83fce6]])
      vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    end,
  },
  {
    "fidget.nvim",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require("fidget").setup({})
    end,
  },
  {
    "lualine.nvim",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require("lualine").setup({})
    end,
  },
})
