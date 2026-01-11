return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local comment = require("Comment")
		local ft = require("Comment.ft")

		-- Configuration des commentaires par type de fichier
		comment.setup({
			-- Commentaires en mode normal et visuel
			padding = true, -- Ajoute un espace après le marqueur de commentaire
			sticky = true, -- Garde le curseur à sa position

			-- Ignore les lignes vides lors du commentaire en bloc
			ignore = "^$",

			-- DÉSACTIVE tous les mappings par défaut - on utilise nos propres
			toggler = {
				line = nil,
				block = nil,
			},

			opleader = {
				line = nil,
				block = nil,
			},

			-- Désactive tous les mappings automatiques
			mappings = {
				basic = false,
				extra = false,
			},
		})

		-- Configuration spécifique pour certains langages
		-- C#: commentaires ligne // et bloc /* */
		ft.set("cs", { "//%s", "/*%s*/" })
		ft.set("c", { "//%s", "/*%s*/" })
		ft.set("cpp", { "//%s", "/*%s*/" })

		-- GDScript: commentaire ligne uniquement
		ft.set("gdscript", "#%s")

		-- Python: commentaire ligne uniquement
		ft.set("python", "#%s")

		-- Rust
		ft.set("rust", { "//%s", "/*%s*/" })

		-- JavaScript/TypeScript
		ft.set("javascript", { "//%s", "/*%s*/" })
		ft.set("typescript", { "//%s", "/*%s*/" })

		-- Keybindings pour le commentaire intelligent
		local keymap = vim.keymap.set
		local api = require("Comment.api")

		-- Mode normal : gcc (toggle ligne)
		keymap("n", "gcc", function()
			require("core.smart_comment").smart_toggle()
		end, { desc = "Toggle commentaire ligne/bloc", noremap = true, silent = true })

		-- Mode visuel : gc - Utilise directement l'API avec '<,'> range
		keymap("x", "gc", ":<C-u>lua require('core.comment_helper').visual_comment()<CR>", { desc = "Toggle commentaire (visuel)", noremap = true, silent = true })

		-- EXCEPTION : Décommenter UNE seule ligne d'un bloc de commentaire
		keymap("n", "gC", function()
			require("core.smart_comment").uncomment_line_in_block()
		end, { desc = "Décommenter UNE ligne d'un bloc de commentaire", noremap = true, silent = true })
	end,
}
