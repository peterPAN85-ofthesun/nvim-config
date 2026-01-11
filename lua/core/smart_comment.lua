-- Module de commentaires intelligents
local M = {}

-- Configuration des commentaires par langage
M.comment_config = {
	c = { line = "//", block_start = "/*", block_end = "*/" },
	cpp = { line = "//", block_start = "/*", block_end = "*/" },
	cs = { line = "//", block_start = "/*", block_end = "*/" },
	rust = { line = "//", block_start = "/*", block_end = "*/" },
	javascript = { line = "//", block_start = "/*", block_end = "*/" },
	typescript = { line = "//", block_start = "/*", block_end = "*/" },
	java = { line = "//", block_start = "/*", block_end = "*/" },
	python = { line = "#" },
	gdscript = { line = "#" },
	lua = { line = "--", block_start = "--[[", block_end = "]]" },
	sh = { line = "#" },
	bash = { line = "#" },
}

-- Récupère la config de commentaire pour le filetype actuel
local function get_comment_config()
	local ft = vim.bo.filetype
	return M.comment_config[ft] or { line = "#" }
end

-- Échappe les caractères spéciaux pour les patterns Lua
local function escape_pattern(str)
	return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- Détecte si une ligne est dans un commentaire de bloc (/* */ ou --[[ ]])
local function is_in_block_comment(line_content)
	local config = get_comment_config()
	if not config.block_start then
		return false
	end

	local block_start_esc = escape_pattern(config.block_start)
	local block_end_esc = escape_pattern(config.block_end)

	return line_content:match("^%s*" .. block_start_esc)
		or line_content:match("^%s*%*")
		or line_content:match("^%s*" .. block_end_esc)
end

-- Détecte si une ligne est un commentaire de ligne simple (//, #, --, etc.)
local function is_line_comment(line_content)
	local config = get_comment_config()
	local line_marker_esc = escape_pattern(config.line)
	return line_content:match("^%s*" .. line_marker_esc)
end

-- Trouve les limites d'un bloc de commentaires
local function find_block_comment_bounds(line_num)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local config = get_comment_config()

	if not config.block_start then
		return line_num, line_num
	end

	local block_start_esc = escape_pattern(config.block_start)
	local block_end_esc = escape_pattern(config.block_end)

	local start_line = line_num
	local end_line = line_num

	-- Cherche le début du bloc en remontant
	for i = line_num, 1, -1 do
		if lines[i]:match(block_start_esc) then
			start_line = i
			break
		end
		if not is_in_block_comment(lines[i]) then
			break
		end
	end

	-- Cherche la fin du bloc en descendant
	for i = line_num, #lines do
		if lines[i]:match(block_end_esc) then
			end_line = i
			break
		end
		if not is_in_block_comment(lines[i]) then
			break
		end
	end

	return start_line, end_line
end

-- Décommente une seule ligne dans un bloc de commentaires
function M.uncomment_line_in_block()
	local line_num = vim.fn.line(".")
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local current_line = lines[line_num]
	local config = get_comment_config()

	if not config.block_start then
		vim.notify("Ce langage ne supporte pas les commentaires de bloc", vim.log.levels.WARN)
		return
	end

	if not is_in_block_comment(current_line) then
		vim.notify("Cette ligne n'est pas dans un commentaire de bloc", vim.log.levels.WARN)
		return
	end

	local start_line, end_line = find_block_comment_bounds(line_num)

	-- Si c'est un bloc d'une seule ligne sur la même ligne (/* ... */)
	if start_line == end_line and current_line:match(escape_pattern(config.block_end)) then
		require("Comment.api").toggle.linewise.current()
		return
	end

	-- Extraction de la ligne du bloc
	local clean_line = current_line
	local block_start_esc = escape_pattern(config.block_start)
	local block_end_esc = escape_pattern(config.block_end)

	-- Enlève les marqueurs de début et fin
	clean_line = clean_line:gsub("^%s*" .. block_start_esc .. "%s?", "")
	clean_line = clean_line:gsub("^%s*" .. block_end_esc .. "%s?", "")
	clean_line = clean_line:gsub("^%s*%*%s?", "")

	-- Si la ligne devient vide après nettoyage, ne pas l'extraire
	if clean_line:match("^%s*$") then
		vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {})
		vim.notify("Ligne vide supprimée du bloc", vim.log.levels.INFO)
		return
	end

	-- Insère la ligne décommentée après le bloc
	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, { clean_line })
	-- Supprime l'ancienne ligne commentée
	vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {})

	vim.notify("Ligne extraite du bloc de commentaires", vim.log.levels.INFO)
