"""Validate local Markdown links and explicit anchors; no network access."""
from pathlib import Path
from collections import Counter
import re
import sys
from urllib.parse import unquote, urlsplit


def prose(text):
    lines = []
    fence = None
    for line in text.splitlines():
        m = re.match(r"^\s*(`{3,}|~{3,})", line)
        if m:
            marker = m[1]
            if fence is None:
                fence = marker
            elif marker[0] == fence[0] and len(marker) >= len(fence) and not line[m.end():].strip():
                fence = None
            continue
        if fence is None:
            lines.append(line)
    text = "\n".join(lines)
    text = re.sub(r"<!--.*?-->", "", text, flags=re.S)
    return re.sub(r"(`+).*?\1", "", text, flags=re.S)


ANCHOR = re.compile(r"<a\b[^>]*\b(?:id|name)=[\"']([^\"']+)[\"']", re.I)
# Angle-delimited paths can contain spaces; bare paths allow balanced parentheses.
DEST = r"(<[^>]+>|(?:[^\s()]+|\([^()]*\))+)"
INLINE = re.compile(r"!?\[[^\]\n]*\]\(\s*" + DEST + r"(?:\s+[\"'][^\n]*?[\"'])?\s*\)")
DEFINITION = re.compile(r"^\s{0,3}\[([^\]]+)\]:\s*" + DEST, re.M)
REFERENCE = re.compile(r"!?\[([^\]\n]+)\]\[([^\]\n]*)\]")


def normalize(s):
    return " ".join(s.split()).casefold()


def check_files(paths):
    issues = []
    cache = {}

    def read(path):
        if path not in cache:
            content = prose(path.read_text(encoding="utf-8-sig"))
            cache[path] = (content, ANCHOR.findall(content))
        return cache[path]

    for path in paths:
        path = path.resolve()
        content, anchors = read(path)
        for anchor, count in Counter(anchors).items():
            if count > 1:
                issues.append(f"Duplicate anchor: {anchor} in {path}")
        definitions = {normalize(m[1]): m[2] for m in DEFINITION.finditer(content)}
        targets = [m[1] for m in INLINE.finditer(content)] + list(definitions.values())
        for m in REFERENCE.finditer(content):
            key = normalize(m[2] or m[1])
            if key not in definitions:
                issues.append(f"Missing link reference: {key} in {path}")
        for target in targets:
            target = target.strip("<>")
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc:
                continue
            dest = (path.parent / unquote(parsed.path)).resolve() if parsed.path else path
            if not dest.exists():
                issues.append(f"Broken local link: {target} in {path}")
                continue
            if parsed.fragment:
                if dest.is_dir():
                    dest = dest / "README.md"
                if not dest.is_file() or dest.suffix.lower() != ".md":
                    issues.append(f"Cannot verify anchor target: {target} in {path}")
                elif unquote(parsed.fragment) not in read(dest)[1]:
                    issues.append(f"Missing anchor: {target} in {path}")
    return issues


def main():
    root = Path(__file__).resolve().parents[1]
    paths = list(root.glob("*.md"))
    for directory in ("docs", "templates", "assets", ".agents"):
        paths.extend((root / directory).rglob("*.md"))
    issues = check_files(sorted(paths))
    for issue in issues:
        print(issue)
    if not issues:
        print(f"Local links and anchors passed: {len(paths)} Markdown files.")
    return bool(issues)


if __name__ == "__main__":
    sys.exit(main())
