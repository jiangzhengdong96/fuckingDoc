import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("check_links", Path(__file__).parents[1] / "check-links.py")
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


class LinkTests(unittest.TestCase):
    def check(self, files):
        with tempfile.TemporaryDirectory() as tmp:
            paths = []
            for name, text in files.items():
                path = Path(tmp) / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(text, encoding="utf-8")
                paths.append(path)
            return checker.check_files(paths)

    def test_chinese_encoded_and_space_paths(self):
        self.assertEqual([], self.check({
            "index.md": '[页](中文.md#%E7%AB%A0) [空格](<with space.md#ok>)',
            "中文.md": '<a id="章"></a>',
            "with space.md": '<a id="ok"></a>'}))

    def test_missing_local_and_cross_file_anchor(self):
        issues = self.check({"a.md": '[本页](#bad) [跨页](b.md#bad)', "b.md": '# B'})
        self.assertEqual(2, len(issues))
        self.assertTrue(all('Missing anchor' in x for x in issues))

    def test_duplicate_ignores_code_and_comments(self):
        issues = self.check({"a.md": '<a id="x"></a>\n<a id="x"></a>\n```md\n<a id="x"></a>\n[示例](missing.md)\n```\n<!-- [hidden](absent.md) -->'})
        self.assertEqual(1, len(issues))
        self.assertIn('Duplicate anchor', issues[0])

    def test_reference_links_and_missing_file(self):
        issues = self.check({"a.md": '[ok][ref] [bad][unknown]\n[ref]: b.md#ok\n[missing](none.md)', "b.md": '<a id="ok"></a>'})
        self.assertEqual(2, len(issues))
        self.assertTrue(any('Missing link reference' in x for x in issues))
        self.assertTrue(any('Broken local link' in x for x in issues))

    def test_external_and_code_literals(self):
        self.assertEqual([], self.check({"a.md": '[web](https://example.com/a#x) `[code](absent.md)`\n~~~\n[code](absent.md)\n~~~'}))

    def test_directory_readme_and_parentheses(self):
        self.assertEqual([], self.check({"a.md": '[dir](sub/#ok) [paren](name(test).md#ok)', "sub/README.md": '<a id="ok"></a>', "name(test).md": '<a id="ok"></a>'}))


if __name__ == '__main__':
    unittest.main()
