nixInfo.lze.load({
	{
		"clangd",
		for_cat = "cCpp",
		lsp = {
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
			},
		},
	},
	{
		"clangd_extensions.nvim",
		for_cat = "cCpp",
		after = function(_)
			require("clangd_extensions").setup()
		end,
	},
})
