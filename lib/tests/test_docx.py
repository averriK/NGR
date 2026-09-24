"""CAN composition and reference checks against a real Quarto fixture."""

from copy import deepcopy
from hashlib import sha256
import json
from pathlib import Path
import tempfile
import unittest
import subprocess

from lxml import etree

import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "inst/docx"))
import compose_docx as srk


Root = Path(__file__).resolve().parent / "fixtures/docx"
Resources = Path(srk.__file__).resolve().parent


class DocxTests(unittest.TestCase):
    def setUp(self):
        self.Directory = tempfile.TemporaryDirectory()
        self.Root = Path(self.Directory.name)
        self.addCleanup(self.Directory.cleanup)
        self.Spec = json.loads((Root / "spec.json").read_text())
        self.SpecPath = self.Root / "spec.json"
        self.Output = self.Root / "output.docx"

    def compose(self, contentPath=None):
        self.SpecPath.write_text(json.dumps(self.Spec), encoding="utf-8")
        return srk.composeDocument(templatePath=Resources / "srk-template.zip", contentPath=contentPath or Root / "content.docx", specPath=self.SpecPath, outputPath=self.Output)

    def contentWith(self, change):
        Parts = srk.readPackage(Root / "content.docx")
        change(Parts)
        Target = self.Root / "content.docx"
        srk.writePackage(Parts, outputPath=Target, inputPaths=[])
        return Target

    def testThreeAppendicesPreserveObjects(self):
        Manifest = self.compose()
        Parts = srk.readPackage(self.Output)
        Content = srk.readPackage(Root / "content.docx")
        Document = srk._xml(Parts["word/document.xml"])
        Before = srk._xml(Content["word/document.xml"])
        Before.find("w:body", srk.NS).remove(Before.find("w:body/w:p", srk.NS))
        # The fixture has four Quarto caption wrappers. Compare the semantic
        # tables after removing only those known layout containers independently.
        Wrappers = Before.xpath("./w:body/w:tbl[./w:tr/w:tc/w:tbl]", namespaces=srk.NS)
        self.assertEqual(4, len(Wrappers))
        self.assertEqual(4, Manifest["repairs"]["tableWrappers"])
        for x in Wrappers:
            Parent = x.getparent()
            i = Parent.index(x)
            for v in list(x.find("w:tr/w:tc", srk.NS)):
                if v.tag != f"{{{srk.W}}}tcPr":
                    Parent.insert(i, v)
                    i += 1
            Parent.remove(x)
        self.assertEqual(8, len(Document.findall(".//w:sectPr", srk.NS)))
        Ids = Document.xpath(".//@w14:paraId", namespaces={"w14": "http://schemas.microsoft.com/office/word/2010/wordml"})
        self.assertEqual(len(Ids), len(set(Ids)))
        self.assertGreater(Manifest["repairs"]["captionProperties"], 0)
        for s in ("word/footnotes.xml", "word/endnotes.xml"):
            self.assertEqual(Content.get(s), Parts.get(s))
        for s in Content:
            if s.startswith("word/media/"):
                self.assertEqual(Content[s], Parts[s])
        Body = Document.find("w:body", srk.NS)
        for x in list(Body)[:Manifest["coverElements"] + 1]:
            Body.remove(x)
        for x in self.Spec["appendices"]:
            Bookmark = Body.xpath("./w:bookmarkStart[@w:name=$name]", namespaces=srk.NS, name=x["bookmark"])[0]
            Table = Bookmark.getnext()
            Body.replace(Table, Table.find("w:tr/w:tc/w:p", srk.NS))
        for s in ("m:oMath", "w:tblGrid", "w:tcW", "w:gridSpan", "w:vMerge", "w:footnoteReference"):
            self.assertEqual([etree.tostring(v) for v in Before.findall(".//" + s, srk.NS)], [etree.tostring(v) for v in Document.findall(".//" + s, srk.NS)])
        self.assertEqual(len(Before.findall(".//w:drawing", srk.NS)), len(Document.findall(".//w:drawing", srk.NS)))
        self.assertFalse(Document.xpath("./w:body/w:tbl[./w:tr/w:tc/w:tbl]", namespaces=srk.NS))
        self.assertFalse(Document.xpath(".//w:instrText[contains(.,'FORMTEXT') or contains(.,'MACROBUTTON')]", namespaces=srk.NS))

    def testNoGeneratedCoverImageOrGeometryChanges(self):
        self.compose()
        SourceParts = srk._readTemplate(Resources / "srk-template.zip")
        SourceBody = srk._xml(SourceParts["cover.xml"])
        Document = srk._xml(srk.readPackage(self.Output)["word/document.xml"])
        Cover = Document.find("w:body/w:tbl", srk.NS)
        CoverSource = SourceBody.find("w:tbl", srk.NS)
        self.assertEqual(1, len(Cover.findall(".//w:drawing", srk.NS)))
        self.assertEqual(SourceParts["logo.wmf"], srk.readPackage(self.Output)["word/media/srk-na-logo.wmf"])
        self.assertFalse(Cover.findall(".//w:sdt", srk.NS))
        self.assertNotIn("Crawford", "".join(Cover.xpath(".//w:t/text()", namespaces=srk.NS)))
        self.assertNotIn("`", "".join(Cover.xpath(".//w:t/text()", namespaces=srk.NS)))
        for s in ("tblW", "gridCol", "tcW", "trHeight", "tblpPr", "framePr"):
            self.assertEqual([dict(v.attrib) for v in CoverSource.findall(".//w:" + s, srk.NS)], [dict(v.attrib) for v in Cover.findall(".//w:" + s, srk.NS)])
        self.assertFalse(Cover.findall(".//w:sym", srk.NS))

    def testVariableAppendixCounts(self):
        for n in (0, 2):
            with self.subTest(appendices=n):
                self.Spec["appendices"] = json.loads((Root / "spec.json").read_text())["appendices"][:n]
                self.compose()
                Document = srk._xml(srk.readPackage(self.Output)["word/document.xml"])
                self.assertEqual(2 + 2 * n, len(Document.findall(".//w:sectPr", srk.NS)))

    def testMissingDuplicateAndUnorderedBookmarksPreserveOutput(self):
        Cases = [[{"bookmark": "missing"}], [self.Spec["appendices"][0]] * 2, list(reversed(self.Spec["appendices"]))]
        for x in Cases:
            with self.subTest(appendices=x):
                self.Output.write_bytes(b"prior output")
                self.Spec["appendices"] = x
                with self.assertRaises(ValueError):
                    self.compose()
                self.assertEqual(b"prior output", self.Output.read_bytes())

    def testUnknownMetadataRejected(self):
        self.Spec["cover"]["invented"] = "x"
        with self.assertRaisesRegex(ValueError, "explicit"):
            self.compose()
        self.assertFalse(self.Output.exists())

    def testAlreadyComposedRejected(self):
        self.compose()
        Baseline = self.Output.read_bytes()
        with self.assertRaisesRegex(ValueError, "already composed"):
            self.compose(contentPath=self.Output)
        self.assertEqual(Baseline, self.Output.read_bytes())

    def testInputCannotBeOverwritten(self):
        Content = self.contentWith(lambda parts: None)
        self.Output = Content
        Baseline = Content.read_bytes()
        with self.assertRaisesRegex(ValueError, "overwrite an input"):
            self.compose(contentPath=Content)
        self.assertEqual(Baseline, Content.read_bytes())

    def testGeneratedTitleTypographyDoesNotOverrideCoverMetadata(self):
        def change(parts):
            x = srk._xml(parts["word/document.xml"])
            x.find("w:body/w:p/w:r/w:t", srk.NS).text = "Formato de informes SRK – demostración"
            parts["word/document.xml"] = srk._bytes(x)
        self.Spec["cover"]["title"] = "Formato de informes SRK -- demostración"
        self.compose(contentPath=self.contentWith(change))
        x = srk._xml(srk.readPackage(self.Output)["word/document.xml"])
        self.assertIn(self.Spec["cover"]["title"], x.xpath(".//w:t/text()", namespaces=srk.NS))

    def testInternalSectionRejected(self):
        def change(parts):
            x = srk._xml(parts["word/document.xml"])
            x.find("w:body/w:p/w:pPr", srk.NS).append(deepcopy(x.find("w:body/w:sectPr", srk.NS)))
            parts["word/document.xml"] = srk._bytes(x)
        Content = self.contentWith(change)
        with self.assertRaisesRegex(ValueError, "internal sections"):
            self.compose(contentPath=Content)

    def testUnknownPropertyConflictRejected(self):
        def change(parts):
            x = srk._xml(parts["word/document.xml"])
            v = x.find("w:body/w:p/w:pPr", srk.NS)
            v.append(deepcopy(v.find("w:pStyle", srk.NS)))
            parts["word/document.xml"] = srk._bytes(x)
        Content = self.contentWith(change)
        with self.assertRaisesRegex(ValueError, "conflicting paragraph property"):
            self.compose(contentPath=Content)

    def testUnknownAlignmentRejectedAndTableAlignmentPreserved(self):
        x = srk._xml(f'<w:document xmlns:w="{srk.W}"><w:p><w:pPr><w:jc w:val="left"/><w:jc w:val="right"/></w:pPr></w:p></w:document>'.encode())
        with self.assertRaisesRegex(ValueError, "conflicting paragraph alignment"):
            srk.normalizeParagraphs(x)
        self.compose()
        x = srk._xml(srk.readPackage(self.Output)["word/document.xml"])
        Values = x.xpath(".//w:tbl[w:tblPr/w:tblStyle/@w:val='SRKDataTable']//w:pPr/w:jc/@w:val", namespaces=srk.NS)
        self.assertTrue(Values)
        self.assertEqual({"left"}, set(Values))

    def testStyleCollisionPreservesExistingStyle(self):
        def change(parts):
            x = srk._xml(parts["word/styles.xml"])
            v = deepcopy(x.xpath("./w:style[@w:styleId='Normal']", namespaces=srk.NS)[0])
            v.set(f"{{{srk.W}}}styleId", "SRKCover1")
            v.find("w:name", srk.NS).set(f"{{{srk.W}}}val", "Existing unrelated style")
            v.attrib.pop(f"{{{srk.W}}}default", None)
            x.append(v)
            parts["word/styles.xml"] = srk._bytes(x)
        Manifest = self.compose(contentPath=self.contentWith(change))
        self.assertEqual("SRK1Cover1", Manifest["mapping"]["styles"]["Cover1"])

    def testAppendixLabelsIsolatedFromBodyNumbering(self):
        Manifest = self.compose()
        Parts = srk.readPackage(self.Output)
        Numbering = srk._xml(Parts["word/numbering.xml"])
        n = Manifest["mapping"]["nums"]["6"]
        Labels = Numbering.xpath("./w:num[@w:numId=$id]/w:lvlOverride/w:lvl/w:lvlText/@w:val", namespaces=srk.NS, id=n)
        self.assertIn("Appendix %8", Labels)
        StyleIds = set(srk._xml(Parts["word/styles.xml"]).xpath("./w:style/@w:styleId", namespaces=srk.NS))
        self.assertTrue(set(Numbering.xpath(".//w:pStyle/@w:val", namespaces=srk.NS)) <= StyleIds)
        Document = srk._xml(Parts["word/document.xml"])
        for x in self.Spec["appendices"]:
            Bookmark = Document.xpath(".//w:bookmarkStart[@w:name=$name]", namespaces=srk.NS, name=x["bookmark"])[0]
            Table = Bookmark.getnext()
            self.assertEqual("center", Table.find("w:tr/w:tc/w:tcPr/w:vAlign", srk.NS).get(f"{{{srk.W}}}val"))
            self.assertFalse(Table.findall(".//w:drawing", srk.NS))
            self.assertEqual("0", Table.find("w:tr/w:tc/w:p/w:pPr/w:numPr/w:numId", srk.NS).get(f"{{{srk.W}}}val"))
            self.assertIn("Appendix ", "".join(Table.xpath(".//w:t/text()", namespaces=srk.NS)))

    def testReferenceRolesAndNoScientificContent(self):
        srk.checkReference(Resources / "reference.docx")
        Parts = srk.readPackage(Resources / "reference.docx")
        Styles = srk._xml(Parts["word/styles.xml"])
        for s, n in (("Heading1", "32"), ("Heading2", "24"), ("Heading3", "20"), ("Heading4", "20"), ("BodyText", "20"), ("SRKTableText", "18"), ("TableHeading", "18")):
            x = Styles.xpath("./w:style[@w:styleId=$id]", namespaces=srk.NS, id=s)[0]
            self.assertEqual("Arial", x.find("w:rPr/w:rFonts", srk.NS).get(f"{{{srk.W}}}ascii"))
            self.assertEqual(n, x.find("w:rPr/w:sz", srk.NS).get(f"{{{srk.W}}}val"))
        for s in ("Heading1", "Heading2", "Heading3", "Heading4"):
            self.assertFalse(Styles.xpath("./w:style[@w:styleId=$id]/w:pPr/w:numPr", namespaces=srk.NS, id=s))
        self.assertFalse(Styles.xpath("./w:style[@w:styleId='Table']//w:tblBorders", namespaces=srk.NS))
        self.assertTrue(Styles.xpath("./w:style[@w:styleId='SRKDataTable']//w:tblBorders", namespaces=srk.NS))
        self.assertFalse(any(s.startswith(("customXml/", "docProps/", "word/footnotes")) for s in Parts))
        for s, x in Parts.items():
            if s.endswith(".xml"):
                self.assertNotIn("Crawford", "".join(srk._xml(x).xpath(".//w:t/text()", namespaces=srk.NS)))

    def testCrossReferenceBibliographyAndTableRoles(self):
        Manifest = self.compose()
        Document = srk._xml(srk.readPackage(self.Output)["word/document.xml"])
        Links = Document.xpath(".//w:hyperlink[@w:anchor='sec-demo-apx-a']//w:t/text()", namespaces=srk.NS)
        self.assertEqual("Appendix\u00a0A", "".join(Links))
        self.assertEqual(1, len(Document.xpath(".//w:bookmarkStart[@w:name='ref-Newmark1965']", namespaces=srk.NS)))
        self.assertEqual(2, len(Document.xpath(".//w:hyperlink[@w:anchor='ref-Newmark1965']", namespaces=srk.NS)))
        self.assertGreater(Manifest["repairs"]["cellEndings"], 0)
        Tables = Document.xpath(".//w:tbl[w:tblPr/w:tblStyle/@w:val='SRKDataTable']", namespaces=srk.NS)
        self.assertEqual(2, len(Tables))
        for x in Tables:
            self.assertTrue(x.xpath("./w:tr[w:trPr/w:tblHeader]//w:pStyle[@w:val='TableHeading']", namespaces=srk.NS))
            self.assertTrue(x.xpath("./w:tr[not(w:trPr/w:tblHeader)]//w:pStyle[@w:val='SRKTableText']", namespaces=srk.NS))

    def testReplaceTextPreservesRunFontOverParagraphMark(self):
        x = srk._xml(f'<w:p xmlns:w="{srk.W}"><w:pPr><w:rPr><w:sz w:val="20"/></w:rPr></w:pPr><w:r><w:rPr><w:sz w:val="48"/></w:rPr><w:t>Before</w:t></w:r></w:p>'.encode())
        srk._replaceText(x, "After")
        self.assertEqual("48", x.find("w:r/w:rPr/w:sz", srk.NS).get(f"{{{srk.W}}}val"))

    def testMissingLxmlHasActionableError(self):
        OUT = subprocess.run([sys.executable, "-S", str(Resources / "compose_docx.py"), "check-reference", "--reference", str(Resources / "reference.docx")], capture_output=True, text=True)
        self.assertNotEqual(0, OUT.returncode)
        self.assertIn("requires lxml in this Python interpreter", OUT.stderr)

    def testWrongTemplateHashAndTamperingRejected(self):
        Target = self.Root / "template.zip"
        Target.write_bytes(b"prior output")
        with self.assertRaisesRegex(ValueError, "hash differs"):
            srk.prepareTemplate(sourcePath=Root / "content.docx", outputPath=Target)
        self.assertEqual(b"prior output", Target.read_bytes())
        Parts = srk.readPackage(Resources / "srk-template.zip")
        Parts["cover.xml"] += b" "
        srk.writePackage(Parts, outputPath=Target, inputPaths=[])
        with self.assertRaisesRegex(ValueError, "digest mismatch"):
            srk._readTemplate(Target)

    def testMissingRelationshipUseRejected(self):
        def change(parts):
            x = srk._xml(parts["word/document.xml"])
            v = x.xpath(".//*[@r:embed]", namespaces=srk.NS)[0]
            v.set(f"{{{srk.R}}}embed", "rIdMissing")
            parts["word/document.xml"] = srk._bytes(x)
        self.Output.write_bytes(b"prior output")
        with self.assertRaisesRegex(ValueError, "Unresolved relationship use"):
            self.compose(contentPath=self.contentWith(change))
        self.assertEqual(b"prior output", self.Output.read_bytes())

    def testCyclicStyleInheritanceRejected(self):
        def change(parts):
            x = srk._xml(parts["word/styles.xml"])
            v = x.xpath("./w:style[@w:styleId='BodyText']", namespaces=srk.NS)[0]
            for t in v.findall("w:basedOn", srk.NS):
                v.remove(t)
            etree.SubElement(v, f"{{{srk.W}}}basedOn", {f"{{{srk.W}}}val": "BodyText"})
            parts["word/styles.xml"] = srk._bytes(x)
        self.Output.write_bytes(b"prior output")
        with self.assertRaisesRegex(ValueError, "Cyclic style inheritance"):
            self.compose(contentPath=self.contentWith(change))
        self.assertEqual(b"prior output", self.Output.read_bytes())

    def testCustomizedTableWrapperIsPreserved(self):
        for s in ("cell", "row", "grid"):
            with self.subTest(property=s):
                Parts = srk.readPackage(Root / "content.docx")
                x = srk._xml(Parts["word/document.xml"])
                Table = x.xpath("./w:body/w:tbl[./w:tr/w:tc/w:tbl]", namespaces=srk.NS)[0]
                if s == "cell":
                    etree.SubElement(Table.find("w:tr/w:tc/w:tcPr", srk.NS), f"{{{srk.W}}}shd", {f"{{{srk.W}}}fill": "FFFF00"})
                if s == "row":
                    etree.SubElement(Table.find("w:tr", srk.NS), f"{{{srk.W}}}trPr")
                if s == "grid":
                    Table.find("w:tblGrid/w:gridCol", srk.NS).set(f"{{{srk.W}}}w", "8000")
                Before = etree.tostring(Table)
                self.assertEqual(3, srk._unwrapTables(x))
                self.assertEqual(Before, etree.tostring(Table))
                self.assertIsNotNone(Table.getparent())

    def testUnpairedBookmarkAndMissingNoteRejected(self):
        for s in ("bookmark", "footnote"):
            with self.subTest(failure=s):
                def change(parts):
                    x = srk._xml(parts["word/document.xml"])
                    if s == "bookmark":
                        v = x.find(".//w:bookmarkEnd", srk.NS)
                        v.getparent().remove(v)
                    else:
                        x.find(".//w:footnoteReference", srk.NS).set(f"{{{srk.W}}}id", "2147483647")
                    parts["word/document.xml"] = srk._bytes(x)
                self.Output.write_bytes(b"prior output")
                with self.assertRaisesRegex(ValueError, "bookmark identity|footnote definition"):
                    self.compose(contentPath=self.contentWith(change))
                self.assertEqual(b"prior output", self.Output.read_bytes())

    def testMissingMetadataControlRejected(self):
        def change(parts):
            x = srk._xml(parts["word/header1.xml"])
            v = x.find(".//w:sdtPr/w:tag", srk.NS)
            v.getparent().remove(v)
            parts["word/header1.xml"] = srk._bytes(x)
        with self.assertRaisesRegex(ValueError, "metadata controls missing"):
            self.compose(contentPath=self.contentWith(change))

    def testOutputReproducible(self):
        self.compose()
        Baseline = sha256(self.Output.read_bytes()).hexdigest()
        self.compose()
        self.assertEqual(Baseline, sha256(self.Output.read_bytes()).hexdigest())


if __name__ == "__main__":
    unittest.main()
