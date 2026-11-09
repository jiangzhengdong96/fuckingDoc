from pathlib import Path
import json
import shutil
import subprocess
import tempfile
import unittest

HOOK = Path(__file__).resolve().parents[2] / '.codex/hooks/knowledge-stop-check.ps1'


@unittest.skipUnless(shutil.which('powershell') and shutil.which('git'), 'requires Windows PowerShell and git')
class HookTests(unittest.TestCase):
    def run_case(self, changed, tracked=False):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / '.codex/hooks').mkdir(parents=True)
            shutil.copyfile(HOOK, root / '.codex/hooks/knowledge-stop-check.ps1')
            (root / 'scripts').mkdir()
            for name, marker in [('check-knowledge.ps1', 'checked'), ('update-index.ps1', 'indexed')]:
                (root / 'scripts' / name).write_text(f"Set-Content -LiteralPath '{marker}' -Value ok\n$global:LASTEXITCODE = 0\n", encoding='utf-8')
            target = root / changed
            target.parent.mkdir(parents=True, exist_ok=True)
            if tracked:
                target.write_text('before', encoding='utf-8')
            def git(*args):
                subprocess.run(['git', '-C', str(root), *args], check=True, capture_output=True)
            git('init')
            git('add', '.')
            git('-c', 'user.name=Test', '-c', 'user.email=test@example.invalid', 'commit', '-m', 'fixture')
            target.write_text('after', encoding='utf-8')
            result = subprocess.run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(root / '.codex/hooks/knowledge-stop-check.ps1')], cwd=root, capture_output=True, text=True)
            self.assertEqual(0, result.returncode, result.stderr)
            return (root / 'checked').exists(), (root / 'indexed').exists(), result.stdout

    def test_new_untracked_note(self):
        checked, indexed, output = self.run_case('docs/new.md')
        self.assertTrue(checked)
        self.assertTrue(indexed)
        self.assertIn('passed', json.loads(output)['systemMessage'])

    def test_script_change_triggers_check(self):
        checked, indexed, _ = self.run_case('scripts/probe.ps1', tracked=True)
        self.assertTrue(checked)
        self.assertFalse(indexed)

    def test_unrelated_workspace_change_skips(self):
        checked, indexed, output = self.run_case('.obsidian/workspace.json')
        self.assertFalse(checked)
        self.assertFalse(indexed)
        self.assertEqual('', output.strip())
