return {
	"s1n7ax/nvim-window-picker",
	name = "window-picker",
	event = "VeryLazy",
	version = "2.*",
	config = function()
		require("window-picker").setup({
			hint = "floating-big-letter",
			selection_chars = "1234567890",
			show_prompt = true,
			prompt_message = "Choisissez une fenêtre: ",
			filter_rules = {
				autoselect_one = true,
				include_current_win = false,
				bo = {
					filetype = { "NvimTree", "neo-tree", "notify" },
					buftype = { "terminal", "quickfix" },
				},
			},
			-- Grandes lettres flottantes au centre de chaque fenêtre
		})
	end,
}
