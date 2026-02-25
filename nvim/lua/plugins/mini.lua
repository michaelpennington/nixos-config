nixInfo.lze.load({
  {
    "mini.ai",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require("mini.ai").setup({})
    end,
  },
  {
    "mini.comment",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require("mini.comment").setup({
        mappings = {
          comment = "<leader>/",
          comment_line = "<leader>/",
          comment_visual = "<leader>/",
          textobject = "<leader>/",
        },
      })
    end,
  },
  {
    "mini.pairs",
    auto_enable = true,
    lazy = false,
    after = function(_)
      require("mini.pairs").setup({})
    end,
  },
  {
    "mini.extra",
    dep_of = { "mini.hipatterns" },
    auto_enable = true,
    after = function(_)
      require("mini.extra").setup({})
    end,
  },
  {
    "mini.hipatterns",
    auto_enable = true,
    lazy = false,
    after = function(_)
      local hi_words = MiniExtra.gen_highlighter.words
      require("mini.hipatterns").setup({
        fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
        hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
        todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
        note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
      })
    end,
  },
  {
    "mini.clue",
    auto_enable = true,
    lazy = false,
    after = function(_)
      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = { "n", "x" }, keys = "<Leader>" },

          -- `[` and `]` keys
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = { "n", "x" }, keys = "g" },

          -- Marks
          { mode = { "n", "x" }, keys = "'" },
          { mode = { "n", "x" }, keys = "`" },

          -- Registers
          { mode = { "n", "x" }, keys = '"' },
          { mode = { "i", "c" }, keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = { "n", "x" }, keys = "z" },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.square_brackets(),
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
          { mode = "n", keys = "<Leader>g", desc = "+Git" },
          { mode = "x", keys = "<Leader>h", desc = "+Git" },
          { mode = { "n", "x" }, keys = "<Leader>F", desc = "+Format" },
          { mode = "n", keys = "<Leader>f", desc = "+Find" },
          { mode = "n", keys = "<Leader>gt", desc = "+Toggle Options" },
          { mode = { "n", "x" }, keys = "<Leader>s", desc = "+Search" },
          { mode = "n", keys = "<Leader>w", desc = "+Workspace" },
          { mode = "n", keys = "<Leader>l", desc = "+LSP" },
          { mode = "n", keys = "<Leader><Leader>", desc = "+Buffer Options" },
          { mode = { "n", "x" }, keys = "<Leader>v", desc = "+Select" },
        },

        window = {
          config = {
            row = "auto",
            col = "auto",
            width = 50,
            anchor = "NE",
          },
          delay = 250,
        },
      })
    end,
  },
})
