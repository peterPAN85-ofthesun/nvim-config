return {
	"nvim-treesitter/nvim-treesitter",
	-- Branche "main" : la branche "master" est gelée et ne supporte pas Neovim 0.12
	-- (erreur treesitter "attempt to call method 'range'" sur les injections markdown).
	branch = "main",
	lazy = false, -- nvim-treesitter ne supporte pas le lazy-loading
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup()

		-- Branche main : installation explicite des parsers (plus de auto_install ni highlight/indent dans setup)
		require("nvim-treesitter").install({
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
		})

		-- Activer highlighting + indentation treesitter dès qu'un parser est disponible pour le filetype
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				-- vim.treesitter.start() échoue si aucun parser n'existe pour ce filetype : on protège l'appel
				if not pcall(vim.treesitter.start) then
					return
				end
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
