nixInfo.lze.load({
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
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "<c-v>",
          },
          include_surrounding_whitespace = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select").select_textobject
      vim.keymap.set({ "x", "o" }, "af", function()
        select("@function.outer", "textobjects")
      end, { desc = "Around Function (TxtObj)" })
      vim.keymap.set({ "x", "o" }, "if", function()
        select("@function.inner", "textobjects")
      end, { desc = "Inside Function (TxtObj)" })
      vim.keymap.set({ "x", "o" }, "ac", function()
        select("@class.outer", "textobjects")
      end, { desc = "Around Class (TxtObj)" })
      vim.keymap.set({ "x", "o" }, "ic", function()
        select("@class.inner", "textobjects")
      end, { desc = "Inside Class (TxtObj)" })
      vim.keymap.set({ "x", "o" }, "as", function()
        select("@local.scope", "locals")
      end, { desc = "Around local Scope (TxtObj)" })
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
      vim.keymap.set("n", "<Leader>v", ts.init_selection, {
        desc = "Start selecting nodes with treesitter-modules",
      })
      vim.keymap.set("x", "<Leader>vi", ts.node_incremental, {
        desc = "[I]ncrement selection to named node",
      })
      vim.keymap.set("x", "<Leader>vs", ts.scope_incremental, {
        desc = "Increment selection to surrounding [S]cope",
      })
      vim.keymap.set("x", "<Leader>vd", ts.node_decremental, {
        desc = "[D]ecrement selection to previous named node",
      })
    end,
  },
})
