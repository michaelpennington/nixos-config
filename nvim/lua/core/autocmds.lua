vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "r", "o" })
  end,
})
vim.api.nvim_create_user_command("SuperReplace", function(opts)
  if #opts.fargs ~= 2 then
    vim.notify(
      "SuperReplace needs exactly 2 arguments: <Target> <Replacement>",
      vim.log.levels.ERROR
    )
    return
  end

  local target = string.lower(opts.fargs[1])
  local replacement = string.lower(opts.fargs[2])

  local function to_title(str)
    return str:sub(1, 1):upper() .. str:sub(2)
  end

  local t_title = to_title(target)
  local t_upper = string.upper(target)
  local t_lower = target

  local r_title = to_title(replacement)
  local r_upper = string.upper(replacement)
  local r_lower = replacement

  local search_pattern = string.format([[\v<(%s)|(%s)|(%s)>]], t_title, t_upper, t_lower)
  local replace_expr =
    string.format([[\=submatch(1)!=''?'%s':submatch(2)!=''?'%s':'%s']], r_title, r_upper, r_lower)

  local cmd =
    string.format([[%d,%ds/%s/%s/ge]], opts.line1, opts.line2, search_pattern, replace_expr)

  -- 7. Execute!
  vim.cmd(cmd)
end, {
  nargs = "+",
  range = "%",
  desc = "Case-preserving substitution: SuperReplace <target> <replacement>",
})

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})
