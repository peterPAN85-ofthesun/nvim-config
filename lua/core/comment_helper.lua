-- Helper pour gérer les commentaires en mode visuel
local M = {}

-- Vérifie si un bloc est déjà commenté (/* ... */)
local function is_block_commented(start_line, end_line)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- Vérifie la ligne avant le début
	if start_line > 1 then
		local prev_line = lines[start_line - 1]
		if prev_line:match("^%s*/%*%s*$") then
			-- Vérifie la ligne après la fin
			if end_line < #lines then
				local next_line = lines[end_line + 1]
				if next_line:match("^%s*%*/%s*$") then
					return true
				end
			end
		end
	end

	return false
end

function M.visual_comment()
	-- Récupère les marks de la dernière sélection visuelle
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")

	-- Vérifie le filetype
	local ft = vim.bo.filetype
	local has_block = (ft == "c" or ft == "cpp" or ft == "cs" or ft == "rust"
		or ft == "javascript" or ft == "typescript" or ft == "java")

	-- Détermine si multi-ligne
	local is_multi_line = (end_line - start_line) > 0

	-- Si multi-ligne et langage supporte blocs : commentaire personnalisé
	if is_multi_line and has_block then
		-- Vérifie si déjà commenté
		if is_block_commented(start_line, end_line) then
			-- Décommente : supprime les lignes /* et */
			vim.api.nvim_buf_set_lines(0, end_line, end_line + 1, false, {}) -- Supprime */
			vim.api.nvim_buf_set_lines(0, start_line - 2, start_line - 1, false, {}) -- Supprime /*
		else
			-- Commente : insère /* avant et */ après
			local indent = vim.fn.indent(start_line)
			local indent_str = string.rep(" ", indent)

			-- Insère */ après la sélection
			vim.api.nvim_buf_set_lines(0, end_line, end_line, false, { indent_str .. "*/" })
			-- Insère /* avant la sélection
			vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, { indent_str .. "/*" })
		end
	else
		-- Commentaire ligne par ligne pour les autres cas
		vim.api.nvim_win_set_cursor(0, { start_line, 0 })
		local api = require("Comment.api")
		local count = end_line - start_line + 1
		api.toggle.linewise.count(count)
	end
end

return M
