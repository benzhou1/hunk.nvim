local fixtures = require("tests.utils.fixtures")
local api = require("hunk.api")

describe("diff patching", function()
  fixtures.with_workspace(function(workspace)
    fixtures.prepare_simple_workspace(workspace)

    local changeset = api.changeset.load_changeset(workspace.left, workspace.right)

    it("should do nothing if no lines are selected", function()
      local change = changeset.modified
      local left_file_content = api.fs.read_file_as_lines(change.left_file.path)
      local right_file_content = api.fs.read_file_as_lines(change.right_file.path)
      local result = api.diff.apply_diff(left_file_content, right_file_content, change)
      assert.are.same(left_file_content, result)
    end)

    it("should apply left before right", function()
      local change = changeset.modified
      local left_file_content = api.fs.read_file_as_lines(change.left_file.path)
      local right_file_content = api.fs.read_file_as_lines(change.right_file.path)
      change.selected_lines = {
        left = {
          [1] = false,
          [2] = true,
          [3] = true,
        },
        right = {
          [1] = true,
          [2] = true,
          [3] = true,
        },
      }
      local result = api.diff.apply_diff(left_file_content, right_file_content, change)
      assert.are.same({
        "a",
        "a1",
        "c",
        "d",
      }, result)
    end)

    it("should apply files with no left correctly", function()
      local change = changeset.added
      local left_file_content = api.fs.read_file_as_lines(change.left_file.path)
      local right_file_content = api.fs.read_file_as_lines(change.right_file.path)
      change.selected_lines = {
        left = {},
        right = {
          [1] = true,
          [2] = true,
          [3] = true,
        },
      }
      local result = api.diff.apply_diff(left_file_content, right_file_content, change)
      assert.are.same({
        "a",
        "b",
        "c",
      }, result)
    end)

    it("should apply files with no right correctly", function()
      local change = changeset.deleted
      local left_file_content = api.fs.read_file_as_lines(change.left_file.path)
      local right_file_content = api.fs.read_file_as_lines(change.right_file.path)
      change.selected_lines = {
        left = {
          [1] = false,
          [2] = false,
          [3] = true,
        },
        right = {},
      }
      local result = api.diff.apply_diff(left_file_content, right_file_content, change)
      assert.are.same({
        "a",
        "b",
      }, result)
    end)
  end)

  it("should handle inserts at beginning of file correctly", function()
    fixtures.with_workspace(function(workspace)
      fixtures.prepare_workspace(workspace, {
        modified = {
          "a",
          "b",
          "c",
          "d",
        },
      }, {
        modified = {
          "new",
          "a",
          "b",
          "changed",
          "d",
        },
      })

      local changeset = api.changeset.load_changeset(workspace.left, workspace.right)

      local change = changeset.modified
      local left_file_content = api.fs.read_file_as_lines(change.left_file.path)
      local right_file_content = api.fs.read_file_as_lines(change.right_file.path)
      change.selected_lines = {
        left = {
          [1] = true,
          [2] = true,
          [3] = true,
          [4] = true,
        },
        right = {
          [1] = true,
          [2] = true,
          [3] = true,
          [4] = true,
          [5] = true,
        },
      }
      local result = api.diff.apply_diff(left_file_content, right_file_content, change)
      assert.are.same({
        "new",
        "a",
        "b",
        "changed",
        "d",
      }, result)
    end)
  end)

  it("should maintain line ordering within a hunk", function()
    fixtures.with_workspace(function(workspace)
      fixtures.prepare_workspace(workspace, {
        filea = {
          "a1",
          "b1",
          "c1",
          "d1",
        },
      }, {
        filea = {
          "a1",
          "b2",
          "c2",
          "d1",
        },
      })

      local changeset = api.changeset.load_changeset(workspace.left, workspace.right)

      local change = changeset.filea
      local left_file_content = api.fs.read_file_as_lines(change.left_file.path)
      local right_file_content = api.fs.read_file_as_lines(change.right_file.path)
      change.selected_lines = {
        left = {
          [2] = true,
        },
        right = {
          [2] = true,
        },
      }
      local result = api.diff.apply_diff(left_file_content, right_file_content, change)
      assert.are.same({
        "a1",
        "b2",
        "c1",
        "d1",
      }, result)
    end)
  end)
end)
