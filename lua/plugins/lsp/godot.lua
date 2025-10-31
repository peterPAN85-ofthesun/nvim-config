-- Configuration LSP pour Godot (GDScript et C#)
return {
	"neovim/nvim-lspconfig",
	opts = {
		servers = {
			-- GDScript LSP (intégré dans l'éditeur Godot)
			gdscript = {
				-- Le serveur LSP GDScript tourne dans l'éditeur Godot
				-- Par défaut sur le port 6005
				cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
				root_dir = function(fname)
					local lspconfig = require("lspconfig")
					-- Cherche le fichier project.godot à la racine
					return lspconfig.util.root_pattern("project.godot")(fname)
				end,
				filetypes = { "gd", "gdscript", "gdscript3" },
				on_attach = function(client, bufnr)
					-- Configuration spécifique pour GDScript si nécessaire
					vim.api.nvim_buf_set_option(bufnr, "tabstop", 4)
					vim.api.nvim_buf_set_option(bufnr, "shiftwidth", 4)
					-- GDScript utilise des tabs
					vim.api.nvim_buf_set_option(bufnr, "expandtab", false)
				end,
			},

			-- C# LSP (OmniSharp) pour Godot
			omnisharp = {
				-- OmniSharp sera installé via Mason
				cmd = { "omnisharp" },
				root_dir = function(fname)
					local lspconfig = require("lspconfig")
					-- Cherche .sln, .csproj ou project.godot
					return lspconfig.util.root_pattern("*.sln", "*.csproj", "project.godot")(fname)
				end,
				filetypes = { "cs" },
				enable_roslyn_analyzers = true,
				enable_import_completion = true,
				organize_imports_on_format = true,
				enable_decompilation_support = true,
				settings = {
					FormattingOptions = {
						-- Utilise les conventions C# de Godot
						EnableEditorConfigSupport = true,
						OrganizeImports = true,
					},
					RoslynExtensionsOptions = {
						EnableAnalyzersSupport = true,
						EnableImportCompletion = true,
						AnalyzeOpenDocumentsOnly = false,
					},
					Sdk = {
						IncludePrereleases = false,
					},
				},
				on_attach = function(client, bufnr)
					-- Configuration spécifique pour C# Godot
					vim.api.nvim_buf_set_option(bufnr, "tabstop", 4)
					vim.api.nvim_buf_set_option(bufnr, "shiftwidth", 4)
					vim.api.nvim_buf_set_option(bufnr, "expandtab", false)
				end,
			},
		},
	},
}
