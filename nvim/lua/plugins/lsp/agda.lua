nixInfo.lze.load({
  {
    "cornelis",
    auto_enable = true,
    lazy = true,
    ft = { "agda" },
    before = function()
      vim.g.cornelis_agda_prefix = "\\"
    end,
    after = function() end,
  },
})
