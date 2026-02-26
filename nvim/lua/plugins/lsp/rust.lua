return function(on_attach)
  nixInfo.lze.load({
    {
      "rustaceanvim",
      auto_enable = true,
      lazy = false,
      ft = { "rust" },
    },
    {
      "crates.nvim",
      lazy = true,
      auto_enable = true,
      event = { "BufRead Cargo.toml" },
      after = function(_)
        require("crates").setup({
          lsp = {
            enabled = true,
            on_attach = on_attach,
            actions = true,
            completion = true,
            hover = true,
          },
        })
      end,
    },
    {
      "cargo.nvim",
      lazy = true,
      auto_enable = true,
      ft = { "rust" },
      cmd = {
        "CargoBench",
        "CargoBuild",
        "CargoClean",
        "CargoDoc",
        "CargoNew",
        "CargoRun",
        "CargoRunTerm",
        "CargoTest",
        "CargoUpdate",
        "CargoCheck",
        "CargoClippy",
        "CargoAdd",
        "CargoRemove",
        "CargoFmt",
        "CargoFix",
      },
      after = function(_)
        require("cargo").setup({
          float_window = true,
          window_width = 0.8,
          window_height = 0.8,
          auto_close = true,
          close_timeout = 5000,
        })
      end,
    },
  })
end
