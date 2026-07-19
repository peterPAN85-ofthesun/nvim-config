return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		-- Guides d'indentation discrets (couleur IblIndent, voir cyberdream.lua)
		indent = { char = "┊" },
		-- Surligne le bloc/scope sous le curseur d'une couleur contrastée (IblScope)
		-- + souligne la ligne d'ouverture et de fermeture du bloc.
		scope = {
			enabled = true,
			show_start = true,
			show_end = true,
		},
	},
}
