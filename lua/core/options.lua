local opt = vim.opt -- raccourci pour un peu plus de concision

-- numéros de ligne
-- opt.relativenumber = true -- affichage des numéros de ligne relatives à la position actuelle du curseur
opt.number = true -- affiche le numéro absolu de la ligne active lorsque que relativenumber est activé

-- tabs & indentation
opt.tabstop = 2       -- 2 espaces pour les tabulations
opt.shiftwidth = 2    -- 2 espaces pour la taille des indentations
opt.expandtab = false -- change les tabulations en espaces (don't feed the troll please ;) )
opt.autoindent = true -- on garde l'indentation actuelle à la prochaine ligne

-- recherche
opt.ignorecase = true -- ignore la casse quand on recherche
opt.smartcase = true  -- sauf quand on fait une recherche avec des majuscules, on rebascule en sensible à la casse
opt.hlsearch = true   -- surlignage de toutes les occurences de la recherche en cours

-- ligne du curseur
opt.cursorline = true -- surlignage de la ligne active

-- apparence

-- termguicolors est nécessaire pour que les thèmes modernes fonctionnent
opt.termguicolors = true
opt.background = "dark" -- dark ou light en fonction de votre préférence
opt.signcolumn = "yes"  -- affiche une colonne en plus à gauche pour afficher les signes (évite de décaler le texte)

-- retour
opt.backspace = "indent,eol,start" -- on autorise l'utilisation de retour quand on indente, à la fin de ligne ou au début

-- presse papier
opt.clipboard = "unnamedplus" -- on utilise le presse papier du système par défaut

-- Configuration explicite du provider clipboard
-- Détection automatique de l'environnement (Wayland ou X11)
local function setup_clipboard()
	-- Détecte le socket Wayland disponible
	local uid = vim.loop.getuid()
	local wayland_socket = vim.fn.glob("/run/user/" .. uid .. "/wayland-*")
	if wayland_socket ~= "" then
		-- Extrait le nom du socket (ex: wayland-1)
		local socket_name = vim.fn.fnamemodify(wayland_socket, ":t"):gsub("%.lock$", "")
		if not socket_name:match("%.lock$") then
			vim.env.WAYLAND_DISPLAY = socket_name
		end
	end

	-- Configure le provider en fonction de l'environnement
	if vim.env.WAYLAND_DISPLAY then
		-- Wayland avec wl-clipboard
		vim.g.clipboard = {
			name = "wl-clipboard",
			copy = {
				["+"] = "wl-copy",
				["*"] = "wl-copy",
			},
			paste = {
				["+"] = "wl-paste --no-newline",
				["*"] = "wl-paste --no-newline",
			},
			cache_enabled = 1,
		}
	elseif vim.env.DISPLAY then
		-- X11 avec xclip
		vim.g.clipboard = {
			name = "xclip",
			copy = {
				["+"] = "xclip -quiet -i -selection clipboard",
				["*"] = "xclip -quiet -i -selection primary",
			},
			paste = {
				["+"] = "xclip -o -selection clipboard",
				["*"] = "xclip -o -selection primary",
			},
			cache_enabled = 1,
		}
	end
end

setup_clipboard()

-- split des fenêtres
opt.splitright = true     -- le split vertical d'une fenêtre s'affiche à droite
opt.splitbelow = true     -- le split horizontal d'une fenêtre s'affiche en bas

-- Caractères de séparation des fenêtres : traits pleins et continus.
-- La *couleur* du séparateur est définie par WinSeparator (voir cyberdream.lua).
opt.fillchars = {
	vert = "│",       -- séparateur des splits verticaux (vsp)
	horiz = "─",      -- séparateur des splits horizontaux (sp)
	horizup = "┴",
	horizdown = "┬",
	vertleft = "┤",
	vertright = "├",
	verthoriz = "┼",
	eob = " ",        -- masque les « ~ » des lignes vides en fin de buffer
}

opt.swapfile = false      -- on supprime le pénible fichier de swap

opt.undofile = true       -- on autorise l'undo à l'infini (même quand on revient sur un fichier qu'on avait fermé)

opt.iskeyword:append("-") -- on traite les mots avec des - comme un seul mot

-- affichage des caractères spéciaux
opt.list = true
opt.listchars:append({ nbsp = "␣", trail = "•", precedes = "«", extends = "»", tab = "> " })

-- désactivation des providers non utilisés
vim.g.loaded_perl_provider = 0 -- désactive le provider Perl (rarement utilisé)
