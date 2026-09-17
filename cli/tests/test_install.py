import json
import base64
import importlib.util
import os
from pathlib import Path
import subprocess
import shutil
import sys
import tempfile
import unittest
from unittest import mock


NGR_TEST_ROOT = os.environ["NGR_TEST_ROOT"]
Installer = Path(__file__).resolve().parents[2] / "install/cli/install.py"
Command = "ngr.cmd" if os.name == "nt" else "ngr"


class InstallTest(unittest.TestCase):
    def testInstallUpdateRemoveAndForeignFiles(self):
        with tempfile.TemporaryDirectory(dir=NGR_TEST_ROOT) as DIR:
            Prefix = Path(DIR) / "prefix space ñ"
            Args = [sys.executable, "-B", str(Installer), "--prefix", str(Prefix)]
            DATA = subprocess.run(Args, capture_output=True, text=True)
            self.assertEqual(DATA.returncode, 0, DATA.stderr)
            Runtime = Prefix / "libexec/ngr"
            Manifest = Runtime / "INSTALL_MANIFEST.json"
            Receipt = Manifest.read_bytes()
            DATA = subprocess.run(Args, capture_output=True, text=True)
            self.assertEqual(DATA.returncode, 0, DATA.stderr)
            self.assertEqual(Manifest.read_bytes(), Receipt)
            Distribution = Path(DIR) / "incomplete"
            (Distribution / "install/cli").mkdir(parents=True)
            (Distribution / "cli").mkdir()
            shutil.copy2(Installer, Distribution / "install/cli/install.py")
            (Distribution / "cli/manifest.json").write_text(json.dumps({"files": ["missing-resource"]}))
            DATA = subprocess.run([sys.executable, "-B", str(Distribution / "install/cli/install.py"), "--prefix", str(Prefix)], capture_output=True, text=True)
            self.assertNotEqual(DATA.returncode, 0)
            self.assertEqual(Manifest.read_bytes(), Receipt)
            self.assertTrue((Prefix / "bin" / Command).is_file())
            if os.name == "nt":
                for Name in ("ngr.cmd", "ngr.ps1"):
                    Launcher = Prefix / "bin" / Name
                    Content = Launcher.read_bytes()
                    Launcher.write_bytes(Content + b"owner edit\r\n")
                    DATA = subprocess.run([*Args, "--uninstall"], capture_output=True, text=True)
                    self.assertNotEqual(DATA.returncode, 0)
                    self.assertTrue(Runtime.exists())
                    self.assertEqual(Launcher.read_bytes(), Content + b"owner edit\r\n")
                    Launcher.write_bytes(Content)
            (Runtime / "foreign").write_text("keep")
            DATA = subprocess.run(Args, capture_output=True, text=True)
            self.assertNotEqual(DATA.returncode, 0)
            self.assertEqual((Runtime / "foreign").read_text(), "keep")
            (Runtime / "foreign").unlink()
            DATA = subprocess.run([*Args, "--uninstall"], capture_output=True, text=True)
            self.assertEqual(DATA.returncode, 0, DATA.stderr)
            self.assertFalse(Runtime.exists())
            self.assertFalse((Prefix / "bin" / Command).exists())
            self.assertFalse((Prefix / "bin/ngr.ps1").exists())

    def testRelocatedRuntimeHasNoCheckoutDependency(self):
        with tempfile.TemporaryDirectory(prefix="ngr-independent-") as DIR:
            Prefix = Path(DIR) / "installation"
            DATA = subprocess.run([sys.executable, "-B", str(Installer), "--prefix", str(Prefix)], capture_output=True, text=True)
            self.assertEqual(DATA.returncode, 0, DATA.stderr)
            Project = Path(DIR) / "consumer"
            Project.mkdir()
            Binary = str(Prefix / "bin" / Command)
            for Args in (("--version",), ("pull", "--from", "ngr", "yml"), ("doctor",)):
                DATA = subprocess.run([Binary, *Args], cwd=Project, capture_output=True, text=True)
                self.assertEqual(DATA.returncode, 0, DATA.stderr)
            self.assertTrue((Project / "yml/_quarto.yml").is_file())
            DATA = json.loads((Project / "manifest.json").read_text(encoding="utf-8"))
            self.assertEqual(Path(DATA["scaffolds"]["ngr"]["manifest"]), (Prefix / "libexec/ngr/scaffold/manifest.json").resolve())
            Commit = subprocess.run(["git", "-C", str(Installer.parent), "rev-parse", "HEAD"],
                                    capture_output=True, text=True).stdout.strip() or "unknown"
            self.assertEqual({x["commit"] for x in DATA["scaffolds"]["ngr"]["files"].values()}, {Commit})

    def testForeignLauncherBlocksPreflight(self):
        with tempfile.TemporaryDirectory(dir=NGR_TEST_ROOT) as DIR:
            Prefix = Path(DIR)
            (Prefix / "bin").mkdir()
            for Name in ((Command, "ngr.ps1") if os.name == "nt" else (Command,)):
                Launcher = Prefix / "bin" / Name
                Launcher.write_text("owner content")
                DATA = subprocess.run([sys.executable, "-B", str(Installer), "--prefix", str(Prefix), "--check"], capture_output=True, text=True)
                self.assertNotEqual(DATA.returncode, 0)
                self.assertEqual(Launcher.read_text(), "owner content")
                self.assertFalse((Prefix / "libexec").exists())
                Launcher.unlink()

    @unittest.skipUnless(os.name == "nt", "Windows PowerShell entry")
    def testPowerShellPreservesLiteralArguments(self):
        with tempfile.TemporaryDirectory(dir=NGR_TEST_ROOT) as DIR:
            Prefix = Path(DIR) / "installation"
            subprocess.run([sys.executable, "-B", str(Installer), "--prefix", str(Prefix)], check=True, capture_output=True)
            Project = Path(DIR) / "consumer"
            Project.mkdir()
            (Project / "resource.txt").write_text("literal")
            (Project / "source&one.json").write_text(json.dumps({"schemaVersion": 1, "id": "literal",
                "resources": [{"from": "resource.txt", "to": "copied.txt", "ownership": "managed"}]}))
            Environment = os.environ.copy()
            Environment["PATH"] = str(Prefix / "bin") + os.pathsep + Environment["PATH"]
            Script = "$env:NGR_COMMAND_PATH='owner'; ngr pull --from 'source&one.json'; $Status=$LASTEXITCODE; if ($env:NGR_COMMAND_PATH -ne 'owner') { exit 90 }; exit $Status"
            DATA = subprocess.run(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand",
                base64.b64encode(Script.encode("utf-16le")).decode()], cwd=Project, env=Environment, capture_output=True, text=True)
            self.assertEqual(DATA.returncode, 0, DATA.stdout + DATA.stderr)
            self.assertEqual((Project / "copied.txt").read_text(), "literal")

    @unittest.skipUnless(os.name == "nt", "Windows two-launcher transaction")
    def testWindowsLauncherRollback(self):
        with tempfile.TemporaryDirectory(dir=NGR_TEST_ROOT) as DIR:
            Prefix = Path(DIR) / "installation"
            subprocess.run([sys.executable, "-B", str(Installer), "--prefix", str(Prefix)], check=True, capture_output=True)
            Before = {x.relative_to(Prefix): x.read_bytes() for x in Prefix.rglob("*") if x.is_file()}
            Distribution = Path(DIR) / "distribution"
            shutil.copytree(Prefix / "libexec/ngr", Distribution / "cli")
            Source = Installer.parents[2] / "cli"
            shutil.copy2(Source / "manifest.json", Distribution / "cli/manifest.json")
            (Distribution / "cli/main.R").write_bytes(b"# candidate\n" + (Distribution / "cli/main.R").read_bytes())
            (Distribution / "install/cli").mkdir(parents=True)
            for Name in ("install.py", "checkRuntime.R"):
                shutil.copy2(Installer.with_name(Name), Distribution / "install/cli" / Name)
            shutil.copy2(Installer.parent.parent / "requirements.R", Distribution / "install/requirements.R")
            Spec = importlib.util.spec_from_file_location("ngrInstaller", Distribution / "install/cli/install.py")
            Module = importlib.util.module_from_spec(Spec)
            Spec.loader.exec_module(Module)
            Replace = os.replace

            def replace(source, target):
                if Path(target).name == "ngr.ps1":
                    raise OSError("injected PowerShell replacement failure")
                return Replace(source, target)

            with mock.patch.object(Module.os, "replace", side_effect=replace):
                with self.assertRaisesRegex(OSError, "injected"):
                    Module.installRuntime(Prefix, uninstall=False)
            self.assertEqual({x.relative_to(Prefix): x.read_bytes() for x in Prefix.rglob("*") if x.is_file()}, Before)


if __name__ == "__main__":
    unittest.main()
