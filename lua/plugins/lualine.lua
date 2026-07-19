return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- affiche le nombre de mise à jour plugins lazy dans la barre

    -- configuration de lualine
    lualine.setup({
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          -- Pas de winbar sur les buffers utilitaires (arbo, dashboard…)
          winbar = { "alpha", "NvimTree", "neo-tree", "trouble" },
        },
        ignore_focus = {},
        always_divide_middle = true,
        -- Barre de statut unique en bas : les splits horizontaux (sp) sont
        -- alors séparés par WinSeparator (cyan), comme les splits verticaux.
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      -- Nom de fichier par fenêtre (la barre de statut étant désormais globale).
      -- Identifie chaque split en haut de sa fenêtre.
      winbar = {
        lualine_c = { { "filename", path = 1 } },
      },
      inactive_winbar = {
        lualine_c = { { "filename", path = 1 } },
      },
      extensions = {},
    })
  end,
}

