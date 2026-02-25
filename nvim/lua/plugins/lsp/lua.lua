nixInfo.lze.load({
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
        table.insert(lib_paths, { words = { "nixInfo%.lze" }, path = lze_path .. "/lua" })
      end
      if lzextras_path then
        table.insert(lib_paths, { words = { "nixInfo%.lze" }, path = lzextras_path .. "/lua" })
      end
      require("lazydev").setup({
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
      filetypes = { "lua" },
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
            disable = { "missing-fields" },
          },
        },
      },
    },
    -- also these are regular specs and you can use before and after and all the other normal fields
  },
})
