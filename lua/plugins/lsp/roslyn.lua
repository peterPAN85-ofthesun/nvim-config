-- Serveur LSP C# moderne (Microsoft Roslyn), remplace omnisharp.
-- Voir la configuration des settings/capabilities dans plugins/lsp/lspconfig.lua (vim.lsp.config("roslyn", ...)).
-- Le serveur (DLL) est installé via Mason sous le paquet "roslyn" (cf. plugins/lsp/mason.lua).
return {
	"seblyng/roslyn.nvim",
	ft = "cs",
	opts = {
		-- Recherche les solutions/projets dans les répertoires parents
		-- (utile pour les projets Godot et les .csproj sans .sln).
		broad_search = true,
	},
}
