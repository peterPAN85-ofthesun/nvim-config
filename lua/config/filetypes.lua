-- Détection de filetypes personnalisés
vim.filetype.add({
	extension = {
		gd = "gdscript",
	},
	pattern = {
		[".*%.gd"] = "gdscript",
	},
})
