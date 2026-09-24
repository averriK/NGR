"""Build the CAN reference and components from the admitted human report."""

import argparse
from copy import deepcopy
from hashlib import sha256
import json
from pathlib import Path

from lxml import etree

import compose_docx as docx


W, R, NS = docx.W, docx.R, docx.NS
ALIASES = {
    "FirstParagraph": ("First Paragraph", "BodyText"),
    "Compact": ("Compact", "Normal"),
    "TableCaption": ("Table Caption", "Caption"),
    "ImageCaption": ("Image Caption", "Caption"),
    "Figure": ("Figure", "BodyText"),
    "CaptionedFigure": ("Captioned Figure", "BodyText"),
    "FootnoteBlockText": ("Footnote Block Text", "FootnoteText"),
    "BlockText": ("Block Text", "BodyText"),
    "DefinitionTerm": ("Definition Term", "BodyText"),
    "Definition": ("Definition", "BodyText"),
    "Title": ("Title", "Cover1"),
    "Subtitle": ("Subtitle", "Cover3"),
    "Author": ("Author", "Normal"),
    "Date": ("Date", "Normal"),
    "Abstract": ("Abstract", "BodyText"),
    "AbstractTitle": ("Abstract Title", "Heading1"),
}


def _control(tag, text):
    Control = etree.Element(f"{{{W}}}sdt")
    Properties = etree.SubElement(Control, f"{{{W}}}sdtPr")
    etree.SubElement(Properties, f"{{{W}}}tag", {f"{{{W}}}val": tag})
    etree.SubElement(Properties, f"{{{W}}}text")
    Content = etree.SubElement(Control, f"{{{W}}}sdtContent")
    etree.SubElement(etree.SubElement(Content, f"{{{W}}}r"), f"{{{W}}}t").text = text
    return Control


