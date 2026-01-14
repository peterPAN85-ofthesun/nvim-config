return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false, -- nvim-treesitter ne supporte pas le lazy-loading
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		-- Configuration de base de treesitter
		configs.setup({
			-- Installation automatique des parsers
			ensure_installed = {
				"bash",
				"c",
				"c_sharp", -- C# pour Godot
				"cpp",
				"dockerfile",
				"gdscript", -- GDScript pour Godot
				"gitignore",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"rst",
				"rust",
				"typescript",
				"vim",
				"yaml",
			},
			-- Installer automatiquement les parsers manquants lors de l'ouverture de fichiers
			auto_install = true,
			-- Configuration du highlighting
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			-- Configuration de l'indentation
			indent = {
				enable = true,
			},
		})
	end,
}
