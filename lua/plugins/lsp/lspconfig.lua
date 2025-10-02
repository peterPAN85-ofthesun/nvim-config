local signature_index = 0
local signatures = {}


-- Fonction pour générer la proposition suivante
local function show_signature_next()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local clangd_client = nil

	for _, client in pairs(clients) do
		if client.name == "clangd" and client.server_capabilities.signatureHelpProvider then
			clangd_client = client
			break
		end
	end

	if not clangd_client then
		vim.notify("No clangd LSP client attached to this buffer", vim.log.levels.WARN)
		return
	end

	local params = vim.lsp.util.make_position_params()

	clangd_client.request("textDocument/signatureHelp", params, function(err, result)
		if err or not result or not result.signatures or #result.signatures == 0 then
			vim.notify("No signatures available", vim.log.levels.INFO)
			return
		end

		signatures = result.signatures
		signature_index = (signature_index % #signatures) + 1

		local sig = signatures[signature_index]
		local lines = {}

		-- ✅ Ajout du compteur (index / total)
		table.insert(lines, string.format("(%d/%d)", signature_index, #signatures))

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
	end, 0)
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
		{ "<leader>ca", vim.lsp.buf.code_action,                   desc = "Code Action",               mode = { "n", "v" } },
		{ "gR",         "<cmd>Telescope lsp_references<CR>",       desc = "Show LSP references",       mode = "n" },
		{ "gD",         vim.lsp.buf.declaration,                   desc = "Go to declaration",         mode = "n" },
		{ "gd",         "<cmd>Telescope lsp_definitions<CR>",      desc = "Show LSP definitions",      mode = "n" },
		{ "gi",         "<cmd>Telescope lsp_implementations<CR>",  desc = "Show LSP implementations",  mode = "n" },
		{ "gt",         "<cmd>Telescope lsp_type_definitions<CR>", desc = "Show LSP type definitions", mode = "n" },
		{ "gs",         vim.lsp.buf.signature_help,                desc = "Show LSP signature help",   mode = "n" },
		{ "<leader>rn", vim.lsp.buf.rename,                        desc = "Smart rename",              mode = "n" },
		{ "<leader>D",  "<cmd>Telescope diagnostics bufnr=0<CR>",  desc = "Show buffer diagnostics",   mode = "n" },
		{ "<leader>d",  vim.diagnostic.open_float,                 desc = "Show line diagnostics",     mode = "n" },
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
		-- Python
		vim.lsp.config("pylsp", {
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

		vim.lsp.config("ruff", {
			settings = {
				init_options = {
					settings = {
						-- Arguments par défaut de la ligne de commande ruff
						-- (on ajoute les warnings pour le tri des imports)
						args = { "--extend-select", "I" },
					},
				},
			},
		})

		-- Rust
		vim.lsp.config("rust_analyzer", {
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
	end,
}