end

-- Convertit des commentaires ligne adjacents en commentaire de bloc
function M.merge_to_block_comment()
	local config = get_comment_config()

	if not config.block_start then
		vim.notify("Ce langage ne supporte pas les commentaires de bloc", vim.log.levels.WARN)
		return
	end

	-- Mode visuel : récupère les lignes sélectionnées
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")

	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local line_marker_esc = escape_pattern(config.line)

	-- Enlève les commentaires de ligne de chaque ligne
	local clean_lines = {}
	for _, line in ipairs(lines) do
		local clean = line:gsub("^%s*" .. line_marker_esc .. "+%s?", "")
		table.insert(clean_lines, " * " .. clean)
	end

	-- Ajoute /* au début et */ à la fin
	table.insert(clean_lines, 1, config.block_start)
	table.insert(clean_lines, " " .. config.block_end)

	-- Remplace les lignes
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, clean_lines)

	vim.notify("Commentaires fusionnés en bloc", vim.log.levels.INFO)
end

-- Vérifie si les lignes adjacentes (avant/après) sont commentées
local function has_adjacent_comments(start_line, end_line)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- Vérifie la ligne avant
	if start_line > 1 then
		local prev_line = lines[start_line - 1]
		if is_line_comment(prev_line) or is_in_block_comment(prev_line) then
			return true, start_line - 1
		end
	end

	-- Vérifie la ligne après
	if end_line < #lines then
		local next_line = lines[end_line + 1]
		if is_line_comment(next_line) or is_in_block_comment(next_line) then
			return true, end_line + 1
		end
	end

	return false, nil
end

-- Toggle intelligent de commentaire
function M.smart_toggle()
	local mode = vim.fn.mode()
	local config = get_comment_config()

	-- En mode normal : toggle commentaire ligne
	if mode == "n" then
		local line_num = vim.fn.line(".")
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local current_line = lines[line_num]

		-- Si la ligne est dans un bloc de commentaire, décommenter tout le bloc
		if is_in_block_comment(current_line) then
			local start_line, end_line = find_block_comment_bounds(line_num)
			require("Comment.api").uncomment.linewise({ start_line, end_line })
			vim.notify("Bloc de commentaire décommenté", vim.log.levels.INFO)
		else
			-- Toggle commentaire ligne normal
			require("Comment.api").toggle.linewise.current()
		end
		return
	end

	-- En mode visuel (v, V, ou Ctrl-V)
	if mode == "v" or mode == "V" or mode == "\22" then -- \22 = Ctrl-V (visual block)
		-- Récupère les positions de la sélection visuelle
		local start_line = vim.fn.line("v")
		local end_line = vim.fn.line(".")

		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end

		local is_multi_line = (end_line - start_line) > 0

		-- Quitte le mode visuel
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

		-- Attends que le mode visuel soit quitté
		vim.schedule(function()
			-- Si multi-ligne et langage supporte blocs (C, C++, C#, etc.), commente en bloc
			if is_multi_line and config.block_start then
				require("Comment.api").toggle.blockwise({ start_line, end_line })
			else
				-- Sinon commente ligne par ligne
				require("Comment.api").toggle.linewise({ start_line, end_line })
			end
		end)
		return
	end
end

return M
