-- nvim/ftplugin/agda.lua
local bufnr = vim.api.nvim_get_current_buf()

local function nmap(keys, cmd, desc)
  vim.keymap.set("n", keys, cmd, { buffer = bufnr, desc = "Agda: " .. desc })
end

-- Apply Spacemacs bindings to both <localleader> (,) and <leader>m (SPC m)
local prefixes = { "<localleader>", "<leader>m" }

for _, prefix in ipairs(prefixes) do
  nmap(prefix .. "l", "<cmd>CornelisLoad<CR>", "Load")
  nmap(prefix .. "?", "<cmd>CornelisGoals<CR>", "Show all goals")
  nmap(prefix .. "c", "<cmd>CornelisMakeCase<CR>", "Make case")
  nmap(prefix .. " ", "<cmd>CornelisGive<CR>", "Give (fill goal)")
  nmap(prefix .. "r", "<cmd>CornelisRefine<CR>", "Refine goal")
  nmap(prefix .. "a", "<cmd>CornelisAuto<CR>", "Auto (proof search)")
  nmap(prefix .. "t", "<cmd>CornelisTypeInfer<CR>", "Infer type")
  nmap(prefix .. ",", "<cmd>CornelisTypeContext<CR>", "Type and context")
  nmap(prefix .. ".", "<cmd>CornelisTypeContextInfer<CR>", "Type, context & infer")
  nmap(prefix .. "n", "<cmd>CornelisNormalize<CR>", "Normalize")
  nmap(prefix .. "xr", "<cmd>CornelisRestart<CR>", "Restart Agda")
  nmap(prefix .. "gg", "<cmd>CornelisGoToDefinition<CR>", "Go to definition")
end

-- Map standard gd for Go To Definition without the prefixes
nmap("gd", "<cmd>CornelisGoToDefinition<CR>", "Go to definition")
