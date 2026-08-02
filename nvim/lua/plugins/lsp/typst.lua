nixInfo.lze.load({
  "tinymist",
  enabled = nixInfo(nil, "settings", "cats", "typst"),
  for_cat = "typst",
  lsp = {
    filetypes = { "typst" },
    settings = {
      exportPdf = "onType",
    },
  },
})
