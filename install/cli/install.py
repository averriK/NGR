#!/usr/bin/env python3
"""Install only the CLI runtime; R packages are independently managed."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def installRuntime(prefix, uninstall, check=False):
    Source = Path(__file__).resolve().parents[2] / "cli"
    Prefix = prefix.expanduser().resolve()
    Runtime = Prefix / "libexec/ngr"
    Windows = os.name == "nt"
    Launcher = Prefix / ("bin/ngr.cmd" if Windows else "bin/ngr")
    Launchers = {"launcher": Launcher, "powershell": Prefix / "bin/ngr.ps1"} if Windows else {}
    Receipt = Runtime / "INSTALL_MANIFEST.json"
    if Runtime.is_symlink():
        raise ValueError(f"runtime must not be a symlink: {Runtime}")
    if not Windows and (Launcher.exists() or Launcher.is_symlink()):
        if not Launcher.is_symlink() or Launcher.resolve() != Runtime / "bin/ngr":
            raise ValueError(f"launcher belongs to another installation: {Launcher}")
    if Runtime.exists():
        if not Receipt.is_file():
            raise ValueError(f"runtime has no ownership receipt: {Runtime}")
        DATA = json.loads(Receipt.read_text(encoding="utf-8"))
        if DATA.get("product") != "ngr" or not isinstance(DATA.get("files"), dict):
            raise ValueError("invalid ngr installation receipt")
        if any(x.is_symlink() for x in Runtime.rglob("*")):
            raise ValueError("symlink found inside owned runtime")
        Actual = {x.relative_to(Runtime).as_posix() for x in Runtime.rglob("*") if not x.is_dir()}
        if Actual != set(DATA["files"]) | {"INSTALL_MANIFEST.json"}:
            raise ValueError("runtime files differ from the ownership receipt; preserve/reconcile them first")
        for Name, Hash in DATA["files"].items():
            FILE = Runtime / Name
            if FILE.is_symlink() or digest(FILE) != Hash:
                raise ValueError(f"installed file changed: {FILE}")
    for Key, Entry in Launchers.items():
        if not Entry.exists() and not Entry.is_symlink():
            continue
        if Entry.is_symlink() or not Receipt.is_file() or not Entry.is_file():
            raise ValueError(f"launcher belongs to another installation: {Entry}")
        if DATA.get(Key) != {"path": f"bin/{Entry.name}", "sha256": digest(Entry)}:
            raise ValueError(f"installed launcher changed: {Entry}")
    if uninstall:
        if not Runtime.exists():
            raise ValueError(f"no ngr installation at {Prefix}")
        if not Windows:
            Launcher.unlink(missing_ok=True)
        for Entry in Launchers.values():
            Entry.unlink(missing_ok=True)
        shutil.rmtree(Runtime)
        print(f"Removed ngr CLI from {Prefix}")
        return
    Assets = json.loads((Source / "manifest.json").read_text(encoding="utf-8"))["files"]
    if not isinstance(Assets, list) or not all(isinstance(x, str) for x in Assets) or len(Assets) != len(set(Assets)):
        raise ValueError("distribution manifest requires unique file paths")
    Files = []
    for Name in Assets:
        if not Name or Name.startswith("/") or any(x in ("", ".", "..") for x in Name.split("/")):
            raise ValueError(f"invalid distribution path: {Name}")
        FILE = Source / Name
        if not FILE.is_file() or FILE.is_symlink() or Source not in FILE.resolve().parents:
            raise ValueError(f"distribution file missing or unsafe: {FILE}")
        Files.append(FILE)
    if not {"bin/ngr", "bin/ngr.cmd", "bin/ngr.ps1", "main.R", "scaffold/manifest.json", "VERSION"}.issubset(Assets):
        raise ValueError("incomplete distribution manifest")
    for Parent in (Runtime.parent, Launcher.parent):
        while not Parent.exists() and not Parent.is_symlink():
            Parent = Parent.parent
        if not Parent.is_dir() or Parent.is_symlink() or not os.access(Parent, os.W_OK):
            raise ValueError(f"installation parent is not a writable directory: {Parent}")
    if check:
        print(f"CLI destination available: {Prefix}")
        return
    subprocess.run(["Rscript", str(Path(__file__).with_name("checkRuntime.R")),
                    str(Source.parent / "install/requirements.R")], check=True)
    Runtime.parent.mkdir(parents=True, exist_ok=True)
    Launcher.parent.mkdir(parents=True, exist_ok=True)
    Directory = Path(tempfile.mkdtemp(prefix=".ngr-install-", dir=Runtime.parent))
    Cleanup = True
    try:
        Stage = Directory / "runtime"
        Stage.mkdir()
        DATA = {"product": "ngr", "files": {}}
        for FILE in Files:
            Name = FILE.relative_to(Source).as_posix()
            if FILE.is_symlink():
                raise ValueError(f"source runtime symlink: {FILE}")
            Target = Stage / Name
            Target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(FILE, Target)
            Target.chmod(0o755 if Name == "bin/ngr" else 0o644)
            DATA["files"][Name] = digest(Target)
        LauncherBytes = {}
        LauncherBackups = {}
        for Key, Entry in Launchers.items():
            Content = (Stage / "bin" / Entry.name).read_bytes().replace(
                b"..\\main.R", b"..\\libexec\\ngr\\main.R")
            LauncherBytes[Entry] = Content
            DATA[Key] = {"path": f"bin/{Entry.name}", "sha256": hashlib.sha256(Content).hexdigest()}
            if Entry.exists():
                LauncherBackups[Entry] = Directory / Entry.name
                shutil.copy2(Entry, LauncherBackups[Entry])
        (Stage / "INSTALL_MANIFEST.json").write_text(json.dumps(DATA, indent=2) + "\n", encoding="utf-8")
        Backup = Directory / "previous"
        Linked = Launcher.is_symlink()
        Installed = False
        try:
            if Runtime.exists():
                Runtime.rename(Backup)
            Stage.rename(Runtime)
            Installed = True
            for Entry, Content in LauncherBytes.items():
                with tempfile.NamedTemporaryFile(prefix=".ngr-launcher-", dir=Entry.parent, delete=False) as FILE:
                    LauncherStage = Path(FILE.name)
                    FILE.write(Content)
                try:
                    os.replace(LauncherStage, Entry)
                finally:
                    LauncherStage.unlink(missing_ok=True)
            if not Windows and not Linked:
                Launcher.symlink_to(os.path.relpath(Runtime / "bin/ngr", Launcher.parent))
        except OSError:
            try:
                if Installed:
                    shutil.rmtree(Runtime)
                if Backup.exists():
                    Backup.rename(Runtime)
                for Entry in LauncherBytes:
                    if Entry in LauncherBackups:
                        shutil.copy2(LauncherBackups[Entry], Entry)
                    if Entry not in LauncherBackups:
                        Entry.unlink(missing_ok=True)
            except OSError as e:
                Cleanup = False
                raise OSError(f"restore failed; recovery files retained at {Directory}: {e}") from e
            raise
    finally:
        if Cleanup:
            shutil.rmtree(Directory)
    print(f"Installed ngr CLI: {Launcher}")


if __name__ == "__main__":
    Parser = argparse.ArgumentParser(description=__doc__)
    Parser.add_argument("--prefix", type=Path, required=True, help="installation prefix (bin/ and libexec/ngr/)")
    Mode = Parser.add_mutually_exclusive_group()
    Mode.add_argument("--uninstall", action="store_true")
    Mode.add_argument("--check", action="store_true", help="check distribution and destination without installing")
    ARGS = Parser.parse_args()
    try:
        installRuntime(ARGS.prefix, ARGS.uninstall, check=ARGS.check)
    except (OSError, ValueError, subprocess.CalledProcessError) as e:
        Parser.exit(1, f"ngr install: {e}\n")
