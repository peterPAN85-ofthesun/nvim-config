return {
  -- 42 standard header (insert with <F1>, auto-update on save)
  "42paris/42header",
  lazy = false,
  dependencies = { "stevearc/conform.nvim" },
  init = function()
    vim.g.user42 = vim.env.USER or "login"
    vim.g.mail42 = (vim.env.USER or "login") .. "@student.42.fr"
    vim.g.norm42_active = false -- 42 format mode OFF by default
  end,
  config = function()
    local conform = require("conform")

    -- Pre-processor: converts 2+ spaces between type and varname to tabs (ceil(n/4))
    -- Runs before c_formatter_42 so tabs are preserved by the norm formatter
    local align_script = [=[
import sys, re

TAB_WIDTH = 4

def next_tab(col):
    return ((col // TAB_WIDTH) + 1) * TAB_WIDTH

def tabs_to_reach(col, target):
    n = 0
    while col < target:
        col = next_tab(col)
        n += 1
    return max(1, n)

DECL = re.compile(
    r'^([ \t]+)'
    r'((?:(?:const|static|volatile|extern|inline|register|unsigned|signed|long|short|struct|enum|union)\s+)*[a-zA-Z_]\w*)'
    r'\s+'
    r'(\*{0,3}[a-zA-Z_]\w*(?:\[[^\]]*\])?)'
    r'\s*;'
)

def flush(block, out):
    decls = [(l, m) for l, m in block if m]
    if decls:
        target = next_tab(max(len(m.group(2)) for _, m in decls))
    for line, m in block:
        if m:
            lead, typ, var = m.group(1), m.group(2), m.group(3)
            rest = line[m.end():].rstrip('\n')
            out.append(lead + typ + '\t' * tabs_to_reach(len(typ), target) + var + ';' + rest + '\n')
        else:
            out.append(line)
    block.clear()

ALLMAN = re.compile(r'^(\s*)(\S.*\S|\S)\s*\{\s*$')

def to_allman(lines):
    out = []
    for line in lines:
        m = ALLMAN.match(line)
        if m:
            lead, content = m.group(1), m.group(2)
            out.append(lead + content + '\n')
            out.append(lead + '{\n')
        else:
            out.append(line)
    return out

def reindent(lines):
    out = []
    depth = 0
    in_block_comment = False
    for line in lines:
        s = line.strip()
        if not s:
            out.append('\n')
            continue
        if s.startswith('#'):
            out.append(s + '\n')
            continue
        if in_block_comment:
            prefix = ' ' if s.startswith('*') else ''
            out.append('\t' * depth + prefix + s + '\n')
            if '*/' in s:
                in_block_comment = False
            continue
        if '/*' in s and '*/' not in s:
            in_block_comment = True
        if s.startswith('}'):
            depth = max(0, depth - 1)
        out.append('\t' * depth + s + '\n')
        if s.endswith('{'):
            depth += 1
    return out

lines = to_allman(reindent(sys.stdin.readlines()))
out, block = [], []
for line in lines:
    m = DECL.match(line)
    if m:
        block.append((line, m))
    else:
        flush(block, out)
        out.append(line)
flush(block, out)
sys.stdout.write(''.join(out))
]=]
    conform.formatters.norm42_align = {
      command = "python3",
      args = { "-c", align_script },
      stdin = true,
    }

    -- Register c_formatter_42
    conform.formatters.c_formatter_42 = {
      command = "c_formatter_42",
      stdin = true,
    }

    -- Toggle 42 norm mode (controls format-on-save behavior for C/H files)
    local function toggle_norm42()
      vim.g.norm42_active = not vim.g.norm42_active
      local state = vim.g.norm42_active and "ON  (save → c_formatter_42)" or "OFF (save → clangd)"
      vim.notify("[42 Norm] Format mode: " .. state, vim.log.levels.INFO)
    end

    vim.api.nvim_create_user_command("Norm42Toggle", toggle_norm42,
      { desc = "Toggle 42 norm format-on-save mode" })

    vim.keymap.set("n", "<leader>4t", toggle_norm42,
      { desc = "Toggle 42 norm format-on-save" })

    -- :Norm42 / <leader>4f → always format manually with 42 norm
    vim.api.nvim_create_user_command("Norm42", function()
      conform.format({ formatters = { "c_formatter_42", "norm42_align" }, async = false, timeout_ms = 5000 })
    end, { desc = "Format buffer with 42 norm (c_formatter_42)" })

    vim.keymap.set("n", "<leader>4f", "<cmd>Norm42<CR>",
      { desc = "Format 42 norm (c_formatter_42)" })

    -- Compile and run current .c file in a terminal split
    local function compile_and_run(flags)
      local file = vim.fn.expand("%:p")
      if vim.fn.expand("%:e") ~= "c" then
        vim.notify("[42] Not a .c file", vim.log.levels.WARN)
        return
      end
      vim.cmd("write")
      local out = vim.fn.tempname()
      local cmd = { "sh", "-c",
        string.format("gcc %s '%s' -o '%s' && '%s'; echo \"[exit: $?]\"", flags, file, out, out)
      }
      vim.cmd("botright new")
      vim.fn.termopen(cmd)
      vim.cmd("startinsert")
    end

    vim.api.nvim_create_user_command("Norm42Run", function()
      compile_and_run("-Wall -Wextra -Werror")
    end, { desc = "Compile .c (-Wall -Wextra -Werror) and run" })

    vim.api.nvim_create_user_command("Norm42Debug", function()
      compile_and_run("-g")
    end, { desc = "Compile .c (-g) and run" })

    vim.keymap.set("n", "<leader>4r", "<cmd>Norm42Run<CR>",
      { desc = "Compile & run (42 flags)" })

    vim.keymap.set("n", "<leader>4d", "<cmd>Norm42Debug<CR>",
      { desc = "Compile & run (-g debug)" })

    -- Auto-update header modification date/login on save (only if header already present)
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.c", "*.h" },
      callback = function()
        local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
        if first_line:match("^/%* %*+%s*$") then
          local cursor = vim.api.nvim_win_get_cursor(0)
          vim.cmd("Stdheader")
          vim.api.nvim_win_set_cursor(0, cursor)
        end
      end,
    })
  end,
}
