"""Contract tests for safe, project-aware STAR cycle handling."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/star_relay.py"
spec = importlib.util.spec_from_file_location("star_relay", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class RelayContract(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / "PROJECTS.md").write_text(
            "# Registry\n## Projets appartenant à Memo Labs\n"
            "| Name | Path | Kind | Status |\n|---|---|---|---|\n"
            "| alpha | alpha | repo | active |\n"
            "| beta | beta | repo | parked |\n"
            "\n## Dépôts de référence\n| ignored | ignored | repo | active |\n")
        (self.root / "alpha").mkdir()
        (self.root / "beta").mkdir()
        self.worktree = self.root / "_worktrees/alpha/fix-one"
        self.worktree.mkdir(parents=True)
        (self.worktree / ".git").write_text("gitdir: /tmp/other")
        (self.worktree / "SPEC.md").write_text("Task: verify x")
        self.notes = self.worktree / "SHARED_TASK_NOTES.md"

    def test_inventory_is_read_only_and_skips_external_repos(self):
        report = module.inventory(self.root)
        self.assertEqual([p["project"] for p in report], ["alpha", "beta"])
        self.assertFalse(self.notes.exists())
        self.notes.write_text("in flight")
        report = module.inventory(self.root)
        self.assertEqual(report[0]["worktree_notes"], 1)

    def test_worktree_and_spec_must_exist(self):
        with self.assertRaises(ValueError):
            module.workspace_for(self.root, "alpha", self.root / "alpha")
        with self.assertRaises(ValueError):
            module.workspace_for(self.root, "ignored", self.worktree)
        self.assertEqual(module.spec_in(self.worktree, None), "SPEC.md")
        (self.worktree / "SPEC.md").unlink()
        with self.assertRaises(ValueError):
            module.spec_in(self.worktree, None)

    def test_one_complete_star_cycle_preserves_prior_notes(self):
        self.notes.write_text("# Existing notes\nDo not replace me.\n")
        id1 = module.start(self.notes, "alpha", "SPEC.md", "Observed foo", "Verify foo")
        text = self.notes.read_text()
        self.assertIn("Do not replace me.", text)
        self.assertIn("**Situation:** Observed foo", text)
        self.assertEqual(module.active_cycle(text), id1)
        with self.assertRaises(ValueError):
            module.start(self.notes, "alpha", "SPEC.md", "other", "second")
        self.assertEqual(
            module.finish(self.notes, "PASSED", "Added a test", "Foo works",
                          "python -m unittest: PASS", "Review next bug"), id1)
        final = self.notes.read_text()
        self.assertIn("**Result (PASSED):** Foo works", final)
        self.assertIn("**Next single task:** Review next bug", final)
        self.assertIsNone(module.active_cycle(final))
        id2 = module.start(self.notes, "alpha", "SPEC.md", "New state", "Second task")
        self.assertNotEqual(id1, id2)

    def test_failed_or_blocked_are_honest_results(self):
        module.start(self.notes, "alpha", "SPEC.md", "regression", "fix")
        module.finish(self.notes, "BLOCKED", "Diagnosed issue", "No production change",
                      "CI timed out, link retained", "Investigate CI runner")
        self.assertIn("**Result (BLOCKED):**", self.notes.read_text())

    def test_finish_requires_active_cycle(self):
        with self.assertRaises(ValueError):
            module.finish(self.notes, "PASSED", "a", "r", "e", "next")

    def test_cli_rejects_writes_in_canonical_repo(self):
        self.assertEqual(module.main([
            "--projects-root", str(self.root), "start", "--project", "alpha",
            "--workspace", str(self.root / "alpha"),
            "--situation", "here", "--task", "there"
        ]), 2)
        self.assertFalse((self.root / "alpha/SHARED_TASK_NOTES.md").exists())

    def test_cli_inventory_and_roundtrip(self):
        self.assertEqual(module.main(["--projects-root", str(self.root), "inventory"]), 0)
        self.assertEqual(module.main([
            "--projects-root", str(self.root), "start", "--project", "alpha",
            "--workspace", str(self.worktree), "--task", "Fix bug",
            "--situation", "Repro confirmed"
        ]), 0)
        self.assertEqual(module.main([
            "--projects-root", str(self.root), "finish", "--project", "alpha",
            "--workspace", str(self.worktree), "--status", "PASSED",
            "--action", "Fixed issue", "--result", "Pass",
            "--verification", "unit tests 7/7", "--next-task", "Next task"
        ]), 0)


if __name__ == "__main__":
    unittest.main()
