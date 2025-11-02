return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	opts = {
		current_only = false,
		winblend = 50, -- Transparence de la scrollbar (0-100, 0 = opaque)
		zindex = 40,
		excluded_filetypes = {
			"prompt",
			"TelescopePrompt",
			"noice",
			"notify",
			"neo-tree",
			"NvimTree",
		},
		width = 2, -- Largeur de la scrollbar en colonnes
		handlers = {
			cursor = {
				enable = true,
				-- Symboles pour montrer la position du curseur
				symbols = { "⎺", "⎻", "⎼", "⎽" },
			},
			diagnostic = {
				enable = true,
				signs = { "-", "=", "≡" }, -- Symboles pour les diagnostics
				min_severity = vim.diagnostic.severity.HINT,
			},
			gitsigns = {
				enable = true,
				signs = {
					add = "│",
					change = "│",
					delete = "-",
				},
			},
			marks = {
				enable = true,
				show_builtins = false, -- Affiche les marks builtin (', ", etc)
				key = "m", -- Préfixe pour les marks à afficher
			},
			quickfix = {
				enable = true,
				signs = { "-", "=", "≡" },
			},
			search = {
				enable = true,
			},
		},
	},
}
