return {
  "goolord/alpha-nvim",
  event = "VimEnter",
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
      dashboard.button("n", "  New file", ":enew<CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
      dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
      dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
      dashboard.button("m", "  Mason", ":Mason<CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }

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
  end,
}