def buildReference(sourcePath, outputPath):
    if sha256(Path(sourcePath).read_bytes()).hexdigest() != docx.DIGEST:
        raise ValueError("CAN reference source differs from the admitted report")
    Source = docx.readPackage(sourcePath)
    Document = docx._xml(Source["word/document.xml"])
    Styles = docx._xml(Source["word/styles.xml"])
    Numbering = docx._xml(Source["word/numbering.xml"])
    Index = {x.get(f"{{{W}}}styleId"): x for x in Styles.findall("w:style", NS)}
    # Pandoc reserves Table for a table style; CAN uses that id for cell text.
    Index["Table"].set(f"{{{W}}}styleId", "SRKTableText")
    Index["Table"].find("w:name", NS).set(f"{{{W}}}val", "SRK Table Text")
    for x in (Styles, Numbering):
        for v in x.xpath(".//w:basedOn[@w:val='Table'] | .//w:next[@w:val='Table'] | .//w:link[@w:val='Table'] | .//w:pStyle[@w:val='Table']", namespaces=NS):
            v.set(f"{{{W}}}val", "SRKTableText")
    x = deepcopy(Index["TableNormal"])
    x.set(f"{{{W}}}styleId", "Table")
    x.attrib.pop(f"{{{W}}}default", None)
    x.find("w:name", NS).set(f"{{{W}}}val", "Table")
    Styles.append(x)
    # Quarto uses Table for layout wrappers too. Only semantic data tables
    # receive CAN's rules, taken from the admitted report's first body table.
    Caption = docx._one(Document.xpath("./w:body/w:p[w:pPr/w:pStyle/@w:val='Caption'][contains(.,'Project Site Coordinates')]", namespaces=NS), "CAN body table caption")
    Table = Caption.getnext()
    if Table.tag != f"{{{W}}}tbl":
        raise ValueError("CAN body table no longer follows its caption")
    x = deepcopy(x)
    x.set(f"{{{W}}}styleId", "SRKDataTable")
    x.find("w:name", NS).set(f"{{{W}}}val", "SRK Data Table")
    Properties = x.find("w:tblPr", NS)
    for v in list(Properties):
        Properties.remove(v)
    Borders = etree.SubElement(Properties, f"{{{W}}}tblBorders")
    Rows = Table.findall("w:tr", NS)
    Top = Rows[0].find("w:tc/w:tcPr/w:tcBorders", NS)
    Bottom = Rows[-1].find("w:tc/w:tcPr/w:tcBorders", NS)
    for SourceBorder in (Top.find("w:top", NS), Bottom.find("w:bottom", NS), Top.find("w:left", NS), Top.find("w:right", NS)):
        Borders.append(deepcopy(SourceBorder))
    for s in ("insideH", "insideV"):
        etree.SubElement(Borders, f"{{{W}}}{s}", {f"{{{W}}}val": "nil"})
    Properties.append(deepcopy(Table.find("w:tblPr/w:tblCellMar", NS)))
    v = etree.SubElement(x, f"{{{W}}}tblStylePr", {f"{{{W}}}type": "firstRow"})
    etree.SubElement(v, f"{{{W}}}tcPr").append(deepcopy(Top))
    Styles.append(x)
    # Quarto owns section and cross-reference numbers; Word must not add a
    # second label or number a heading explicitly marked unnumbered.
    for s in ("Heading1", "Heading2", "Heading3", "Heading4"):
        v = Index[s].find("w:pPr", NS)
        if s != "Heading4":
            Indent = docx._one(Numbering.xpath("./w:num[@w:numId='6']/w:lvlOverride/w:lvl[w:pStyle/@w:val=$id]/w:pPr/w:ind", namespaces=NS, id=s), "CAN numbered heading indent")
            for x in v.findall("w:ind", NS) + v.findall("w:tabs", NS):
                v.remove(x)
            v.append(deepcopy(Indent))
            etree.SubElement(etree.SubElement(v, f"{{{W}}}tabs"), f"{{{W}}}tab", {f"{{{W}}}val": "left", f"{{{W}}}pos": Indent.get(f"{{{W}}}left")})
        for x in v.findall("w:numPr", NS):
            v.remove(x)
        v[:] = sorted(v, key=lambda p: docx.PORDER[etree.QName(p).localname])
    for x in Numbering.xpath(".//w:pStyle[@w:val='Heading1' or @w:val='Heading2' or @w:val='Heading3' or @w:val='Heading4']", namespaces=NS):
        x.getparent().remove(x)
    for s, (Name, Base) in ALIASES.items():
        for x in Styles.xpath("w:style[@w:styleId=$id]", namespaces=NS, id=s):
            Styles.remove(x)
        x = etree.SubElement(Styles, f"{{{W}}}style", {f"{{{W}}}type": "paragraph", f"{{{W}}}styleId": s})
        etree.SubElement(x, f"{{{W}}}name", {f"{{{W}}}val": Name})
        etree.SubElement(x, f"{{{W}}}basedOn", {f"{{{W}}}val": Base})
    for s, Name in (("VerbatimChar", "Verbatim Char"), ("FootnoteReference", "Footnote Reference")):
        if s in Index:
            continue
        x = etree.SubElement(Styles, f"{{{W}}}style", {f"{{{W}}}type": "character", f"{{{W}}}styleId": s})
        etree.SubElement(x, f"{{{W}}}name", {f"{{{W}}}val": Name})
        etree.SubElement(x, f"{{{W}}}basedOn", {f"{{{W}}}val": "DefaultParagraphFont"})
        if s == "FootnoteReference":
            etree.SubElement(etree.SubElement(x, f"{{{W}}}rPr"), f"{{{W}}}vertAlign", {f"{{{W}}}val": "superscript"})
    # CAN stores these bullet references as direct paragraph formatting.
    for i, s in enumerate(("ListBullet", "ListBullet2", "ListBullet3")):
        x = Index[s].find("w:pPr", NS)
        for v in x.findall("w:numPr", NS):
            x.remove(v)
        v = etree.Element(f"{{{W}}}numPr")
        etree.SubElement(v, f"{{{W}}}ilvl", {f"{{{W}}}val": str(i)})
        etree.SubElement(v, f"{{{W}}}numId", {f"{{{W}}}val": "4"})
        x.insert(0, v)
    # Bibliography's hanging indent is direct formatting in the human report.
    x = Document.xpath(".//w:p[w:pPr/w:pStyle/@w:val='Bibliography']/w:pPr/w:ind", namespaces=NS)[0]
    v = etree.SubElement(Index["Bibliography"], f"{{{W}}}pPr")
    v.append(deepcopy(x))

    Header = docx._xml(Source["word/header3.xml"])
    Footer = docx._xml(Source["word/footer1.xml"])
    x = Header.find("w:p", NS)
    docx._replaceText(x, "")
    x.append(_control("srk.company", "{{company}}"))
    x = docx._one(Header.xpath(".//w:sdt[w:sdtPr/w:tag/@w:val='shorttitle']", namespaces=NS), "CAN short title")
    x.getparent().replace(x, _control("srk.title", "{{title}}"))
    for x in Header.xpath(".//w:r[w:rPr/w:noProof]/w:t", namespaces=NS):
        x.text = "1"
    x = Footer.find("w:p", NS)
    docx._replaceText(x, "")
    x.append(_control("srk.project", "{{project}}"))
    etree.SubElement(etree.SubElement(x, f"{{{W}}}r"), f"{{{W}}}tab")
    etree.SubElement(etree.SubElement(x, f"{{{W}}}r"), f"{{{W}}}tab")
    x.append(_control("srk.date", "{{date}}"))
    for x in (Header, Footer):
        docx._clearParagraphIds(x)

    Section = deepcopy(Document.findall(".//w:sectPr", NS)[2])
    x = etree.SubElement(Styles, f"{{{W}}}style", {f"{{{W}}}type": "paragraph", f"{{{W}}}styleId": "Equation"})
    etree.SubElement(x, f"{{{W}}}name", {f"{{{W}}}val": "Equation"})
    etree.SubElement(x, f"{{{W}}}basedOn", {f"{{{W}}}val": "BodyText"})
    Properties = etree.SubElement(x, f"{{{W}}}pPr")
    Width = int(Section.find("w:pgSz", NS).get(f"{{{W}}}w")) - sum(int(Section.find("w:pgMar", NS).get(f"{{{W}}}{s}")) for s in ("left", "right"))
    Tabs = etree.SubElement(Properties, f"{{{W}}}tabs")
    for s, n in (("center", Width // 2), ("right", Width)):
        etree.SubElement(Tabs, f"{{{W}}}tab", {f"{{{W}}}val": s, f"{{{W}}}pos": str(n)})
    etree.SubElement(Properties, f"{{{W}}}ind", {f"{{{W}}}left": "0", f"{{{W}}}firstLine": "0"})
    etree.SubElement(Properties, f"{{{W}}}jc", {f"{{{W}}}val": "left"})
    for x in list(Section):
        if etree.QName(x).localname in {"headerReference", "footerReference", "pgNumType", "titlePg"}:
            Section.remove(x)
    for i, s in enumerate(("header", "footer"), start=1):
        Section.insert(i - 1, etree.Element(f"{{{W}}}{s}Reference", {f"{{{W}}}type": "default", f"{{{R}}}id": f"srk{i}"}))
    Body = Document.find("w:body", NS)
    Body.clear()
    etree.SubElement(Body, f"{{{W}}}p")
    Body.append(Section)
    Settings = docx._xml(Source["word/settings.xml"])
    for x in list(Settings):
        if etree.QName(x).localname in {"attachedTemplate", "updateFields", "rsids", "docVars"}:
            Settings.remove(x)
    Parts = {s: Source[s] for s in ("word/fontTable.xml", "word/theme/theme1.xml", "word/webSettings.xml")}
    Parts.update({"word/document.xml": docx._bytes(Document), "word/styles.xml": docx._bytes(Styles),
                  "word/numbering.xml": docx._bytes(Numbering), "word/settings.xml": docx._bytes(Settings),
                  "word/header1.xml": docx._bytes(Header), "word/footer1.xml": docx._bytes(Footer)})
    Relationships = etree.Element(f"{{{docx.REL}}}Relationships", nsmap={None: docx.REL})
    for s, Kind, Id in (("header1.xml", "header", "srk1"), ("footer1.xml", "footer", "srk2"),
                        ("styles.xml", "styles", "srk3"), ("numbering.xml", "numbering", "srk4"),
                        ("settings.xml", "settings", "srk5"), ("fontTable.xml", "fontTable", "srk6"),
                        ("theme/theme1.xml", "theme", "srk7"), ("webSettings.xml", "webSettings", "srk8")):
        etree.SubElement(Relationships, f"{{{docx.REL}}}Relationship", Id=Id, Type=R + "/" + Kind, Target=s)
    Parts["word/_rels/document.xml.rels"] = docx._bytes(Relationships)
    Relationships = etree.Element(f"{{{docx.REL}}}Relationships", nsmap={None: docx.REL})
    etree.SubElement(Relationships, f"{{{docx.REL}}}Relationship", Id="srk1", Type=R + "/officeDocument", Target="word/document.xml")
    Parts["_rels/.rels"] = docx._bytes(Relationships)
    Types = docx._xml(Source["[Content_Types].xml"])
    for x in list(Types):
        if etree.QName(x).localname == "Override" and x.get("PartName").lstrip("/") not in Parts:
            Types.remove(x)
    Parts["[Content_Types].xml"] = docx._bytes(Types)
    docx.writePackage(Parts, outputPath=outputPath, inputPaths=[sourcePath])
    return {"sourceSha256": docx.DIGEST, "referenceSha256": sha256(Path(outputPath).read_bytes()).hexdigest(),
            "aliases": ALIASES, "tableText": "SRKTableText"}


if __name__ == "__main__":
    Parser = argparse.ArgumentParser(description=__doc__)
    Parser.add_argument("--source", required=True, type=Path)
    Parser.add_argument("--output", required=True, type=Path)
    ARGS = Parser.parse_args()
    print(json.dumps(buildReference(sourcePath=ARGS.source, outputPath=ARGS.output)))
