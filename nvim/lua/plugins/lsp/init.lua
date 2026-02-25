nixInfo.lze.h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixInfo.get_nix_plugin_path("nvim-lspconfig")
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    return (ok and cfg or {}).filetypes or {}
  else
    return (vim.lsp.config[name] or {}).filetypes or {}
  end
end)

require("plugins.lsp.lua")
require("plugins.lsp.nix")

nixInfo.lze.load({
  {
    "nvim-lspconfig",
    auto_enable = true,
    -- NOTE: define a function for lsp,
    -- and it will run for all specs with type(plugin.lsp) == table
    -- when their filetype trigger loads them
    lsp = function(plugin)
      local current = type(vim.lsp.config) == "table" and vim.lsp.config[plugin.name] or {}
      local merged_opts = vim.tbl_deep_extend("force", current, plugin.lsp or {})
      if type(vim.lsp.config) == "table" then
        vim.lsp.config[plugin.name] = merged_opts
      else
        vim.lsp.config(plugin.name, merged_opts)
      end
      vim.lsp.enable(plugin.name)
    end,
    -- set up our on_attach function once before the spec loads
    before = function(_)
      vim.lsp.config("*", {
        on_attach = function(_, bufnr)
          -- we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local nmap = function(keys, func, desc)
            if desc then
              desc = "[L]SP: " .. desc
            end
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
          end

          nmap("<leader>lr", vim.lsp.buf.rename, "[R]ename")
          nmap("<leader>lc", vim.lsp.buf.code_action, "[C]ode Action")
          nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
          nmap("<leader>ld", vim.lsp.buf.type_definition, "Type [D]efinition")
          nmap("gr", function()
            Snacks.picker.lsp_references()
          end, "[G]oto [R]eferences")
          nmap("gI", function()
            Snacks.picker.lsp_implementations()
          end, "[G]oto [I]mplementation")
          nmap("<leader>ls", function()
            Snacks.picker.lsp_symbols()
          end, "Document [S]ymbols")
          nmap("<leader>lw", function()
            Snacks.picker.lsp_workspace_symbols()
          end, "[W]orkspace Symbols")

          -- See `:help K` for why this keymap
          nmap("K", vim.lsp.buf.hover, "Hover Documentation")
          nmap("<leader>lt", vim.lsp.buf.signature_help, "Signature Documentation")

          -- Lesser used LSP functionality
          nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
          nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
          nmap("<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "[W]orkspace [L]ist Folders")

          -- Create a command `:Format` local to the LSP buffer
          vim.api.nvim_buf_create_user_command(bufnr, "LSPFormat", function(_)
            vim.lsp.buf.format()
          end, { desc = "Format current buffer with LSP" })
        end,
      })
    end,
  },
  {
    "blink.cmp",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require("blink.cmp").setup({
        keymap = {
          preset = "none",
          ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
          ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
          ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<C-e>"] = { "hide", "fallback" },
        },
        appearance = {
          nerd_font_variant = "normal",
        },

        completion = {
          documentation = { auto_show = true },
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
        },

        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          per_filetype = {
            lua = { inherit_defaults = true, "lazydev" },
          },
          providers = {
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" },
      })
    end,
  },
})
