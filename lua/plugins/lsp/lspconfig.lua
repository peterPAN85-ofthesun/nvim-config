local signature_index = {}
local signatures = {}

-- Fonction pour générer la proposition suivante (compatible tous LSP)
local function show_signature_next()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local active_client = nil

	-- Trouver un client LSP actif avec signatureHelpProvider
	for _, client in pairs(clients) do
		if client.server_capabilities.signatureHelpProvider then
			active_client = client
			break
		end
	end

	if not active_client then
		-- Fallback sur hover si pas de signature help
		vim.lsp.buf.hover()
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local client_name = active_client.name

	-- Initialiser l'index pour ce client si nécessaire
	if not signature_index[client_name] then
		signature_index[client_name] = 0
	end

	local params = vim.lsp.util.make_position_params()

	active_client.request("textDocument/signatureHelp", params, function(err, result)
		if err or not result or not result.signatures or #result.signatures == 0 then
			-- Fallback sur hover si pas de signatures
			vim.lsp.buf.hover()
			return
		end

		signatures[client_name] = result.signatures
		signature_index[client_name] = (signature_index[client_name] % #result.signatures) + 1

		local sig = signatures[client_name][signature_index[client_name]]
		local lines = {}

		-- Ajout du compteur (index / total)
		table.insert(lines, string.format("(%d/%d)", signature_index[client_name], #signatures[client_name]))

		-- Label de la fonction
		table.insert(lines, sig.label)

		-- Documentation de la fonction
		if sig.documentation then
			if type(sig.documentation) == "string" then
				table.insert(lines, sig.documentation)
			elseif sig.documentation.value then
				table.insert(lines, sig.documentation.value)
			end
		end

		-- Documentation des paramètres
		if sig.parameters then
			for i, param in ipairs(sig.parameters) do
				if param.documentation then
					local doc = type(param.documentation) == "string" and param.documentation or param.documentation.value
					table.insert(lines, string.format("Param %s: %s", param.label or i, doc))
				end
			end
		end

		vim.lsp.util.open_floating_preview(lines, "markdown", { border = "rounded" })
	end, bufnr)
end


return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- Va permettre de remplir le plugin de complétion automatique nvim-cmp
		-- avec les résultats des LSP
		"hrsh7th/cmp-nvim-lsp",
		-- Ajoute les « code actions » de type renommage de fichiers intelligent, etc
		{ "antosha417/nvim-lsp-file-operations", config = true },
		-- Utile pour éditer les fichiers lua spécifiques à la config neovim
		-- Notamment pour éviter le "Undefined global `vim`"
		{ "folke/lazydev.nvim",                  opts = {} },
	},
	keys = {
		{ "<leader>ca", vim.lsp.buf.code_action,                   desc = "Code Action",                mode = { "n", "v" } },
		{ "gR",         "<cmd>Telescope lsp_references<CR>",       desc = "Show LSP references",        mode = "n" },
		{ "gD",         vim.lsp.buf.declaration,                   desc = "Go to declaration",          mode = "n" },
		{ "gd",         "<cmd>Telescope lsp_definitions<CR>",      desc = "Show LSP definitions",       mode = "n" },
		{ "gi",         "<cmd>Telescope lsp_implementations<CR>",  desc = "Show LSP implementations",   mode = "n" },
		{ "gt",         "<cmd>Telescope lsp_type_definitions<CR>", desc = "Show LSP type definitions",  mode = "n" },
		{ "gO",         "<cmd>Telescope lsp_document_symbols<CR>", desc = "Show LSP documents symbols", mode = "n" },
		{ "gs",         vim.lsp.buf.signature_help,                desc = "Show LSP signature help",    mode = "n" },
		{ "<leader>rn", vim.lsp.buf.rename,                        desc = "Smart rename",               mode = "n" },
		{ "<leader>D",  "<cmd>Telescope diagnostics bufnr=0<CR>",  desc = "Show buffer diagnostics",    mode = "n" },
		{ "<leader>d",  vim.diagnostic.open_float,                 desc = "Show line diagnostics",      mode = "n" },
		{
			"[d",
			function()
				vim.diagnostic.jump({ count = -1, float = true })
			end,
			desc = "Go to previous diagnostic",
			mode = "n",
		},
		{
			"]d",
			function()
				vim.diagnostic.jump({ count = 1, float = true })
			end,
			desc = "Go to next diagnostic",
			mode = "n",
		},
		{ "K",          show_signature_next,                               desc = "Show documentation for what is under cursor",     mode = "n" },
		{ "<leader>K",  vim.lsp.buf.hover,                                 desc = "Show documentation for what is under the cursor", mode = "n" },
		{ "<leader>F",  "<cmd>lua vim.lsp.buf.format({async = true})<cr>", desc = "Format buffer",                                   mode = { "n", "x" } },
		{ "<leader>rs", ":LspRestart<CR>",                                 desc = "Restart LSP",                                     mode = "n" },
	},








	opts = {
		servers = {
			-- Ensure mason installs the server
			clangd = {
				keys = {
					{ "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
				},
				root_markers = {
					"compile_commands.json",
					"compile_flags.txt",
					"configure.ac", -- AutoTools
					"Makefile",
					"configure.ac",
					"configure.in",
					"config.h.in",
					"meson.build",
					"meson_options.txt",
					"build.ninja",
					".git",
				},
				capabilities = {
					offsetEncoding = { "utf-16" },
				},
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--all-scopes-completion",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
			},
		},
		setup = {
			clangd = function(_, opts)
				local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
				require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
				return false
			end,
		},
	},






	config = function()
		-- Customize error signs
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.INFO] = "",
					[vim.diagnostic.severity.HINT] = "󰌵",
				},
			},
		})
		-- Python LSP (pylsp)
		vim.lsp.config("pylsp", {
			cmd = { "pylsp" },
			root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
			settings = {
				pylsp = {
					plugins = {
						-- formatter options
						black = { enabled = true },
						autopep8 = { enabled = false },
						yapf = { enabled = false },
						-- linter options
						pyflakes = { enabled = false },
						pycodestyle = {
							enabled = true,
							ignore = { "E501" },
						},
						-- type checker
						pylsp_mypy = { enabled = true },
						-- auto-completion options
						jedi_completion = { fuzzy = true },
						-- import sorting
						pylsp_isort = { enabled = true },
						rope_completion = { enabled = true },
						rope_autoimport = {
							enabled = true,
						},
					},
				},
			},
		})

		-- Ruff LSP (Python linter/formatter)
		vim.lsp.config("ruff", {
			cmd = { "ruff", "server" },
			root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
			init_options = {
				settings = {
					-- Arguments par défaut de la ligne de commande ruff
					-- (on ajoute les warnings pour le tri des imports)
					args = { "--extend-select", "I" },
				},
			},
		})

		-- Rust Analyzer
		vim.lsp.config("rust_analyzer", {
			cmd = { "rust-analyzer" },
			root_markers = { "Cargo.toml", "rust-project.json" },
			settings = {
				["rust-analyzer"] = {
					check = {
						command = "clippy",
					},
					inlayHints = {
						renderColons = true,
						typeHints = {
							enable = true,
							hideClosureInitialization = false,
							hideNamedConstructor = false,
						},
					},
					diagnostics = {
						enable = true,
						styleLints = {
							enable = true,
						},
					},
				},
			},
		})

		-- Omnisharp LSP (C#)
		vim.lsp.config("omnisharp", {
			cmd = { "omnisharp" },
			root_markers = {
				"*.sln",
				"*.csproj",
				"omnisharp.json",
				"function.json",
				".git",
			},
			settings = {
				FormattingOptions = {
					EnableEditorConfigSupport = true,
					OrganizeImports = true,
				},
				RoslynExtensionsOptions = {
					EnableAnalyzersSupport = true,
					EnableImportCompletion = true,
					AnalyzeOpenDocumentsOnly = false,
				},
			},
		})

		-- GDScript LSP (connecté à Godot Editor)
		local util = require("lspconfig.util")

		-- Obtenir les capabilities de nvim-cmp pour l'autocomplétion intelligente
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
		if has_cmp then
			capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
		end

		-- Activer automatiquement les LSP pour les bons filetypes
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "python",
			callback = function()
				vim.lsp.enable("pylsp")
				vim.lsp.enable("ruff")
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "rust",
			callback = function()
				vim.lsp.enable("rust_analyzer")
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "cs",
			callback = function()
				vim.lsp.enable("omnisharp")
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "gdscript",
			callback = function(ev)
				-- Vérifier que project.godot existe dans les répertoires parents
				local root = util.root_pattern("project.godot")(ev.file)
				if not root then
					return
				end

				-- Démarrer le LSP Godot
				vim.lsp.start({
					name = "gdscript",
					cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
					root_dir = root,
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						-- Configuration spécifique pour GDScript
						vim.bo[bufnr].tabstop = 4
						vim.bo[bufnr].shiftwidth = 4
						vim.bo[bufnr].expandtab = false
					end,
				})
			end,
		})
	end,
}
