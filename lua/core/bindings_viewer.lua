-- Custom Telescope picker for viewing keybindings from binding_list.csv
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local M = {}

-- Search mode: "binding" or "function"
local current_search_mode = "binding"

-- Parse CSV line handling quoted fields
local function parse_csv_line(line)
	local fields = {}
	local field = ""
	local in_quotes = false
	local i = 1

	while i <= #line do
		local char = line:sub(i, i)

		if char == '"' then
			in_quotes = not in_quotes
		elseif char == "," and not in_quotes then
			table.insert(fields, field)
			field = ""
		else
			field = field .. char
		end

		i = i + 1
	end

	-- Add the last field
	table.insert(fields, field)

	return fields
end

-- Parse CSV file and return table of bindings
local function parse_bindings_csv()
	local csv_path = vim.fn.stdpath("config") .. "/binding_list.csv"
	local file = io.open(csv_path, "r")
	if not file then
		vim.notify("Could not open binding_list.csv", vim.log.levels.ERROR)
		return {}
	end

	local bindings = {}
	local header = file:read("*line") -- Skip header line

	for line in file:lines() do
		local fields = parse_csv_line(line)

		if #fields >= 5 then
			table.insert(bindings, {
				binding = fields[1],
				func = fields[2],
				mode = fields[3],
				source = fields[4],
				file = fields[5],
			})
		end
	end

	file:close()
	return bindings
end

-- Create display entry for Telescope
local function make_display(entry)
	local displayer = require("telescope.pickers.entry_display").create({
		separator = " │ ",
		items = {
			{ width = 20 },
			{ width = 8 },
			{ width = 12 },
			{ remaining = true },
		},
	})

	return displayer({
		{ entry.binding, "TelescopeResultsIdentifier" },
		{ entry.mode, "TelescopeResultsConstant" },
		{ entry.source, "TelescopeResultsComment" },
		{ entry.func, "TelescopeResultsFunction" },
	})
end

-- Main function to show bindings picker
function M.show_bindings(search_mode)
	-- Use provided mode or keep current
	if search_mode then
		current_search_mode = search_mode
	end

	local bindings = parse_bindings_csv()

	if #bindings == 0 then
		vim.notify("No bindings found in binding_list.csv", vim.log.levels.WARN)
		return
	end

	-- Determine prompt title based on search mode
	local prompt_title = current_search_mode == "binding"
		and "Keybindings [Mode: Search by BINDING] <C-t> to toggle"
		or "Keybindings [Mode: Search by FUNCTION] <C-t> to toggle"

	pickers
		.new({}, {
			prompt_title = prompt_title,
			finder = finders.new_table({
				results = bindings,
				entry_maker = function(entry)
					-- Change ordinal based on search mode
					local ordinal
					if current_search_mode == "binding" then
						ordinal = entry.binding .. " " .. entry.mode
					else
						ordinal = entry.func .. " " .. entry.binding
					end

					return {
						value = entry,
						display = make_display,
						ordinal = ordinal,
						binding = entry.binding,
						func = entry.func,
						mode = entry.mode,
						source = entry.source,
						file = entry.file,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewers.new_buffer_previewer({
				title = "Binding Details",
				define_preview = function(self, entry)
					local search_mode_info = current_search_mode == "binding"
						and "Current: Search by BINDING (press <C-t> to search by function)"
						or "Current: Search by FUNCTION (press <C-t> to search by binding)"

					local lines = {
						"╔════════════════════════════════════════",
						"║ " .. search_mode_info,
						"╚════════════════════════════════════════",
						"",
						"Keybinding: " .. entry.binding,
						"Function: " .. entry.func,
						"Mode: " .. entry.mode,
						"Source: " .. entry.source,
						"File: " .. entry.file,
						"",
						"Mode Legend:",
						"  n = normal mode",
						"  i = insert mode",
						"  v = visual mode",
						"  x = visual block mode",
						"  t = terminal mode",
						"  o = operator-pending mode",
						"  c = command-line mode",
					}

					-- Add file content preview if it's from conf nvim
					if entry.source == "conf nvim" and entry.file ~= "native" then
						local file_path = vim.fn.stdpath("config") .. "/" .. entry.file
						local file_exists = vim.fn.filereadable(file_path) == 1

						if file_exists then
							table.insert(lines, "")
							table.insert(lines, "─────────────────────────────────────")
							table.insert(lines, "Source File Preview:")
							table.insert(lines, "")

							-- Read file and try to find the binding
							local f = io.open(file_path, "r")
							if f then
								local content = f:read("*all")
								f:close()

								-- Try to find relevant lines (simple search for the binding)
								for line in content:gmatch("[^\r\n]+") do
									if line:find(vim.pesc(entry.binding), 1, true) or line:find("keymap") then
										table.insert(lines, line)
									end
								end
							end
						end
					end

					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				-- Default action: open file or show help
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection.source == "conf nvim" and selection.file ~= "native" then
						local file_path = vim.fn.stdpath("config") .. "/" .. selection.file
						vim.cmd("vsplit " .. file_path)
						-- Try to search for the binding in the file
						vim.fn.search(vim.pesc(selection.binding))
					else
						vim.notify(
							"This is a native Vim binding. Use :help " .. selection.binding,
							vim.log.levels.INFO
						)
					end
				end)

				-- Toggle search mode with <C-t>
				map("i", "<C-t>", function()
					actions.close(prompt_bufnr)
					-- Toggle mode
					local new_mode = current_search_mode == "binding" and "function" or "binding"
					vim.notify(
						"Switched to search by " .. new_mode:upper(),
						vim.log.levels.INFO
					)
					-- Reopen picker with new mode
					vim.schedule(function()
						M.show_bindings(new_mode)
					end)
				end)

				map("n", "<C-t>", function()
					actions.close(prompt_bufnr)
					-- Toggle mode
					local new_mode = current_search_mode == "binding" and "function" or "binding"
					vim.notify(
						"Switched to search by " .. new_mode:upper(),
						vim.log.levels.INFO
					)
					-- Reopen picker with new mode
					vim.schedule(function()
						M.show_bindings(new_mode)
					end)
				end)

				return true
			end,
		})
		:find()
end

return M
