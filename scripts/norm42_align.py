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

def fix_comma_spacing(line):
    result = []
    i = 0
    in_string = None
    while i < len(line):
        c = line[i]
        if in_string:
            result.append(c)
            if c == '\\':
                i += 1
                if i < len(line):
                    result.append(line[i])
            elif c == in_string:
                in_string = None
        else:
            if c in ('"', "'"):
                in_string = c
                result.append(c)
            elif c == '/' and i + 1 < len(line) and line[i + 1] == '/':
                result.append(line[i:])
                break
            elif c == ',' and i + 1 < len(line) and line[i + 1] not in (' ', '\n', '\r'):
                result.append(', ')
            else:
                result.append(c)
        i += 1
    return ''.join(result)

sys.stdout.write(''.join(fix_comma_spacing(line) for line in out))
