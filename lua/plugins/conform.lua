return {
  "stevearc/conform.nvim",
  opts = {},
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        css = { "prettier" },
        elm = { "elm_format" },
        graphql = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        python = { "ruff_fix", "ruff_format" },
        rust = { "rustfmt" },
        svelte = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
        -- Godot
        gdscript = { "gdformat" }, -- GDScript formatter (gdtoolkit)
        cs = { "csharpier" }, -- C# formatter pour Godot
      },
      format_on_save = function(bufnr)
        if vim.g.format_disabled then return end
        local ft = vim.bo[bufnr].filetype
        if (ft == "c" or ft == "cpp") and vim.g.norm42_active then
          return { formatters = { "c_formatter_42", "norm42_align" }, async = false, timeout_ms = 5000 }
        elseif ft == "c" or ft == "cpp" then
          return { lsp_fallback = true, async = false, timeout_ms = 1000 }
        end
        return { lsp_fallback = true, async = false, timeout_ms = 1000 }
      end,
    })

    vim.keymap.set("n", "<leader>mf", function()
      vim.g.format_disabled = not vim.g.format_disabled
      local state = vim.g.format_disabled and "OFF" or "ON"
      vim.notify("[Format] Format-on-save: " .. state, vim.log.levels.INFO)
    end, { desc = "Toggle format-on-save" })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}

