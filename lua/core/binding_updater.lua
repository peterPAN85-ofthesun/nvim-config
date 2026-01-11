-- binding_updater.lua
-- Automatically update binding_list.csv by analyzing git diff
-- This script detects changes in keybindings and updates the CSV file accordingly

local M = {}

-- Helper function to execute shell commands and get output
local function exec_cmd(cmd)
  local handle = io.popen(cmd)
  if not handle then
    return nil, "Failed to execute command: " .. cmd
  end
  local result = handle:read("*a")
  handle:close()
  return result
end

-- Get list of modified Lua files from git diff
local function get_modified_lua_files()
  local config_dir = vim.fn.stdpath("config")
  local result = exec_cmd("cd " .. config_dir .. " && git diff HEAD --name-only --diff-filter=AM")

  if not result then
    return {}
  end

  local files = {}
  for file in result:gmatch("[^\r\n]+") do
    if file:match("%.lua$") and (file:match("^lua/") or file:match("^init%.lua$")) then
      table.insert(files, file)
    end
  end

  return files
end

-- Parse git diff for a specific file to find added keybindings
local function parse_diff_for_bindings(file)
  local config_dir = vim.fn.stdpath("config")
  local diff_result = exec_cmd("cd " .. config_dir .. " && git diff HEAD " .. file)

  if not diff_result then
    return {}
  end

  local bindings = {}

  -- Pattern to match vim.keymap.set() calls in added lines
  -- Supports: vim.keymap.set("mode", "binding", function, { desc = "description" })
  -- or: vim.keymap.set("mode", "binding", "command", { desc = "description" })
  for line in diff_result:gmatch("[^\r\n]+") do
    if line:match("^%+") and not line:match("^%+%+%+") then
      -- Remove the leading '+'
      local code_line = line:sub(2)

      -- Match both vim.keymap.set and keymap (alias)
      local mode, binding, desc = code_line:match('[%w_]*keymap%.set%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,.-desc%s*=%s*["\']([^"\']+)["\']')
      if not mode then
        -- Try simpler alias pattern: keymap("mode", "binding", ..., { desc = "..." })
        mode, binding, desc = code_line:match('keymap%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,.-desc%s*=%s*["\']([^"\']+)["\']')
      end

      if mode and binding and desc then
        table.insert(bindings, {
          binding = binding,
          mode = mode,
          desc = desc,
          source = "conf nvim",
          file = file
        })
      end
    end
  end

  return bindings
end

-- Parse all staged/uncommitted changes for new bindings
local function get_unstaged_bindings()
  local config_dir = vim.fn.stdpath("config")
  local diff_result = exec_cmd("cd " .. config_dir .. " && git diff")

  if not diff_result then
    return {}
  end

  local bindings = {}
  local current_file = nil

  for line in diff_result:gmatch("[^\r\n]+") do
    -- Track which file we're looking at
    local file_match = line:match("^%+%+%+ b/(.+)")
    if file_match then
      current_file = file_match
    end

    -- Parse added lines for keybindings
    if line:match("^%+") and not line:match("^%+%+%+") and current_file then
      local code_line = line:sub(2)
      -- Match both vim.keymap.set and keymap (alias)
      local mode, binding, desc = code_line:match('[%w_]*keymap%.set%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,.-desc%s*=%s*["\']([^"\']+)["\']')
      if not mode then
        -- Try simpler alias pattern: keymap("mode", "binding", ..., { desc = "..." })
        mode, binding, desc = code_line:match('keymap%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,.-desc%s*=%s*["\']([^"\']+)["\']')
      end

      if mode and binding and desc then
        table.insert(bindings, {
          binding = binding,
          mode = mode,
          desc = desc,
          source = "conf nvim",
          file = current_file
        })
      end
    end
  end

  return bindings
end

-- Read existing CSV file
local function read_csv()
  local config_dir = vim.fn.stdpath("config")
  local csv_path = config_dir .. "/binding_list.csv"
  local file = io.open(csv_path, "r")

  if not file then
    return {}, "binding,function,mode,source,file\n"
  end

  local header = file:read("*l")
  local entries = {}

  for line in file:lines() do
    -- Parse CSV line: binding,function,mode,source,file
    local binding, func, mode, source, filepath = line:match("^([^,]*),([^,]*),([^,]*),([^,]*),(.*)$")
    if binding and func and mode then
      local key = binding .. "|" .. mode
      entries[key] = {
        binding = binding,
        func = func,
        mode = mode,
        source = source or "",
        file = filepath or ""
      }
    end
  end

  file:close()
  return entries, header
end

-- Write updated CSV file
local function write_csv(entries, header)
  local config_dir = vim.fn.stdpath("config")
  local csv_path = config_dir .. "/binding_list.csv"
  local file = io.open(csv_path, "w")

  if not file then
    return false, "Failed to open CSV file for writing"
  end

  file:write(header)

  -- Sort entries by binding name for consistency
  local sorted_keys = {}
  for k in pairs(entries) do
    table.insert(sorted_keys, k)
  end
  table.sort(sorted_keys, function(a, b)
    local bind_a = entries[a].binding
    local bind_b = entries[b].binding
    return bind_a < bind_b
  end)

  for _, key in ipairs(sorted_keys) do
    local entry = entries[key]
    file:write(string.format("%s,%s,%s,%s,%s\n",
      entry.binding,
      entry.func,
      entry.mode,
      entry.source,
      entry.file
    ))
  end

  file:close()
  return true
end

-- Main function to update bindings from git diff
function M.update_from_diff()
  print("Analyzing git diff for keybinding changes...")

  -- Get all new/modified bindings from git diff
  local new_bindings = get_unstaged_bindings()

  if #new_bindings == 0 then
    print("No new keybindings found in git diff")
    return
  end

  print(string.format("Found %d new/modified keybinding(s)", #new_bindings))

  -- Read existing CSV
  local entries, header = read_csv()

  -- Update or add new bindings
  local added_count = 0
  local updated_count = 0

  for _, binding_info in ipairs(new_bindings) do
    local key = binding_info.binding .. "|" .. binding_info.mode

    if entries[key] then
      -- Update existing entry
      entries[key].func = binding_info.desc
      entries[key].source = binding_info.source
      entries[key].file = binding_info.file
      updated_count = updated_count + 1
    else
      -- Add new entry
      entries[key] = {
        binding = binding_info.binding,
        func = binding_info.desc,
        mode = binding_info.mode,
        source = binding_info.source,
        file = binding_info.file
      }
      added_count = added_count + 1
    end

    print(string.format("  - %s (%s mode): %s", binding_info.binding, binding_info.mode, binding_info.desc))
  end

  -- Write updated CSV
  local success, err = write_csv(entries, header)

  if success then
    print(string.format("\nSuccessfully updated binding_list.csv:"))
    print(string.format("  - Added: %d", added_count))
    print(string.format("  - Updated: %d", updated_count))
  else
    print("Error writing CSV: " .. (err or "unknown error"))
  end
end

-- Create Neovim command
vim.api.nvim_create_user_command('UpdateBindings', function()
  M.update_from_diff()
end, {
  desc = 'Update binding_list.csv from git diff'
})

return M
