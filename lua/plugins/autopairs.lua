return {
	"windwp/nvim-autopairs",
	event = { "InsertEnter" },
	dependencies = {
		"hrsh7th/nvim-cmp",
	},
	config = function()
		-- import nvim-autopairs
		local autopairs = require("nvim-autopairs")

		-- configure autopairs
		autopairs.setup({
			check_ts = true, -- enable treesitter
			-- On NE laisse PAS autopairs mapper <CR> : c'est nvim-cmp qui possède la
			-- touche (voir nvim-cmp.lua). Sinon, selon l'ordre de chargement des deux
			-- plugins (tous deux sur InsertEnter), l'un écrase le <CR> de l'autre, ce
			-- qui casse soit la validation des complétions, soit l'expansion des {}.
			map_cr = false,
			disable_filetype = { "TelescopePrompt" },
			ts_config = {
				lua = { "string" },     -- don't add pairs in lua string treesitter nodes
				javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
				java = false,           -- don't check treesitter on java
			},
		})

		-- import nvim-autopairs completion functionality
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")

		-- import nvim-cmp plugin (completions plugin)
		local cmp = require("cmp")

		-- make autopairs and completion work together
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
