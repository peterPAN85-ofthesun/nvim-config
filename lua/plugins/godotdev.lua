return {
	"Mathijs-Bakker/godotdev.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		"rcarriga/nvim-dap-ui",
		"nvim-treesitter/nvim-treesitter",
	},
	lazy = false, -- Charger immédiatement au démarrage
	config = function(_, opts)
		require("godotdev").setup(opts)
	end,
	opts = {
		-- Configuration de base
		editor_host = "127.0.0.1",
		editor_port = 6005, -- Port LSP GDScript
		debug_port = 6006, -- Port de débogage

		-- Activer le support C#
		csharp = true,

		-- Auto-démarrer le serveur d'édition Neovim
		autostart_editor_server = false,

		-- Configuration des indentations Godot (4 espaces, pas de tabs)
		indentation = {
			gdscript = {
				tabstop = 4,
				shiftwidth = 4,
				expandtab = false,
			},
			csharp = {
				tabstop = 4,
				shiftwidth = 4,
				expandtab = false,
			},
		},
	},
}
