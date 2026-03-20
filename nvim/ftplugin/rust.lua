local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set(
  "n",
  "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
  function()
    vim.cmd.RustLsp({ "hover", "actions" })
  end,
  { silent = true, buffer = bufnr }
)
local nmap = function(keys, func, desc)
  if desc then
    desc = "LSP: " .. desc
  end
  vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
end

nmap("<leader>lr", vim.lsp.buf.rename, "Rename")
nmap("<leader>lc", vim.lsp.buf.code_action, "Code Action")
nmap("gd", vim.lsp.buf.definition, "Goto Definition")
nmap("<leader>ld", vim.lsp.buf.type_definition, "Type Definition")
nmap("gr", function()
  Snacks.picker.lsp_references()
end, "Goto References")
nmap("gI", function()
  Snacks.picker.lsp_implementations()
end, "Goto Implementation")
nmap("<leader>ls", function()
  Snacks.picker.lsp_symbols()
end, "Document Symbols")
nmap("<leader>lw", function()
  Snacks.picker.lsp_workspace_symbols()
end, "Workspace Symbols")

-- See `:help K` for why this keymap
nmap("K", vim.lsp.buf.hover, "Hover Documentation")
nmap("<leader>lt", vim.lsp.buf.signature_help, "Signature Documentation")

-- Lesser used LSP functionality
nmap("gD", vim.lsp.buf.declaration, "Goto Declaration")
nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace Add Folder")
nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace Remove Folder")
nmap("<leader>wl", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, "Workspace List Folders")

-- Create a command `:Format` local to the LSP buffer
vim.api.nvim_buf_create_user_command(bufnr, "LSPFormat", function(_)
  vim.lsp.buf.format()
end, { desc = "Format current buffer with LSP" })
--
-- local navic = require("nvim-navic")
--
-- local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
-- if client.server_capabilities.documentSymbolProvider then
--   navic.attach(client, bufnr)
-- end
