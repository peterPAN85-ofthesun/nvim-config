return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "s1n7ax/nvim-window-picker",
  },
  config = function()
    require("nvim-tree").setup({
      actions = {
        open_file = {
          window_picker = {
            enable = true,
            picker = function()
              local ok, picker = pcall(require, "window-picker")
              if ok then
                return picker.pick_window()
              end
              return nil
            end,
          },
        },
      },
    })

    -- On utilise <leader>e pour ouvrir/fermer l'explorateur
    vim.keymap.set(
      "n",
      "<leader>e",
      "<cmd>NvimTreeFindFileToggle<CR>",
      { desc = "Ouverture/fermeture de l'explorateur de fichiers" }
    )
  end,
}

