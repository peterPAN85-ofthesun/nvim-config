-- On définit notre touche leader sur espace
vim.g.mapleader = " "

-- Raccourci pour la fonction set
local keymap = vim.keymap.set

-- on utilise ;; pour sortir du monde insertion
keymap("i", ";;", "<ESC>", { desc = "Sortir du mode insertion avec ;;" })

-- on efface le surlignage de la recherche
keymap("n", "<leader>nh", ":nohl<CR>", { desc = "Effacer le surlignage de la recherche" })

-- I déplace le texte sélectionné vers le haut en mode visuel (activé avec v)
keymap("v", "<S-i>", ":m .-2<CR>==", { desc = "Déplace le texte sélectionné vers le haut en mode visuel" })
-- K déplace le texte sélectionné vers le bas en mode visuel (activé avec v)
keymap("v", "<S-k>", ":m .+1<CR>==", { desc = "Déplace le texte sélectionné vers le bas en mode visuel" })

-- I déplace le texte sélectionné vers le haut en mode visuel bloc (activé avec V)
keymap("x", "<S-i>", ":move '<-2<CR>gv-gv", { desc = "Déplace le texte sélectionné vers le haut en mode visuel bloc" })
-- K déplace le texte sélectionné vers le bas en mode visuel (activé avec V)
keymap("x", "<S-k>", ":move '>+1<CR>gv-gv", { desc = "Déplace le texte sélectionné vers le bas en mode visuel bloc" })

-- Changement de fenêtre avec Ctrl + déplacement uniquement au lieu de Ctrl-w + déplacement
keymap("n", "<C-h>", "<C-w>h", { desc = "Déplace le curseur dans la fenêtre de gauche" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Déplace le curseur dans la fenêtre du bas" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Déplace le curseur dans la fenêtre du haut" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Déplace le curseur dans la fenêtre droite" })

-- Navigation entre les buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Terminal
keymap("n", "<leader>t", ":sp term://" .. (vim.env.SHELL or "bash") .. "<CR>", { desc = "Affiche le terminal de commande" })
keymap("t", "<ESC>", "<C-\\><C-n>", { desc = "Sort du terminal de commande" })

-- Terminal externe dans le répertoire de config Neovim
keymap("n", "<leader>T", function()
	local nvim_config_dir = vim.fn.stdpath("config")

	-- Liste de terminaux courants à essayer si $TERMINAL n'est pas défini
	local fallback_terminals = { "kitty", "alacritty", "wezterm", "konsole", "gnome-terminal", "xterm" }
	local terminal_cmd = vim.env.TERMINAL

	-- Si $TERMINAL n'est pas défini, chercher un terminal disponible
	if not terminal_cmd then
		for _, term in ipairs(fallback_terminals) do
			if vim.fn.executable(term) == 1 then
				terminal_cmd = term
				break
			end
		end
	end

	if not terminal_cmd then
		vim.notify("Aucun terminal trouvé. Définissez $TERMINAL ou installez un terminal.", vim.log.levels.ERROR)
		return
	end

	-- Extraire le nom du programme (avant le premier espace) pour le test d'exécutabilité
	local terminal_name = terminal_cmd:match("^(%S+)")

	if vim.fn.executable(terminal_name) == 1 then
		-- Découper la commande en arguments pour jobstart
		local cmd_parts = {}
		for part in terminal_cmd:gmatch("%S+") do
			table.insert(cmd_parts, part)
		end

		vim.fn.jobstart(cmd_parts, { cwd = nvim_config_dir, detach = true })
		vim.notify("Opening " .. terminal_cmd .. " in " .. nvim_config_dir, vim.log.levels.INFO)
	else
		vim.notify("Terminal not found: " .. terminal_name, vim.log.levels.ERROR)
	end
end, { desc = "Ouvrir le terminal par défaut dans ~/.config/nvim" })

-- Remplacer des caractères
keymap("n", "<leader>S", ":%s/<C-r><C-w>//gc<Left><Left><Left>",
	{ desc = "Remplacer caractères sans vérifications" })
keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>//gc<Left><Left><Left>", { desc = "Remplacer caractères" })

-- Bindings viewer - show all keybindings from binding_list.csv
keymap("n", "<leader>a", function()
	require("core.bindings_viewer").show_bindings()
end, { desc = "Find keybindings (search all bindings)" })

-- Update bindings from git diff
keymap("n", "<leader>bu", ":UpdateBindings<CR>", { desc = "Update binding_list.csv from git diff" })
