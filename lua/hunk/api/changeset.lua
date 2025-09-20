local diff = require("hunk.api.diff")
local utils = require("hunk.utils")
local fs = require("hunk.api.fs")

local M = {}

local function merge_lists(a, b)
  local seen = {}

  local function add_unique(list)
    for path in pairs(list) do
      if not seen[path] then
        seen[path] = true
      end
    end
  end

  add_unique(a)
  add_unique(b)

  return utils.get_keys(seen)
end

function M.load_changeset(left, right)
  local left_files = fs.scan_dir(left)
  local right_files = fs.scan_dir(right)
  local files = merge_lists(left_files, right_files)

  local changeset = {}

  for _, file in ipairs(files) do
    local left_file = left_files[file]
    local right_file = right_files[file]

    local type = "modified"
    if not left_file then
      left_file = {}
      type = "added"
    end
    if not right_file then
      right_file = {}
      type = "deleted"
    end

    left_file.path = left .. "/" .. file
    right_file.path = right .. "/" .. file

    changeset[file] = {
      type = type,

      left_file = left_file,
      right_file = right_file,
      filepath = file,

      selected = false,
      selected_lines = {
        left = {},
        right = {},
      },
      hunks = diff.diff_file(left_file, right_file),
    }
  end

  return changeset, files
end

local function write_change(change, output_dir)
  local any_selected = utils.any_lines_selected(change)
  local output_file = output_dir .. "/" .. change.filepath

  if change.type == "deleted" and not change.selected and not any_selected then
    fs.move_file(change.left_file.path, output_file)
    return
  end

  if change.type == "deleted" and change.selected then
    fs.rm_file(output_file)
    return
  end

  if change.type == "added" and not change.selected and not any_selected then
    fs.rm_file(output_file)
    return
  end

  if change.selected and change.type ~= "deleted" then
    fs.move_file(change.right_file.path, output_file)
    return
  end

  if any_selected then
    local left_file_content = fs.read_file_as_lines(change.left_file.path)
    local right_file_content = fs.read_file_as_lines(change.right_file.path)
    local result = diff.apply_diff(left_file_content, right_file_content, change)
    fs.write_file(output_dir .. "/" .. change.filepath, result)
    return
  end

  fs.move_file(change.left_file.path, output_file)
end

function M.write_changeset(changeset, output_dir)
  vim.fn.mkdir(output_dir, "p")

  for _, change in pairs(changeset) do
    write_change(change, output_dir)
  end
end

return M
