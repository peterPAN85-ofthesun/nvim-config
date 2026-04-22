return {
	"hiphish/rainbow-delimiters.nvim",
	config = function()
		local lib = require("rainbow-delimiters.lib")
		local orig_attach = lib.attach
		lib.attach = function(bufnr, lang)
			local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
			if not ok or not parser then
				return
			end
			orig_attach(bufnr, lang)
		end

		require("rainbow-delimiters.setup").setup({
			blacklist = { "alpha" },
		})
	end,
}
