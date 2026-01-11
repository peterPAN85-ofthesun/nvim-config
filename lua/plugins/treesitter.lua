return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false, -- nvim-treesitter ne supporte pas le lazy-loading
	build = ":TSUpdate",
	config = function()
		local treesitter = require("nvim-treesitter")

		-- Configuration de base de treesitter
		treesitter.setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		-- Installation des parsers
		local parsers = {
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
		}
		treesitter.install(parsers)

		-- Activation automatique du highlighting treesitter pour les langages supportés
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"bash",
				"c",
				"cpp",
				"c_sharp",
				"dockerfile",
				"gdscript",
				"gitignore",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"python",
				"rst",
				"rust",
				"typescript",
				"vim",
				"yaml",
			},
			callback = function()
				-- Active le highlighting treesitter (avec gestion d'erreur)
				local ok, err = pcall(vim.treesitter.start)
				if not ok then
					-- Silencieusement ignorer si le parser n'existe pas
					return
				end

				-- Active l'indentation treesitter (expérimental) uniquement pour certains langages
				local indent_langs = { "python", "lua", "javascript", "typescript", "rust", "c", "cpp" }
				if vim.tbl_contains(indent_langs, vim.bo.filetype) then
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
