return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		-- Installe automatiquement les outils non-LSP (formatters, linters, parsers)
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import de mason
		local mason = require("mason")

		-- import de mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		-- import de mason-tool-installer (formatters, linters, etc.)
		local mason_tool_installer = require("mason-tool-installer")

		-- Ajoute le chemin bin de Mason au PATH (netcoredbg pour le debug C# de godotdev.nvim, etc.)
		local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
		vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

		-- Active mason et personnalise les icônes
		mason.setup({
			-- Le registre communautaire fournit "roslyn" (LSP C#) et "rzls", absents du registre par défaut.
			registries = {
				"github:mason-org/mason-registry",
				"github:Crashdummyy/mason-registry",
			},
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- Liste des serveurs à installer par défaut
			-- List des serveurs possibles : https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			-- Vous pouvez ne pas en mettre ici et tout installer en utilisant :Mason
			-- Mais au lieu de passer par :Mason pour installer, je vous recommande d'ajouter une entrée à cette liste
			-- Ça permettra à votre configuration d'être plus portable
			ensure_installed = {
				"cssls",
				"elmls",
				"graphql",
				"html",
				"lua_ls",
				"pylsp",
				"ruff",
				"rust_analyzer",
				"sqlls",
				"svelte",
				"ts_ls",
				"yamlls",
				"clangd",
			},
			-- roslyn.nvim démarre lui-même le serveur C# : on empêche mason-lspconfig
			-- d'activer automatiquement un éventuel omnisharp résiduel (incompatible avec Neovim).
			automatic_enable = {
				exclude = { "omnisharp" },
			},
		})

		-- Outils non gérés par mason-lspconfig (formatters, linters, parsers).
		-- mason-tool-installer les installe automatiquement au démarrage.
		-- mason/bin est déjà ajouté au PATH plus haut, donc leurs binaires deviennent disponibles.
		mason_tool_installer.setup({
			ensure_installed = {
				-- Formatters (cf. lua/plugins/conform.lua)
				"prettier", -- css, html, json, markdown, yaml, js/ts, svelte, graphql
				"stylua", -- lua
				"elm-format", -- elm
				"csharpier", -- C# (projets Godot)
				"gdtoolkit", -- fournit gdformat (+ gdlint) pour GDScript
				-- Serveurs / outils divers
				"roslyn", -- LSP C# (registre communautaire), démarré ensuite par roslyn.nvim
				"tree-sitter-cli", -- requis par nvim-treesitter (branche main) pour compiler les parsers
			},
			-- Lance l'installation automatiquement au démarrage de Neovim
			run_on_start = true,
		})
	end,
}
