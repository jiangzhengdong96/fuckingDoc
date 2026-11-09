"""Refresh page navigation in reader-facing Markdown (Python 3, stdlib only)."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
START = '<!-- page-toc:start -->'
END = '<!-- page-toc:end -->'


def outside_code(lines):
    fence = None
    for i, line in enumerate(lines):
        match = re.match(r'^\s*(`{3,}|~{3,})', line)
        if match:
            marker = match[1]
            if fence is None:
                fence = marker
            elif marker[0] == fence[0] and len(marker) >= len(fence):
                fence = None
            continue
        if fence is None:
            yield i, line


def update(text, name):
    text = re.sub(re.escape(START) + r'.*?' + re.escape(END) + r'\n*', '', text, flags=re.S)
    lines = text.splitlines()
    # Replace existing page-only navigation, preserving cross-file module navigation.
    remove = set()
    for i, line in outside_code(lines):
        if re.fullmatch(r'(?:#{1,6}\s+)?(?:目录|一级栏目导航|面试题导航|知识点导航)[：:]?', line.strip()):
            j = i + 1
            found = False
            while j < len(lines):
                if not lines[j].strip():
                    j += 1
                elif re.fullmatch(r'\s*- \[.+\]\(#[^\s]+\)\s*', lines[j]):
                    found = True
                    j += 1
                else:
                    break
            if found:
                remove.update(range(i, j))
    lines = [line for i, line in enumerate(lines) if i not in remove]
    headings = [(i, m[1], m[2]) for i, line in outside_code(lines)
                if (m := re.match(r'^(#{1,6})\s+(.+?)\s*#*$', line))]
    if not headings:
        lines = ['### ' + name, '', '###### 笔记内容', '', *lines]
    elif len(headings) == 1:
        i = headings[0][0]
        lines[i + 1:i + 1] = ['', '###### 正文']
    headings = [(i, m[1], m[2]) for i, line in outside_code(lines)
                if (m := re.match(r'^(#{1,6})\s+(.+?)\s*#*$', line))]
    used = set(re.findall(r'<a\s+id="([^"]+)"', '\n'.join(line for _, line in outside_code(lines))))
    inserts = {}
    entries = []
    context = ''
    for i, level, title in headings[1:]:
        j = i - 1
        while j >= 0 and not lines[j].strip():
            j -= 1
        existing = re.fullmatch(r'<a id="([^"]+)"></a>', lines[j]) if j >= 0 else None
        if existing:
            anchor = existing[1]
        else:
            base = 'section-' + re.sub(r'[^\w\u4e00-\u9fff-]+', '-', title.lower()).strip('-')
            anchor = base
            suffix = 2
            while anchor in used:
                anchor = f'{base}-{suffix}'
                suffix += 1
            used.add(anchor)
            inserts[i] = f'<a id="{anchor}"></a>'
        label = title
        if title == '面试可能怎么问' and context:
            label = context + '：面试可能怎么问'
        elif title not in ('内容概述', '使用场景'):
            context = title
        label = label.replace('[', '&#91;').replace(']', '&#93;')
        entries.append(f'- [{label}](#{anchor})')
    toc = '\n'.join([START, '**目录**', '', *entries, END, ''])
    result = []
    title_index = headings[0][0]
    for i, line in enumerate(lines):
        if i in inserts:
            result.append(inserts[i])
        result.append(line)
        if i == title_index:
            result.extend(['', toc])
    return '\n'.join(result).rstrip() + '\n'


def main():
    paths = sorted([*(p for p in ROOT.glob('*.md') if p.name not in ('AGENTS.md', 'CLAUDE.md')), *(ROOT / 'docs').rglob('*.md'),
                    *(ROOT / 'templates').glob('*.md'), *(ROOT / 'assets').glob('*.md')])
    changed = 0
    for path in paths:
        raw = path.read_bytes()
        bom = raw.startswith(b'\xef\xbb\xbf')
        original = raw.decode('utf-8-sig').replace('\r\n', '\n')
        updated = update(original, path.stem)
        if updated.rstrip('\n') != original.rstrip('\n'):
            newline = '\r\n' if b'\r\n' in raw else '\n'
            path.write_bytes((b'\xef\xbb\xbf' if bom else b'') + updated.replace('\n', newline).encode('utf-8'))
            changed += 1
    print(f'Page TOC: {len(paths)} files checked, {changed} updated.')


if __name__ == '__main__':
    main()
