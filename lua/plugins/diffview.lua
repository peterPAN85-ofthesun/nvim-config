return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	-- Lazy-load sur les commandes ; les keymaps (init) déclenchent le chargement
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewFileHistory",
		"DiffviewRefresh",
	},
	init = function()
		local keymap = vim.keymap
		keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview (diff / merge conflicts)" })
		keymap.set("n", "<leader>gx", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
		keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview file history (current)" })
		keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Diffview history (repo)" })
	end,
	opts = {
		enhanced_diff_hl = true,
		view = {
			-- Vue 3-way pour la résolution de conflits : OURS | base | THEIRS
			merge_tool = {
				layout = "diff3_mixed",
				disable_diagnostics = true,
			},
		},
	},
}
