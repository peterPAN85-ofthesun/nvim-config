local M = {}

function M.implement_current_method()
	local status, err = pcall(function()
		local line = vim.api.nvim_get_current_line() or ""

		-- Nettoyage des mots-clés et valeurs par défaut
		local cleaned_line = line:gsub("%s*;?$", "")
		cleaned_line = cleaned_line:gsub("%s*override", "")
		cleaned_line = cleaned_line:gsub("%s*virtual", "")
		cleaned_line = cleaned_line:gsub("%s*explicit", "")
		cleaned_line = cleaned_line:gsub("%s*final", "")
		cleaned_line = cleaned_line:gsub("=%s*[^,)]+", "")

		local header_file = vim.fn.expand("%:t")
		local class_name = vim.fn.expand("%:t:r")
		local ext = vim.fn.expand("%:e")
		local cpp_ext = (ext == "hpp" or ext == "h") and "cpp" or "c"
		local cpp_file = vim.fn.expand("%:p:h") .. "/" .. class_name .. "." .. cpp_ext

		local buf_found, win_found
		local cpp_exists = vim.fn.filereadable(cpp_file) == 1

		-- Vérifie si le fichier est déjà ouvert
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local name = vim.api.nvim_buf_get_name(buf) or ""
			if name == cpp_file then
				buf_found = buf
				win_found = win
				break
			end
		end

		if buf_found then
			vim.api.nvim_set_current_win(win_found)
		else
			if cpp_exists then
				vim.cmd("edit " .. cpp_file)
				buf_found = vim.api.nvim_get_current_buf()
			else
				local choice = (vim.fn.input("Fichier " .. cpp_file .. " n'existe pas. Le créer ? (y/n) ") or ""):lower()
				if choice ~= "y" then
					vim.notify("Annulé", vim.log.levels.INFO)
					return
				end
				vim.cmd("edit " .. cpp_file)
				buf_found = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_set_lines(buf_found, 0, 0, false, { '#include "' .. header_file .. '"' })
			end
		end

		-- Indentation
		local indent = vim.o.expandtab and string.rep(" ", vim.o.shiftwidth) or "\t"
		local impl_line = cleaned_line:gsub("([%w_]+)%s*%(", class_name .. "::%1(")

		-- Vérifie si la méthode existe déjà
		local cpp_lines = vim.api.nvim_buf_get_lines(buf_found, 0, -1, false)
		for _, l in ipairs(cpp_lines) do
			if l:find(impl_line, 1, true) then
				vim.notify("Méthode déjà implémentée dans " .. cpp_file, vim.log.levels.INFO)
				return
			end
		end

		-- Insérer l'implémentation avec accolades
		local line_count = vim.api.nvim_buf_line_count(buf_found)
		local lines_to_insert = { "", impl_line .. " {", indent .. "", "}" }
		vim.api.nvim_buf_set_lines(buf_found, line_count, line_count, false, lines_to_insert)

		-- Curseur sur la ligne vide à l’intérieur des accolades, après indentation
		vim.api.nvim_win_set_cursor(0, { line_count + 3, #indent })

		-- Mode insertion
		vim.cmd("startinsert")
	end)

	if not status then
		vim.notify("Erreur implement_current_method : " .. tostring(err), vim.log.levels.ERROR)
	end
end

-- Mapping F3
vim.keymap.set("n", "<F3>", M.implement_current_method, { desc = "Implement method under cursor in cpp/c" })

return M
