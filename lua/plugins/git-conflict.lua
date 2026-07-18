return {
	"akinsho/git-conflict.nvim",
	version = "*",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		-- On définit nos propres mappings pour ne pas écraser `ct`/`co` natifs
		default_mappings = false,
		disable_diagnostics = true,
	},
	config = function(_, opts)
		require("git-conflict").setup(opts)

		local keymap = vim.keymap
		-- Choix de résolution inline (sur un conflit)
		keymap.set("n", "<leader>go", "<cmd>GitConflictChooseOurs<cr>", { desc = "Conflict: choose ours" })
		keymap.set("n", "<leader>gt", "<cmd>GitConflictChooseTheirs<cr>", { desc = "Conflict: choose theirs" })
		keymap.set("n", "<leader>gb", "<cmd>GitConflictChooseBoth<cr>", { desc = "Conflict: choose both" })
		keymap.set("n", "<leader>g0", "<cmd>GitConflictChooseNone<cr>", { desc = "Conflict: choose none" })
		keymap.set("n", "<leader>gl", "<cmd>GitConflictListQf<cr>", { desc = "Conflict: list in quickfix" })
		-- Navigation entre conflits
		keymap.set("n", "]x", "<cmd>GitConflictNextConflict<cr>", { desc = "Next git conflict" })
		keymap.set("n", "[x", "<cmd>GitConflictPrevConflict<cr>", { desc = "Prev git conflict" })
	end,
}
