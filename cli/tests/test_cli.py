import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
import shutil


NGR_TEST_BIN = os.environ["NGR_TEST_BIN"]
NGR_TEST_ROOT = os.environ["NGR_TEST_ROOT"]


class CliTest(unittest.TestCase):
    def setUp(self):
        self.Directory = tempfile.TemporaryDirectory(dir=NGR_TEST_ROOT)
        self.addCleanup(self.Directory.cleanup)
        self.Root = Path(self.Directory.name)

    def runCli(self, *args, env=None):
        return subprocess.run([NGR_TEST_BIN, *args], cwd=self.Root,
                              env=env, capture_output=True, text=True)

    def testResourceHelpNamesPublicCommandAndApplicableOptions(self):
        for Command, Present, Absent in (
            ("pull", ("--from", "--source", "--force", "--dry-run", "TARGETS"), ("--check",)),
            ("status", ("--from", "--source", "--check", "TARGETS"), ("--force", "--dry-run")),
            ("doctor", ("--source",), ("--from", "--force", "--dry-run", "--check", "TARGETS")),
        ):
            with self.subTest(command=Command):
                DATA = self.runCli(Command, "--help")
                self.assertEqual(DATA.returncode, 0, DATA.stderr)
                self.assertIn(f"usage: ngr {Command} ", DATA.stdout)
                for x in Present:
                    self.assertIn(x, DATA.stdout)
                for x in Absent:
                    self.assertNotIn(x, DATA.stdout)
                self.assertNotIn("resources.py", DATA.stdout)
        self.assertEqual(list(self.Root.iterdir()), [])

    def testResourceOptionsRejectInvalidCommands(self):
        for Args in (("pull", "--check"), ("status", "--force"),
                     ("status", "--dry-run"), ("doctor", "--from", "ngr"),
                     ("doctor", "scripts")):
            with self.subTest(args=Args):
                DATA = self.runCli(*Args)
                self.assertEqual(DATA.returncode, 2, DATA.stdout + DATA.stderr)
        self.assertEqual(list(self.Root.iterdir()), [])

    def testManifestRenderRejectsUnusedArgumentsBeforeEffects(self):
        (self.Root / "html").mkdir()
        (self.Root / "html/index.html").write_text("static sentinel")
        Manifest = self.Root / "manifest.json"
        Manifest.write_text(json.dumps(dict(schemaVersion=2, artifacts=[
            dict(alias="page", kind="static", path="html", required=True)])))
        for Args in (("--unexpected-option",), ("--dry-run", "--unexpected-option")):
            with self.subTest(args=Args):
                DATA = self.runCli("render", "--manifest", str(Manifest), *Args)
                self.assertNotEqual(DATA.returncode, 0, DATA.stdout + DATA.stderr)
                self.assertIn("--unexpected-option", DATA.stderr)
                self.assertNotIn("[render manifest]", DATA.stdout)
        self.assertEqual((self.Root / "html/index.html").read_text(), "static sentinel")

    def testDeployActionHelpDoesNotNeedProviderOrProject(self):
        # Help needs the declared R runtime, but no provider command.
        Env = dict(os.environ, PATH=str(Path(shutil.which("Rscript")).resolve().parent) + os.pathsep + os.defpath)
        for Action in ("init", "domain", "unbind"):
            for Flag in ("--help", "-h"):
                with self.subTest(action=Action, flag=Flag):
                    DATA = self.runCli("deploy", Action, Flag, env=Env)
                    self.assertEqual(DATA.returncode, 0, DATA.stdout + DATA.stderr)
                    self.assertIn(f"ngr deploy {Action} ", DATA.stdout)
                    self.assertEqual(DATA.stderr, "")
        self.assertEqual(list(self.Root.iterdir()), [])


if __name__ == "__main__":
    unittest.main()
