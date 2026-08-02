nixInfo.lze.load({
  {
    "typst-preview.nvim",
    enabled = nixInfo(nil, "settings", "cats", "typst"),
    auto_enable = true,
    lazy = true,
    ft = "typst",
    after = function(_)
      require("typst-preview").setup({
        dependencies_bin = {
          ["tinymist"] = "tinymist",
          ["websocat"] = "websocat",
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function(opts)
          vim.b[opts.buf].miniclue_config = {
            clues = {
              { mode = "n", keys = "<Leader>t", desc = "+Typst" },
            },
          }
          vim.keymap.set(
            "n",
            "<leader>tp",
            "<cmd>TypstPreview<cr>",
            { buffer = opts.buf, desc = "Typst Preview" }
          )
          vim.keymap.set(
            "n",
            "<leader>tS",
            "<cmd>TypstPreviewSync<cr>",
            { buffer = opts.buf, desc = "Typst Preview Sync" }
          )
        end,
      })
    end,
  },
})
