return {
  "goolord/alpha-nvim",
  lazy = false,
  priority = 1000,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Header ASCII art (Ansi Shadow)
    dashboard.section.header.val = {
      [[                                                     ]],
      [[ ██████   █████                   █████   █████  ███ ]],
      [[░░██████ ░░███                   ░░███   ░░███  ░░░  ]],
      [[ ░███░███ ░███   ██████   ██████  ░███    ░███  ████ ]],
      [[ ░███░░███░███  ███░░███ ███░░███ ░███    ░███ ░░███ ]],
      [[ ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███   ░███ ]],
      [[ ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░    ░███ ]],
      [[ █████  ░░█████░░██████ ░░██████     ░░███      █████]],
      [[░░░░░    ░░░░░  ░░░░░░   ░░░░░░       ░░░      ░░░░░ ]],
      [[                                                     ]],
    }

    -- Menu buttons
    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
      dashboard.button("n", "  New file", ":lua require('alpha').new_file()<CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
      dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
      dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
      dashboard.button("m", "  Mason", ":Mason<CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    -- Fonction pour créer un nouveau fichier avec un nom
    function alpha.new_file()
      vim.ui.input({ prompt = "Nom du fichier: " }, function(filename)
        if filename and filename ~= "" then
          vim.cmd("edit " .. vim.fn.fnameescape(filename))
        end
      end)
    end

    -- Footer
    dashboard.section.footer.val = function()
      local stats = require("lazy").stats()
      return "  " .. stats.loaded .. "/" .. stats.count .. " plugins loaded"
    end

    -- Colors
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"

    -- Layout
    dashboard.config.layout = {
      { type = "padding", val = 2 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)

    -- Disable folding on alpha buffer
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function()
        vim.opt_local.foldenable = false
        vim.opt_local.cursorline = false
      end,
    })

    -- Ouvrir alpha-nvim quand un dossier est passé en argument
    if vim.fn.argc() == 1 then
      local arg = vim.fn.argv(0)
      local stat = vim.loop.fs_stat(arg)
      if stat and stat.type == "directory" then
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            -- Changer le répertoire de travail
            vim.cmd("cd " .. vim.fn.fnameescape(arg))
            -- Supprimer le buffer du dossier
            vim.api.nvim_buf_delete(0, { force = true })
            -- Créer un nouveau buffer vide
            vim.cmd("enew")
            -- Ouvrir alpha-nvim
            alpha.start(false)
          end,
        })
      end
    end
  end,
}
