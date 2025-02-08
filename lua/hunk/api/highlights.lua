local M = {}

function M.set_win_hl(winid, highlights)
  vim.api.nvim_set_option_value("winhl", table.concat(highlights, ","), {
    win = winid,
  })
end

local function color_as_hex(color)
  if not color then
    return
  end
  return string.format("#%06x", color)
end

function M.define_highlights()
  local diff_delete_highlight = vim.api.nvim_get_hl(0, {
    name = "DiffDelete",
    link = true,
  })

  vim.api.nvim_set_hl(
    0,
    "HunkDiffAddAsDelete",
    vim.tbl_deep_extend("force", diff_delete_highlight, {
      bg = color_as_hex(diff_delete_highlight.bg),
      fg = color_as_hex(diff_delete_highlight.fg),
      sp = color_as_hex(diff_delete_highlight.sp),
    })
  )

  vim.api.nvim_set_hl(0, "HunkDiffDelete", {
    link = "HunkDiffDeleteDim",
  })

  vim.api.nvim_set_hl(0, "HunkDiffDeleteDim", {
    default = true,
    link = "Comment",
  })

  vim.api.nvim_set_hl(0, "HunkFileTreeFileAdded", {
    default = true,
    link = "Green",
  })
  vim.api.nvim_set_hl(0, "HunkFileTreeFileDeleted", {
    default = true,
    link = "Red",
  })
  vim.api.nvim_set_hl(0, "HunkFileTreeFileModified", {
    default = true,
    link = "Blue",
  })

  vim.api.nvim_set_hl(0, "HunkFileTreeIconAdded", {
    default = true,
    link = "HunkFileTreeFileAdded",
  })
  vim.api.nvim_set_hl(0, "HunkFileTreeIconDeleted", {
    default = true,
    link = "HunkFileTreeFileDeleted",
  })
  vim.api.nvim_set_hl(0, "HunkFileTreeIconModified", {
    default = true,
    link = "HunkFileTreeFileModified",
  })

  vim.api.nvim_set_hl(0, "HunkFileTreeDirIcon", {
    default = true,
    link = "Yellow",
  })

  vim.api.nvim_set_hl(0, "HunkFileTreeSelectionIcon", {
    default = true,
    link = "Comment",
  })
end

return M
