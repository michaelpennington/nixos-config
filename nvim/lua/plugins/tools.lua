nixInfo.lze.load({
  {
    "snacks.nvim",
    auto_enable = true,
    -- snacks makes a global, and then lazily loads itself
    lazy = false,
    after = function(_)
      require("snacks").setup({
        picker = {
          sources = {
            explorer = {
              auto_close = true,
            },
          },
        },
        git = {},
        terminal = {},
        scope = {},
        indent = {
          scope = {
            hl = "MySnacksIndent",
          },
          chunk = {
            -- enabled = true,
            hl = "MySnacksIndent",
          },
        },
        statuscolumn = {
          left = { "mark", "git" }, -- priority of signs on the left (high to low)
          right = { "sign", "fold" }, -- priority of signs on the right (high to low)
          folds = {
            open = false, -- show open fold icons
            git_hl = false, -- use Git Signs hl for fold icons
          },
          git = {
            -- patterns to match Git signs
            patterns = { "GitSign", "MiniDiffSign" },
          },
          refresh = 50, -- refresh at most every 50ms
        },
        lazygit = {
          config = {
            os = {
              editPreset = "nvim-remote",
              edit = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}})<CR>']=],
              editAtLine = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}}, {{line}})<CR>']=],
              openDirInEditor = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{dir}})<CR>']=],
              -- this one isnt a remote command, make sure it gets our config regardless of if we name it nvim or not
              editAtLineAndWait = nixInfo(vim.v.progpath, "progpath") .. " +{{line}} {{filename}}",
            },
          },
        },
        dashboard = {
          sections = {
            { section = "header" },
            {
              pane = 2,
              section = "terminal",
              cmd = "/home/mpennington/nixos-config/nvim/rectangle",
              height = 5,
              padding = 1,
            },
            { section = "keys", gap = 1, padding = 1 },
            {
              pane = 2,
              icon = " ",
              title = "Recent Files",
              section = "recent_files",
              indent = 2,
              padding = 1,
            },
            {
              pane = 2,
              icon = " ",
              title = "Projects",
              section = "projects",
              indent = 2,
              padding = 1,
            },
            {
              pane = 2,
              icon = " ",
              title = "Git Status",
              section = "terminal",
              enabled = function()
                return Snacks.git.get_root() ~= nil
              end,
              cmd = "git status --short --branch --renames",
              height = 5,
              padding = 1,
              ttl = 5 * 60,
              indent = 3,
            },
            -- { section = "startup" },
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
      vim.keymap.set("n", "<c-\\>", function()
        Snacks.terminal.open()
      end, { desc = "Snacks Terminal" })
      vim.keymap.set("n", "<leader>_", function()
        Snacks.lazygit.open()
      end, { desc = "Snacks LazyGit" })
      vim.keymap.set("n", "<leader>sf", function()
        Snacks.picker.smart()
      end, { desc = "Smart Find Files" })
      vim.keymap.set("n", "<leader><leader>s", function()
        Snacks.picker.buffers()
      end, { desc = "Search Buffers" })
      -- find
      vim.keymap.set("n", "<leader>ff", function()
        Snacks.picker.files()
      end, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", function()
        Snacks.picker.git_files()
      end, { desc = "Find Git Files" })
      -- Grep
      vim.keymap.set("n", "<leader>sb", function()
        Snacks.picker.lines()
      end, { desc = "Buffer Lines" })
      vim.keymap.set("n", "<leader>sB", function()
        Snacks.picker.grep_buffers()
      end, { desc = "Grep Open Buffers" })
      vim.keymap.set("n", "<leader>sg", function()
        Snacks.picker.grep()
      end, { desc = "Grep" })
      vim.keymap.set({ "n", "x" }, "<leader>sw", function()
        Snacks.picker.grep_word()
      end, { desc = "Visual selection or ord" })
      -- search
      vim.keymap.set("n", "<leader>sb", function()
        Snacks.picker.lines()
      end, { desc = "Buffer Lines" })
      vim.keymap.set("n", "<leader>sd", function()
        Snacks.picker.diagnostics()
      end, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>sD", function()
        Snacks.picker.diagnostics_buffer()
      end, { desc = "Buffer Diagnostics" })
      vim.keymap.set("n", "<leader>sh", function()
        Snacks.picker.help()
      end, { desc = "Help Pages" })
      vim.keymap.set("n", "<leader>sj", function()
        Snacks.picker.jumps()
      end, { desc = "Jumps" })
      vim.keymap.set("n", "<leader>sk", function()
        Snacks.picker.keymaps()
      end, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>sl", function()
        Snacks.picker.loclist()
      end, { desc = "Location List" })
      vim.keymap.set("n", "<leader>sm", function()
        Snacks.picker.marks()
      end, { desc = "Marks" })
      vim.keymap.set("n", "<leader>sM", function()
        Snacks.picker.man()
      end, { desc = "Man Pages" })
      vim.keymap.set("n", "<leader>sq", function()
        Snacks.picker.qflist()
      end, { desc = "Quickfix List" })
      vim.keymap.set("n", "<leader>sR", function()
        Snacks.picker.resume()
      end, { desc = "Resume" })
      vim.keymap.set("n", "<leader>su", function()
        Snacks.picker.undo()
      end, { desc = "Undo History" })
    end,
  },
  {
    "oil.nvim",
    dep_of = { "oil-lsp-diagnostics.nvim", "oil-git-status.nvim" },
    auto_enable = true,
    lazy = true,
    after = function(_)
      local oil = require("oil")
      oil.setup({
        watch_for_changes = true,
        keymaps = {
          ["<leader>e"] = { "actions.close", mode = "n" },
        },
        win_options = {
          signcolumn = "yes:2",
        },
        float = {
          padding = 10,
          win_options = {
            signcolumn = "yes:2",
          },
        },
      })

      vim.keymap.set(
        "n",
        "<leader>e",
        oil.open_float,
        { desc = "Open oil (file browser)", silent = true }
      )
    end,
  },
  {
    "oil-lsp-diagnostics.nvim",
    auto_enable = true,
    after = function(_)
      require("oil-lsp-diagnostics").setup({})
    end,
  },
  {
    "oil-git-status.nvim",
    auto_enable = true,
    after = function(_)
      require("oil-git-status").setup({})
    end,
  },
  {
    "conform.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      local conform = require("conform")

      conform.setup({
        formatters = {
          stylua = {
            append_args = {
              "--column-width",
              "100",
              "--indent-type",
              "spaces",
              "--line-endings",
              "unix",
              "--indent-width",
              "2",
            },
          },
        },
        formatters_by_ft = {
          lua = nixInfo(nil, "settings", "cats", "lua") and { "stylua" } or nil,
          nix = nixInfo(nil, "settings", "cats", "nix") and { "alejandra" } or nil,
        },
        format_on_save = function(bufnr)
          -- local ignore_filetypes = { "sql", "java" }
          -- if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          --   return
          -- end
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end

          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match("/node_modules/") then
            return
          end

          return { timeout_ms = 500, lsp_format = "fallback" }
        end,
      })
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format(
          { async = true, lsp_format = "fallback", range = range },
          function(err)
            if not err then
              local mode = vim.api.nvim_get_mode().mode
              if vim.startswith(string.lower(mode), "v") then
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                  "n",
                  true
                )
              end
            end
          end
        )
      end, { range = true, desc = "Format current buffer with Conform" })
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "Disable autoformat-on-save", bang = true })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable autoformat-on-save" })
      vim.keymap.set(
        { "n", "v" },
        "<leader>FF",
        ":Format<CR>",
        { desc = "[F]ormat [F]ile", silent = true }
      )

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  {
    "neorg",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {
            config = {
              icon_preset = "varied",
            },
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
              },
              default_workspace = "notes",
            },
          },
        },
      })
    end,
  },
  {
    "nvim-surround",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require("nvim-surround").setup({})
    end,
  },
  {
    "vim-startuptime",
    auto_enable = true,
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixInfo(vim.v.progpath, "progpath")
    end,
  },
})
