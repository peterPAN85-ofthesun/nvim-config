return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
	},
	config = function()
		-- import de mason
		local mason = require("mason")

		-- import de mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

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

		-- Paquets non gérés par mason-lspconfig, installés directement via le registre Mason :
		--   - roslyn         : LSP C# (inclus projets Godot), détecté ensuite par roslyn.nvim
		--   - tree-sitter-cli: requis par nvim-treesitter (branche main) pour compiler les parsers
		-- mason/bin est déjà ajouté au PATH plus haut, donc le binaire "tree-sitter" devient disponible.
		local registry = require("mason-registry")
		local function ensure_tools()
			for _, name in ipairs({ "roslyn", "tree-sitter-cli" }) do
				local ok, pkg = pcall(registry.get_package, name)
				if ok and not pkg:is_installed() then
					pkg:install()
				end
			end
		end
		if registry.refresh then
			registry.refresh(ensure_tools)
		else
			ensure_tools()
		end
	end,
}
