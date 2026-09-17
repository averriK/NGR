import hashlib
from html.parser import HTMLParser
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import zipfile


NGR_TEST_BIN = os.environ["NGR_TEST_BIN"]
NGR_TEST_ROOT = os.environ["NGR_TEST_ROOT"]
NGR_REFERENCE_BIN = os.environ.get("NGR_REFERENCE_BIN")


class TextParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.Text = []
        self.Hidden = 0

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style"):
            self.Hidden += 1

    def handle_endtag(self, tag):
        if tag in ("script", "style"):
            self.Hidden -= 1

    def handle_data(self, data):
        if not self.Hidden and data.strip():
            self.Text.append(data.strip())


class RenderTest(unittest.TestCase):
    def testProfilesAndReference(self):
        with tempfile.TemporaryDirectory(dir=NGR_TEST_ROOT) as DIR:
            Root = Path(DIR)
            Candidate = Root / "candidate"
            Candidate.mkdir()
            subprocess.run([NGR_TEST_BIN, "pull", "--from", "ngr", "styles", "yml", "lua"], cwd=Candidate, check=True, stdout=subprocess.DEVNULL)
            (Candidate / "_master").mkdir()
            Inputs = {
                "index.qmd": "# Introduction\n\nNGR composition check.\n",
                "chapter.qmd": "# Results\n\n| Name | Value |\n|---|---:|\n| Alpha | 17 |\n",
                "appendix.qmd": "# Appendix data\n\nPreserved appendix.\n",
                "_master/book.qmd": "---\ntitle: Fusion check\nchapters:\n  - index.qmd\n  - chapter.qmd\nappendices:\n  - appendix.qmd\n---\n",
                "_master/slides.qmd": "---\ntitle: Presentation check\n---\n\n## Evidence\n\nSlide sentinel 17.\n",
                "_master/document.qmd": "---\ntitle: Word check\n---\n\n# Results\n\n| Name | Value |\n|---|---:|\n| Alpha | 17 |\n",
                "_master/page.qmd": "---\ntitle: HTML check\n---\n\n# Evidence\n\n```{r}\npackageVersion(\"NGR\")\n```\n\nHTML sentinel 17.\n"
            }
            for Name, Content in Inputs.items():
                (Candidate / Name).write_text(Content, encoding="utf-8")
            if os.environ.get("NGR_TEST_LIBRARY"):
                Inputs["_master/page.qmd"] += '\n```{r}\nstopifnot(normalizePath(find.package("NGR")) == normalizePath(file.path(Sys.getenv("NGR_TEST_LIBRARY"), "NGR")))\nfind.package("NGR")\n```\n'
                (Candidate / "_master/page.qmd").write_text(Inputs["_master/page.qmd"], encoding="utf-8")
            Artifacts = []
            for Alias, Source, Profile, Output in (
                ("page", "_master/page.qmd", "html", "html/page-custom"),
                ("slides", "_master/slides.qmd", "revealjs", "html/slides"),
                ("book", "_master/book.qmd", "book", "html/book"),
                ("word", "_master/document.qmd", "docx", "docx"),
                ("word-book", "_master/book.qmd", "docx", "docx"),
            ):
                Artifacts.append(dict(alias=Alias, kind="quarto", renderSource=Source, profile=Profile, path=Output, required=True))
            Manifest = Candidate / "manifest.json"
            DATA = json.loads(Manifest.read_text())
            DATA["artifacts"] = Artifacts
            Manifest.write_text(json.dumps(DATA), encoding="utf-8")
            Reference = Root / "reference"
            shutil.copytree(Candidate, Reference)
            (Reference / "manifest.json").rename(Reference / "qrt.manifest.json")
            Cases = [(NGR_TEST_BIN, Candidate, "manifest.json")]
            if NGR_REFERENCE_BIN:
                Cases.append((NGR_REFERENCE_BIN, Reference, "qrt.manifest.json"))
            for Binary, Project, Name in Cases:
                Before = {x: hashlib.sha256((Project / x).read_bytes()).hexdigest() for x in Inputs}
                DATA = subprocess.run([Binary, "render", "--manifest", Name], cwd=Project, capture_output=True, text=True)
                self.assertEqual(DATA.returncode, 0, DATA.stdout[-3000:] + DATA.stderr[-7000:])
                self.assertEqual(Before, {x: hashlib.sha256((Project / x).read_bytes()).hexdigest() for x in Inputs})
                for Name, Sentinel in (("page-custom", "HTML sentinel 17"), ("slides", "Slide sentinel 17"), ("book", "NGR composition check")):
                    FILE = Project / "html" / Name / "index.html"
                    self.assertIn(Sentinel, FILE.read_text(encoding="utf-8"))
                if os.environ.get("NGR_TEST_LIBRARY"):
                    self.assertIn((Path(os.environ["NGR_TEST_LIBRARY"]).resolve() / "NGR").as_posix(),
                                  (Project / "html/page-custom/index.html").read_text(encoding="utf-8"))
                for Name in ("book", "document"):
                    with zipfile.ZipFile(Project / "docx" / f"{Name}.docx") as ZIP:
                        DATA = ZIP.read("word/document.xml")
                        self.assertIn(b"Alpha", DATA)
                        self.assertIn(b'autofit', DATA)
                        if Name == "book":
                            self.assertIn(b"Preserved appendix", DATA)
            if NGR_REFERENCE_BIN:
                for Name in ("page-custom", "slides", "book"):
                    Texts = []
                    for Project in (Candidate, Reference):
                        Parser = TextParser()
                        Parser.feed((Project / "html" / Name / "index.html").read_text(encoding="utf-8"))
                        Texts.append(Parser.Text)
                    self.assertEqual(*Texts)
                for Name in ("book", "document"):
                    Documents = []
                    for Project in (Candidate, Reference):
                        with zipfile.ZipFile(Project / "docx" / f"{Name}.docx") as ZIP:
                            Documents.append({x: ZIP.read(x) for x in ("word/document.xml", "word/styles.xml", "word/numbering.xml")})
                    self.assertEqual(*Documents)

    def testExternalProductsNeverRunProducers(self):
        with tempfile.TemporaryDirectory(dir=NGR_TEST_ROOT) as DIR:
            Root = Path(DIR)
            (Root / "pipeline.py").write_text("from pathlib import Path\nPath('calls').write_text('unexpected producer execution')\n")
            for Name in ("one", "two"):
                (Root / "html" / Name).mkdir(parents=True)
                (Root / "html" / Name / "index.html").write_text("external " + Name)
            (Root / "html/static").mkdir(parents=True)
            (Root / "html/static/index.html").write_text("static sentinel")
            Artifacts = [dict(alias=x, kind="map", renderSource="pipeline.py", path=f"html/{x}", pythonModules=["json"], required=True) for x in ("one", "two")]
            Artifacts.append(dict(alias="static", kind="static", path="html/static", required=True))
            Manifest = Root / "manifest.json"
            Manifest.write_text(json.dumps(dict(schemaVersion=2, artifacts=Artifacts)))
            DATA = subprocess.run([NGR_TEST_BIN, "render", "--manifest", str(Manifest)], cwd=Root, capture_output=True, text=True)
            self.assertEqual(DATA.returncode, 0, DATA.stderr)
            self.assertFalse((Root / "calls").exists())
            self.assertEqual((Root / "html/static/index.html").read_text(), "static sentinel")
            (Root / "html/two/index.html").unlink()
            Manifest.write_text(json.dumps(dict(schemaVersion=2, artifacts=Artifacts)))
            DATA = subprocess.run([NGR_TEST_BIN, "render", "--manifest", str(Manifest)], cwd=Root, capture_output=True, text=True)
            self.assertNotEqual(DATA.returncode, 0)
            self.assertIn("Missing required output", DATA.stderr)
            self.assertFalse((Root / "calls").exists())


if __name__ == "__main__":
    unittest.main()
