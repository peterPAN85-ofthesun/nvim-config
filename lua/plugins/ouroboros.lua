-- Plugin pour switcher entre header/source en C/C++
return {
	"jakemason/ouroboros",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<F4>", "<cmd>Ouroboros<CR>", desc = "Switch between header and source" },
	},
}
