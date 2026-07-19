return {
	"scottmckendry/cyberdream.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("cyberdream").setup({
			transparent = true,
			italic_comments = true,
			terminal_colors = true,
			-- Surcharges de highlights (reçoit la palette du thème -> survit au rechargement)
			overrides = function(colors)
				return {
					-- ── Séparateur de splits (vsp/sp) ─────────────────────────────
					-- Par défaut le thème utilise bg_highlight (#3c4048), quasi invisible
					-- avec transparent = true. On passe au cyan lumineux (#5ef1ff) +
					-- gras : séparation nette, dans la couleur signature de cyberdream.
					WinSeparator = { fg = colors.cyan, bg = "NONE", bold = true },
					VertSplit = { fg = colors.cyan, bg = "NONE", bold = true },

					-- ── Contraste de la syntaxe treesitter ────────────────────────
					-- Cyberdream ne définit AUCUN groupe treesitter `@…` : variables,
					-- champs, paramètres, ponctuation et délimiteurs héritent tous du
					-- blanc (Identifier/Delimiter = fg) -> code « plat ». On leur donne
					-- des couleurs distinctes pour mieux lire la structure du code.

					-- Ponctuation & délimiteurs -> gris : la structure recule derrière
					-- le contenu (les identifiants, eux, restent blancs).
					Delimiter = { fg = colors.grey },
					["@punctuation.delimiter"] = { fg = colors.grey },
					["@punctuation.bracket"] = { fg = colors.grey },

					-- Champs / propriétés / membres (obj.champ) -> cyan.
					["@property"] = { fg = colors.cyan },
					["@field"] = { fg = colors.cyan },
					["@variable.member"] = { fg = colors.cyan },

					-- Paramètres de fonction -> jaune + italique, distincts des locales.
					["@variable.parameter"] = { fg = colors.yellow, italic = true },

					-- Symboles intégrés (self, len(), int…) -> accentués.
					["@variable.builtin"] = { fg = colors.pink, italic = true },
					["@constant.builtin"] = { fg = colors.pink },
					["@function.builtin"] = { fg = colors.blue, italic = true },
					["@type.builtin"] = { fg = colors.purple, italic = true },
				}
			end,
		})
		vim.cmd("colorscheme cyberdream")
	end,
}
