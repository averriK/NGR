"""Private CAN resource preparation and validated NGR DOCX composition."""

import argparse
from copy import deepcopy
from hashlib import sha256
import json
import os
from pathlib import Path
import posixpath
import tempfile
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

try:
    from lxml import etree
except ImportError as e:
    raise SystemExit("CAN DOCX rendering requires lxml in this Python interpreter. Install it with python3 -m pip install lxml (python on Windows).") from e


W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
R = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
REL = "http://schemas.openxmlformats.org/package/2006/relationships"
CT = "http://schemas.openxmlformats.org/package/2006/content-types"
NS = {"w": W, "r": R, "m": "http://schemas.openxmlformats.org/officeDocument/2006/math"}
DIGEST = "7ec329ffa48eea32f473cd9efcf1b39c054bdc43b7f1e8de4d1c0884e83d7605"
FORMAT = "ngr-srk-can-components-2"
MARKER = "word/srk-composition.json"
SLOTS = {"title": "reporttitle", "client": "clientname", "issue": "projectnumber",
         "date": "monthyear", "company": "company"}
TITLEFIELDS = {"clientAddress", "companyAddress", "clientWeb", "companyWeb", "fileName"}
PORDER = {s: i for i, s in enumerate(("pStyle", "keepNext", "keepLines", "pageBreakBefore", "framePr", "widowControl", "numPr", "suppressLineNumbers", "pBdr", "shd", "tabs", "suppressAutoHyphens", "kinsoku", "wordWrap", "overflowPunct", "topLinePunct", "autoSpaceDE", "autoSpaceDN", "bidi", "adjustRightInd", "snapToGrid", "spacing", "ind", "contextualSpacing", "mirrorIndents", "suppressOverlap", "jc", "textDirection", "textAlignment", "textboxTightWrap", "outlineLvl", "divId", "cnfStyle", "rPr", "sectPr", "pPrChange"))}


def _xml(data):
    return etree.fromstring(data, parser=etree.XMLParser(resolve_entities=False, no_network=True))


def _bytes(element):
    return etree.tostring(element, encoding="UTF-8", xml_declaration=True, standalone=True)


def _one(elements, label):
    if len(elements) != 1:
        raise ValueError(f"{label}: expected one element, found {len(elements)}")
    return elements[0]


def readPackage(path):
    with ZipFile(path) as FILE:
        if len(FILE.namelist()) != len(set(FILE.namelist())) or FILE.testzip() is not None:
            raise ValueError("Duplicate ZIP member or CRC failure")
        return {s: FILE.read(s) for s in FILE.namelist()}


def writePackage(parts, outputPath, inputPaths):
    Target = Path(outputPath).resolve()
    if Target in {Path(x).resolve() for x in inputPaths}:
        raise ValueError("Output cannot overwrite an input")
    with tempfile.NamedTemporaryFile(dir=Target.parent, prefix=".srk-", suffix=".zip", delete=False) as FILE:
        Temporary = Path(FILE.name)
    try:
        with ZipFile(Temporary, "w") as FILE:
            for s in sorted(parts):
                x = ZipInfo(s, date_time=(1980, 1, 1, 0, 0, 0))
                x.compress_type = ZIP_DEFLATED
                FILE.writestr(x, parts[s])
        readPackage(Temporary)
        os.replace(Temporary, Target)
    finally:
        Temporary.unlink(missing_ok=True)


def _replaceText(paragraph, text):
    Properties = paragraph.find("w:pPr", NS)
    Run = paragraph.find(".//w:r", NS)
    Run = Run.find("w:rPr", NS) if Run is not None else None
    for x in list(paragraph):
        if x is not Properties:
            paragraph.remove(x)
    if text:
        x = etree.SubElement(paragraph, f"{{{W}}}r")
        if Run is not None:
            x.append(deepcopy(Run))
        etree.SubElement(x, f"{{{W}}}t", {"{http://www.w3.org/XML/1998/namespace}space": "preserve"}).text = text


def _clearParagraphIds(element):
    for x in element.iter():
        for s in ("paraId", "textId"):
            x.attrib.pop("{http://schemas.microsoft.com/office/word/2010/wordml}" + s, None)


def prepareTemplate(sourcePath, outputPath):
    if sha256(Path(sourcePath).read_bytes()).hexdigest() != DIGEST:
        raise ValueError("SRK template hash differs from the audited source")
    Source = readPackage(sourcePath)
    Body = _xml(Source["word/document.xml"]).find("w:body", NS)
    Table = _one(Body.xpath("./w:tbl[.//w:sdtPr/w:tag/@w:val='clientlogo']", namespaces=NS), "NA cover table")
    Anchors = list(Table.itersiblings(preceding=True))
    if len(Anchors) != 2 or any(x.tag != f"{{{W}}}p" or x.xpath(".//w:t", namespaces=NS) for x in Anchors):
        raise ValueError("Unsupported NA cover anchors")
    Cover = etree.Element(f"{{{W}}}body", nsmap=Body.nsmap)
    Cover.extend(deepcopy(x) for x in [*reversed(Anchors), Table])
    TitlePage = etree.Element(f"{{{W}}}body", nsmap=Body.nsmap)
    TitlePage.append(deepcopy(_one(Body.xpath("./w:tbl[.//w:pStyle/@w:val='Cover2']", namespaces=NS), "CAN title page")))
    for x in list(TitlePage.findall(".//w:sdt", NS)):
        Parent = x.getparent()
        i = Parent.index(x)
        for v in list(x.find("w:sdtContent", NS)):
            Parent.insert(i, v)
            i += 1
        Parent.remove(x)
    Rows = TitlePage.find("w:tbl", NS).findall("w:tr", NS)
    if len(Rows) != 7 or [len(x.findall("w:tc", NS)) for x in Rows] != [2, 2, 3, 3, 3, 2, 2]:
        raise ValueError("Unsupported CAN title page grid")
    for s, t in (("title", "Cover2"), ("date", "Cover4")):
        _replaceText(_one(TitlePage.xpath(".//w:p[w:pPr/w:pStyle/@w:val=$style]", namespaces=NS, style=t), t), "{{" + s + "}}")
    for i, (s, t) in enumerate((("client", "Canada Nickel Co."), ("company", "SRK Consulting (Canada) Inc.")), start=1):
        Cell = Rows[3].findall("w:tc", NS)[i]
        LIST = Cell.findall("w:p", NS)
        x = _one(Cell.xpath("./w:p[.//w:t=$name]", namespaces=NS, name=t), "title page organization " + s)
        n = LIST.index(x)
        _replaceText(x, "{{" + s + "}}")
        _replaceText(LIST[n + 1], "{{" + s + "Address}}")
        for x in LIST[n + 2:]:
            Cell.remove(x)
        LIST = Rows[4].findall("w:tc", NS)[i].findall("w:p", NS)
        _replaceText(LIST[0], "")
        _replaceText(LIST[1], "{{" + s + "Web}}")
    LIST = Rows[5].findall("w:tc", NS)[1].findall("w:p", NS)
    _replaceText(LIST[0], "{{issue}}")
    _replaceText(LIST[2], "{{fileName}}")
    _replaceText(Rows[6].findall("w:tc", NS)[1].find("w:p", NS), "")
    for s, t in SLOTS.items():
        if s == "company":
            x = _one(Cover.xpath(".//w:p[w:r/w:t='SRK Consulting (Canada) Inc.']", namespaces=NS), "source company")
        else:
            v = _one(Cover.xpath(".//w:sdt[w:sdtPr/w:tag/@w:val=$tag]", namespaces=NS, tag=t), t)
            x = v.getparent() if v.getparent().tag == f"{{{W}}}p" else _one(v.findall("w:sdtContent/w:p", NS), t + " paragraph")
        _replaceText(x, "{{" + s + "}}")
    x = _one(Cover.xpath(".//w:sdt[w:sdtPr/w:tag/@w:val='clientlogo']", namespaces=NS), "client logo placeholder")
    if x.find("w:sdtPr/w:showingPlcHdr", NS) is None:
        raise ValueError("Client logo is no longer an empty placeholder")
    # Retain the source slot height without displaying Word's placeholder image.
    v = etree.Element(f"{{{W}}}p")
    t = etree.SubElement(v, f"{{{W}}}pPr")
    n = int(x.xpath(".//*[local-name()='extent']/@cy")[0])
    etree.SubElement(t, f"{{{W}}}spacing", {f"{{{W}}}line": str(round(n / 635)), f"{{{W}}}lineRule": "exact", f"{{{W}}}after": "0"})
    x.getparent().replace(x, v)
    for x in Cover.xpath(".//w:p[string(.)='``']", namespaces=NS):
        _replaceText(x, "")
    # All remaining controls are known plain metadata slots; detach source bindings.
    for x in list(Cover.findall(".//w:sdt", NS)):
        Parent = x.getparent()
        i = Parent.index(x)
        for v in list(x.find("w:sdtContent", NS)):
            Parent.insert(i, v)
            i += 1
        Parent.remove(x)
    for x in Cover.findall(".//w:p", NS) + TitlePage.findall(".//w:p", NS):
        v = x.find("w:pPr", NS)
        if v is None:
            v = etree.Element(f"{{{W}}}pPr")
            x.insert(0, v)
        if v.find("w:pStyle", NS) is None:
            v.insert(0, etree.Element(f"{{{W}}}pStyle", {f"{{{W}}}val": "Normal"}))
        Spacing = v.find("w:spacing", NS)
        if Spacing is None:
            Spacing = etree.SubElement(v, f"{{{W}}}spacing")
        # NA's table uses single spacing; missing values must not inherit NGR's 9 pt before.
        for s, t in {"before": "0", "after": "0", "line": "240", "lineRule": "auto"}.items():
            if Spacing.get(f"{{{W}}}{s}") is None:
                Spacing.set(f"{{{W}}}{s}", t)
    Heading = deepcopy(Body.xpath("./w:p[w:pPr/w:pStyle/@w:val='Heading8']", namespaces=NS)[0])
    _replaceText(Heading, "{{appendixTitle}}")
    SectionAppendix = _one(Body.xpath("./w:p[w:pPr/w:pStyle/@w:val='Heading8']/w:pPr/w:sectPr[w:vAlign/@w:val='center']", namespaces=NS), "centered NA appendix section")
    SectionCover = Body.find(".//w:sectPr", NS)
    Relationships = _xml(Source["word/_rels/document.xml.rels"])
    ImageId = _one(list(set(Cover.xpath(".//@r:embed", namespaces=NS) + TitlePage.xpath(".//@r:embed", namespaces=NS))), "SRK logo")
    x = _one([v for v in Relationships if v.get("Id") == ImageId], "SRK logo relationship")
    if x.get("Type") != R + "/image" or x.get("TargetMode") == "External":
        raise ValueError("Unsupported SRK logo relationship")
    ImagePath = posixpath.normpath(posixpath.join("word", x.get("Target")))
    Footer = etree.Element(f"{{{W}}}ftr", nsmap={"w": W})
    etree.SubElement(Footer, f"{{{W}}}p")
    for x in Cover.xpath(".//*[@descr]", namespaces=NS) + TitlePage.xpath(".//*[@descr]", namespaces=NS):
        x.set("descr", "SRK Consulting logo")
    Parts = {"cover.xml": _bytes(Cover), "cover-section.xml": _bytes(SectionCover),
             "title-page.xml": _bytes(TitlePage),
             "cover-footer.xml": _bytes(Footer), "appendix-heading.xml": _bytes(Heading),
             "appendix-section.xml": _bytes(SectionAppendix),
             "styles.xml": Source["word/styles.xml"], "numbering.xml": Source["word/numbering.xml"],
             "logo.wmf": Source[ImagePath]}
    Manifest = {"format": FORMAT, "sourceSha256": DIGEST, "slots": SLOTS,
                "parts": {s: sha256(v).hexdigest() for s, v in Parts.items()}}
    Parts["manifest.json"] = (json.dumps(Manifest, ensure_ascii=False, indent=2) + "\n").encode()
    writePackage(Parts, outputPath=outputPath, inputPaths=[sourcePath])
    return Manifest


def _readTemplate(path):
    Parts = readPackage(path)
    Manifest = json.loads(Parts["manifest.json"])
    if Manifest.get("format") != FORMAT or Manifest.get("sourceSha256") != DIGEST or Manifest.get("slots") != SLOTS:
        raise ValueError("Unsupported SRK component manifest")
    if set(Parts) != set(Manifest["parts"]) | {"manifest.json"}:
        raise ValueError("Component inventory differs from manifest")
    for s, v in Manifest["parts"].items():
        if sha256(Parts[s]).hexdigest() != v:
            raise ValueError(f"Component digest mismatch: {s}")
    return Parts


def normalizeParagraphs(document):
    Counts = {"captionProperties": 0, "alignmentProperties": 0, "cellEndings": 0}
    for x in document.findall(".//w:tc", NS):
        Content = [v for v in x if v.tag in {f"{{{W}}}p", f"{{{W}}}tbl"}]
        if Content and Content[-1].tag == f"{{{W}}}tbl":
            etree.SubElement(x, f"{{{W}}}p")
            Counts["cellEndings"] += 1
    for x in document.findall(".//w:p", NS):
        LIST = x.findall("w:pPr", NS)
        if not LIST:
            continue
        if len(LIST) > 1:
            if len(LIST) != 2 or [etree.QName(v).localname for v in LIST[0]] != ["jc"] or LIST[1].find("w:pStyle", NS) is None or LIST[1].find("w:pStyle", NS).get(f"{{{W}}}val") != "ImageCaption":
                raise ValueError("Unknown duplicate paragraph properties")
            Counts["captionProperties"] += 1
        Alignments = x.findall("w:pPr/w:jc", NS)
        Alignment = None
        if len(Alignments) > 1:
            if len(Alignments) != 2:
                raise ValueError("Unknown conflicting paragraph alignment")
            if dict(Alignments[0].attrib) == dict(Alignments[1].attrib):
                Alignment = Alignments[0]
            elif len(LIST) == 2 and Alignments[0].get(f"{{{W}}}val") == "center":
                Alignment = Alignments[1]
            elif (len(LIST) == 1 and LIST[0].xpath("./w:pStyle[@w:val='Compact']", namespaces=NS)
                  and x.xpath("ancestor::w:tbl[1]/w:tblPr/w:tblStyle[@w:val='SRKDataTable']", namespaces=NS)
                  and Alignments[1].get(f"{{{W}}}val") == "center"):
                # Pandoc's cell alignment precedes Quarto's wrapper alignment.
                Alignment = Alignments[0]
            else:
                raise ValueError("Unknown conflicting paragraph alignment")
            Counts["alignmentProperties"] += 1
        Properties = {}
        for v in [v for p in LIST for v in p]:
            s = etree.QName(v).localname
            if s not in PORDER or etree.QName(v).namespace != W:
                raise ValueError(f"Unsupported paragraph property: {v.tag}")
            if s == "jc" and Alignment is not None and v is not Alignment:
                continue
            if v.tag in Properties:
                raise ValueError(f"Unknown conflicting paragraph property: {s}")
            Properties[v.tag] = v
        for v in LIST:
            x.remove(v)
        v = etree.Element(f"{{{W}}}pPr", LIST[0].attrib)
        v[:] = sorted(Properties.values(), key=lambda p: PORDER[etree.QName(p).localname])
        x.insert(0, v)
    return Counts


def _unwrapTables(document):
    # Quarto's one-cell caption wrapper prevents repeated table headers in
    # LibreOffice. Hoist the intact content; the terminal paragraph also gives
    # tables the empty Normal paragraph used in CAN before subsequent text.
    n = 0
    for Table in document.xpath("./w:body/w:tbl[w:tblPr/w:tblStyle/@w:val='Table']", namespaces=NS):
        if Table.attrib or [x.tag for x in Table] != [f"{{{W}}}{s}" for s in ("tblPr", "tblGrid", "tr")]:
            continue
        Row = Table.find("w:tr", NS)
        Grid = Table.find("w:tblGrid", NS)
        if Row.attrib or [x.tag for x in Row] != [f"{{{W}}}tc"] or Grid.attrib or len(Grid) != 1:
            continue
        # Quarto/Pandoc's fixed single-column wrapper grid. A changed grid or
        # additional cell/row formatting belongs to the author and stays intact.
        if Grid[0].tag != f"{{{W}}}gridCol" or dict(Grid[0].attrib) != {f"{{{W}}}w": "7920"}:
            continue
        Cell = Table.find("w:tr/w:tc", NS)
        if Cell.attrib or len(Cell.findall("w:tcPr", NS)) != 1:
            continue
        Properties = Cell.find("w:tcPr", NS)
        if Properties.attrib or len(Properties):
            continue
        Content = [x for x in Cell if x.tag != f"{{{W}}}tcPr"]
        if (len(Cell.findall("w:tbl", NS)) != 1
                or len(Cell.xpath("./w:p[w:pPr/w:pStyle/@w:val='ImageCaption']", namespaces=NS)) != 1
                or any(x.tag not in {f"{{{W}}}{s}" for s in ("p", "tbl", "bookmarkStart", "bookmarkEnd")} for x in Content)
                or any(x.xpath(".//w:t | .//w:drawing | .//m:oMath", namespaces=NS) for x in Cell.xpath("./w:p[not(w:pPr/w:pStyle/@w:val='ImageCaption')]", namespaces=NS))):
            continue
        Properties = Table.find("w:tblPr", NS)
        Expected = [("tblStyle", {"val": "Table"}), ("tblW", {"type": "pct", "w": "5000"}),
                    ("tblLayout", {"type": "fixed"}), ("tblLook", {"firstRow": "0", "lastRow": "0", "firstColumn": "0", "lastColumn": "0", "noHBand": "0", "noVBand": "0", "val": "0000"})]
        if Properties.attrib or len(Properties) != len(Expected) or any(
                x.tag != f"{{{W}}}{s}" or dict(x.attrib) != {f"{{{W}}}{k}": v for k, v in Values.items()} or len(x)
                for x, (s, Values) in zip(Properties, Expected)):
            continue
        Body = Table.getparent()
        i = Body.index(Table)
        if not Content or Content[-1].tag != f"{{{W}}}p":
            Content.append(etree.Element(f"{{{W}}}p"))
        for x in Content:
            Body.insert(i, x)
            i += 1
        Body.remove(Table)
        n += 1
    return n


def _importStyles(styles, numbering, stylesSource, numberingSource, required):
    Styles = {x.get(f"{{{W}}}styleId"): x for x in stylesSource.findall("w:style", NS)}
    Nums = {x.get(f"{{{W}}}numId"): x for x in numberingSource.findall("w:num", NS)}
    Abstracts = {x.get(f"{{{W}}}abstractNumId"): x for x in numberingSource.findall("w:abstractNum", NS)}
    StyleIds, NumIds, AbstractIds = set(required), set(), set()
    while True:
        n = len(StyleIds) + len(NumIds) + len(AbstractIds)
        for s in list(StyleIds):
            if s not in Styles:
                raise ValueError(f"Missing source style: {s}")
            StyleIds.update(Styles[s].xpath("./w:basedOn/@w:val | ./w:next/@w:val | ./w:link/@w:val", namespaces=NS))
            NumIds.update(Styles[s].xpath(".//w:numId[not(@w:val='0')]/@w:val", namespaces=NS))
        for s in list(NumIds):
            AbstractIds.add(Nums[s].find("w:abstractNumId", NS).get(f"{{{W}}}val"))
            StyleIds.update(Nums[s].xpath(".//w:pStyle/@w:val", namespaces=NS))
        for s in list(AbstractIds):
            StyleIds.update(Abstracts[s].xpath(".//w:pStyle/@w:val | .//w:styleLink/@w:val | .//w:numStyleLink/@w:val", namespaces=NS))
        if n == len(StyleIds) + len(NumIds) + len(AbstractIds):
            break
    Existing = set(styles.xpath("./w:style/@w:styleId", namespaces=NS))
    Names = set(styles.xpath("./w:style/w:name/@w:val", namespaces=NS))
    Prefix = "SRK"
    n = 0
    while any(Prefix + s in Existing or Prefix + " " + Styles[s].find("w:name", NS).get(f"{{{W}}}val").lstrip("±") in Names for s in StyleIds):
        n += 1
        Prefix = "SRK" + str(n)
    StyleMap = {s: Prefix + s for s in sorted(StyleIds)}
    n = max([int(x.get(f"{{{W}}}numId")) for x in numbering.findall("w:num", NS)] + [0]) + 1
    NumMap = {s: str(n + i) for i, s in enumerate(sorted(NumIds, key=int))}
    n = max([int(x.get(f"{{{W}}}abstractNumId")) for x in numbering.findall("w:abstractNum", NS)] + [-1]) + 1
    AbstractMap = {s: str(n + i) for i, s in enumerate(sorted(AbstractIds, key=int))}
    for s in sorted(StyleIds):
        x = deepcopy(Styles[s])
        x.set(f"{{{W}}}styleId", StyleMap[s])
        x.attrib.pop(f"{{{W}}}default", None)
        x.find("w:name", NS).set(f"{{{W}}}val", Prefix + " " + Styles[s].find("w:name", NS).get(f"{{{W}}}val").lstrip("±"))
        for v in x.findall("w:aliases", NS):
            x.remove(v)
        if x.find("w:basedOn", NS) is None and x.get(f"{{{W}}}type") == "paragraph":
            for t in ("pPr", "rPr"):
                Defaults = stylesSource.find(f"w:docDefaults/w:{t}Default/w:{t}", NS)
                v = x.find(f"w:{t}", NS)
                if v is None:
                    v = etree.SubElement(x, f"{{{W}}}{t}")
                if Defaults is not None:
                    for y in Defaults:
                        z = v.find(y.tag)
                        if z is None:
                            v.append(deepcopy(y))
                if t == "pPr":
                    Spacing = v.find("w:spacing", NS)
                    if Spacing is None:
                        Spacing = etree.SubElement(v, f"{{{W}}}spacing")
                    if Spacing.get(f"{{{W}}}before") is None:
                        Spacing.set(f"{{{W}}}before", "0")
                if t == "rPr":
                    # Explicit font names in NA styles take precedence over destination theme fonts.
                    for y in v.findall("w:rFonts", NS):
                        for k, a in (("ascii", "asciiTheme"), ("hAnsi", "hAnsiTheme"), ("eastAsia", "eastAsiaTheme"), ("cs", "cstheme")):
                            if y.get(f"{{{W}}}{k}") is not None:
                                y.attrib.pop(f"{{{W}}}{a}", None)
        for v in x.iter():
            if etree.QName(v).localname in ("basedOn", "next", "link"):
                v.set(f"{{{W}}}val", StyleMap[v.get(f"{{{W}}}val")])
            elif v.tag == f"{{{W}}}numId" and v.get(f"{{{W}}}val") != "0":
                v.set(f"{{{W}}}val", NumMap[v.get(f"{{{W}}}val")])
        styles.append(x)
    for s in sorted(AbstractIds, key=int):
        x = deepcopy(Abstracts[s])
        x.set(f"{{{W}}}abstractNumId", AbstractMap[s])
        for v in x.iter():
            if etree.QName(v).localname in ("pStyle", "styleLink", "numStyleLink"):
                v.set(f"{{{W}}}val", StyleMap[v.get(f"{{{W}}}val")])
            elif v.tag == f"{{{W}}}nsid":
                v.set(f"{{{W}}}val", sha256((DIGEST + Prefix + s).encode()).hexdigest()[:8].upper())
        n = next((i for i, v in enumerate(numbering) if v.tag == f"{{{W}}}num"), len(numbering))
        numbering.insert(n, x)
    for s in sorted(NumIds, key=int):
        x = deepcopy(Nums[s])
        x.set(f"{{{W}}}numId", NumMap[s])
        x.find("w:abstractNumId", NS).set(f"{{{W}}}val", AbstractMap[Nums[s].find("w:abstractNumId", NS).get(f"{{{W}}}val")])
        for v in x.findall(".//w:pStyle", NS):
            v.set(f"{{{W}}}val", StyleMap[v.get(f"{{{W}}}val")])
        numbering.append(x)
    return {"styles": StyleMap, "nums": NumMap, "abstracts": AbstractMap}


def _addPart(parts, relationships, types, name, content, kind):
    if name in parts:
        raise ValueError(f"Part collision: {name}")
    n = 1
    while f"rId{n}" in {x.get("Id") for x in relationships}:
        n += 1
    s = f"rId{n}"
    parts[name] = content
    etree.SubElement(relationships, f"{{{REL}}}Relationship", Id=s, Type=R + "/" + kind, Target=posixpath.relpath(name, "word"))
    etree.SubElement(types, f"{{{CT}}}Override", PartName="/" + name, ContentType="image/x-wmf" if kind == "image" else "application/vnd.openxmlformats-officedocument.wordprocessingml." + kind + "+xml")
    return s


def _section(source, references, start, numberFormat="decimal"):
    Section = deepcopy(source)
    for x in list(Section):
        if etree.QName(x).localname in {"headerReference", "footerReference", "titlePg", "type", "pgNumType"}:
            Section.remove(x)
    for x in reversed(references):
        Section.insert(0, deepcopy(x))
    Section.insert(len(references), etree.Element(f"{{{W}}}type", {f"{{{W}}}val": "nextPage"}))
    if start is not None:
        x = Section.find("w:cols", NS)
        Section.insert(Section.index(x) if x is not None else len(Section), etree.Element(f"{{{W}}}pgNumType", {f"{{{W}}}fmt": numberFormat, f"{{{W}}}start": str(start)}))
    elif numberFormat != "decimal":
        x = Section.find("w:cols", NS)
        Section.insert(Section.index(x) if x is not None else len(Section), etree.Element(f"{{{W}}}pgNumType", {f"{{{W}}}fmt": numberFormat}))
    return Section


def _sectionParagraph(section):
    Paragraph = etree.Element(f"{{{W}}}p")
    x = etree.SubElement(Paragraph, f"{{{W}}}pPr")
    etree.SubElement(x, f"{{{W}}}spacing", {f"{{{W}}}before": "0", f"{{{W}}}after": "0", f"{{{W}}}line": "20", f"{{{W}}}lineRule": "exact"})
    x.append(deepcopy(section))
    return Paragraph


def _appendixTable(heading, section):
    Size = section.find("w:pgSz", NS)
    Margins = section.find("w:pgMar", NS)
    Width = int(Size.get(f"{{{W}}}w")) - sum(int(Margins.get(f"{{{W}}}{s}")) for s in ("left", "right"))
    Height = int(Size.get(f"{{{W}}}h")) - sum(int(Margins.get(f"{{{W}}}{s}")) for s in ("top", "bottom")) - 40
    Table = etree.Element(f"{{{W}}}tbl")
    Properties = etree.SubElement(Table, f"{{{W}}}tblPr")
    etree.SubElement(Properties, f"{{{W}}}tblW", {f"{{{W}}}w": str(Width), f"{{{W}}}type": "dxa"})
    Borders = etree.SubElement(Properties, f"{{{W}}}tblBorders")
    for s in ("top", "left", "bottom", "right", "insideH", "insideV"):
        etree.SubElement(Borders, f"{{{W}}}{s}", {f"{{{W}}}val": "nil"})
    etree.SubElement(Properties, f"{{{W}}}tblLayout", {f"{{{W}}}type": "fixed"})
    Margins = etree.SubElement(Properties, f"{{{W}}}tblCellMar")
    for s in ("top", "left", "bottom", "right"):
        etree.SubElement(Margins, f"{{{W}}}{s}", {f"{{{W}}}w": "0", f"{{{W}}}type": "dxa"})
    etree.SubElement(etree.SubElement(Table, f"{{{W}}}tblGrid"), f"{{{W}}}gridCol", {f"{{{W}}}w": str(Width)})
    Row = etree.SubElement(Table, f"{{{W}}}tr")
    Properties = etree.SubElement(Row, f"{{{W}}}trPr")
    etree.SubElement(Properties, f"{{{W}}}cantSplit")
    etree.SubElement(Properties, f"{{{W}}}trHeight", {f"{{{W}}}val": str(Height), f"{{{W}}}hRule": "atLeast"})
    Cell = etree.SubElement(Row, f"{{{W}}}tc")
    Properties = etree.SubElement(Cell, f"{{{W}}}tcPr")
    etree.SubElement(Properties, f"{{{W}}}tcW", {f"{{{W}}}w": str(Width), f"{{{W}}}type": "dxa"})
    etree.SubElement(Properties, f"{{{W}}}vAlign", {f"{{{W}}}val": "center"})
    Cell.append(heading)
    return Table


def _readSpec(path):
    Spec = json.loads(Path(path).read_text(encoding="utf-8"))
    if set(Spec) != {"cover", "titlePage", "headerFooter", "appendices", "lang"} or set(Spec["cover"]) != set(SLOTS) or set(Spec["titlePage"]) != TITLEFIELDS or set(Spec["headerFooter"]) != {"title", "date", "project", "company"}:
        raise ValueError("Spec requires explicit cover, titlePage, headerFooter, appendices and lang fields")
    if Spec["lang"] not in ("en", "es"):
        raise ValueError("Spec lang must be en or es")
    for x in list(Spec["cover"].values()) + list(Spec["headerFooter"].values()):
        if not isinstance(x, str) or not x.strip() or any(ord(v) < 32 for v in x):
            raise ValueError("Metadata must be non-empty single-line strings")
    for s, x in Spec["titlePage"].items():
        LIST = x if s.endswith("Address") else [x]
        if not isinstance(LIST, list) or any(not isinstance(v, str) or any(ord(t) < 32 for t in v) for v in LIST):
            raise ValueError("titlePage requires address lists and single-line strings")
    if not isinstance(Spec["appendices"], list):
        raise ValueError("appendices must be an ordered list")
    for x in Spec["appendices"]:
        if not isinstance(x, dict) or set(x) != {"bookmark"} or not isinstance(x["bookmark"], str) or not x["bookmark"]:
            raise ValueError("Each appendix requires its heading bookmark")
    if len({x["bookmark"] for x in Spec["appendices"]}) != len(Spec["appendices"]):
        raise ValueError("Duplicate appendix bookmark in spec")
    return Spec


def _hydrateHeaderFooter(element, values):
    Fields = set()
    for s in values:
        for x in element.findall(".//w:sdt", NS):
            if not x.xpath("./w:sdtPr/w:tag[@w:val=$tag]", namespaces=NS, tag="srk." + s):
                continue
            LIST = x.findall("w:sdtContent/w:r/w:t", NS)
            if not LIST:
                raise ValueError(f"Unsupported metadata control: {s}")
            LIST[0].text = values[s]
            for v in LIST[1:]:
                v.text = ""
            for v in x.findall("w:sdtPr/w:showingPlcHdr", NS) + x.findall("w:sdtPr/w:dataBinding", NS):
                v.getparent().remove(v)
            Fields.add(s)
    return Fields


def checkReference(path):
    Parts = readPackage(path)
    Styles = _xml(Parts["word/styles.xml"])
    Index = {x.get(f"{{{W}}}styleId"): x for x in Styles.findall("w:style", NS)}
    Required = {"BodyText", "FirstParagraph", "Heading1", "Heading2", "Heading3", "Heading4", "Caption", "ImageCaption", "TableCaption", "SRKTableText", "SRKDataTable", "Equation", "TableHeading", "FootnoteText", "Bibliography"}
    Fields = set()
    for s in Parts:
        if s.startswith(("word/header", "word/footer")) and s.endswith(".xml"):
            Fields.update(_xml(Parts[s]).xpath(".//w:sdtPr/w:tag/@w:val", namespaces=NS))
    if not Required <= set(Index) or Index.get("Table") is None or Index["Table"].get(f"{{{W}}}type") != "table" or not {"srk.title", "srk.company", "srk.project", "srk.date"} <= Fields:
        raise ValueError("DOCX reference is not CAN-compatible. Review and migrate styles/reference.docx and the DOCX profile with ngr status/pull before rendering; render never replaces project styles.")


def validatePackage(parts, contentParts):
    Trees = {s: _xml(v) for s, v in parts.items() if s.endswith((".xml", ".rels"))}
    Styles = Trees["word/styles.xml"]
    Numbering = Trees["word/numbering.xml"]
    StyleIds = Styles.xpath("./w:style/@w:styleId", namespaces=NS)
    NumIds = Numbering.xpath("./w:num/@w:numId", namespaces=NS)
    AbstractIds = Numbering.xpath("./w:abstractNum/@w:abstractNumId", namespaces=NS)
    if any(len(x) != len(set(x)) for x in (StyleIds, NumIds, AbstractIds)):
        raise ValueError("Duplicate style or numbering identity")
    Bases = {x.get(f"{{{W}}}styleId"): x.find("w:basedOn", NS).get(f"{{{W}}}val") for x in Styles if x.find("w:basedOn", NS) is not None}
    for s in Bases:
        Seen = set()
        while s in Bases:
            if s in Seen:
                raise ValueError(f"Cyclic style inheritance: {s}")
            Seen.add(s)
            s = Bases[s]
    if not set(Numbering.xpath("./w:num/w:abstractNumId/@w:val", namespaces=NS)) <= set(AbstractIds):
        raise ValueError("Missing abstract numbering definition")
    for s, x in Trees.items():
        if s.endswith(".rels"):
            LIST = x.findall(f"{{{REL}}}Relationship")
            if len({v.get("Id") for v in LIST}) != len(LIST):
                raise ValueError(f"Duplicate relationship ID: {s}")
            for v in LIST:
                if v.get("TargetMode") != "External":
                    t = posixpath.normpath(posixpath.join(posixpath.dirname(posixpath.dirname(s)), v.get("Target"))).lstrip("/")
                    if t not in parts:
                        raise ValueError(f"Missing relationship target: {s} -> {t}")
        if s.startswith("word/") and s.endswith(".xml"):
            t = posixpath.join(posixpath.dirname(s), "_rels", posixpath.basename(s) + ".rels")
            Ids = {v.get("Id") for v in Trees[t]} if t in Trees else set()
            if not set(x.xpath(".//@r:id | .//@r:embed | .//@r:link", namespaces=NS)) <= Ids:
                raise ValueError(f"Unresolved relationship use: {s}")
            if not set(x.xpath(".//w:pStyle/@w:val | .//w:rStyle/@w:val | .//w:tblStyle/@w:val | .//w:basedOn/@w:val | .//w:next/@w:val | .//w:link/@w:val", namespaces=NS)) <= set(StyleIds):
                raise ValueError(f"Undefined style: {s}")
            if not set(x.xpath(".//w:numPr/w:numId/@w:val", namespaces=NS)) <= set(NumIds) | {"0"}:
                raise ValueError(f"Undefined numbering: {s}")
    Document = Trees["word/document.xml"]
    Ids = Document.xpath(".//@w14:paraId", namespaces={"w14": "http://schemas.microsoft.com/office/word/2010/wordml"})
    if len(Ids) != len(set(Ids)):
        raise ValueError("Duplicate paragraph identity in document")
    Names = Document.xpath(".//w:bookmarkStart/@w:name", namespaces=NS)
    if len(Names) != len(set(Names)) or not set(Document.xpath(".//w:hyperlink/@w:anchor", namespaces=NS)) <= set(Names):
        raise ValueError("Duplicate bookmark or broken internal link")
    Starts = Document.xpath(".//w:bookmarkStart/@w:id", namespaces=NS)
    Ends = Document.xpath(".//w:bookmarkEnd/@w:id", namespaces=NS)
    if len(Starts) != len(set(Starts)) or len(Ends) != len(set(Ends)) or set(Starts) != set(Ends):
        raise ValueError("Unpaired or duplicate bookmark identity")
    Seen = set()
    for x in Document.iter():
        if x.tag == f"{{{W}}}bookmarkStart":
            Seen.add(x.get(f"{{{W}}}id"))
        elif x.tag == f"{{{W}}}bookmarkEnd" and x.get(f"{{{W}}}id") not in Seen:
            raise ValueError("Bookmark end precedes its start")
    Relationships = Trees["word/_rels/document.xml.rels"]
    for s in ("footnote", "endnote"):
        References = Document.xpath(f".//w:{s}Reference/@w:id", namespaces=NS)
        if not References:
            continue
        v = _one([x.get("Target") for x in Relationships if x.get("Type") == R + "/" + s + "s"], s + " relationship")
        Definitions = Trees[posixpath.normpath(posixpath.join("word", v))]
        Ids = Definitions.xpath(f"./w:{s}/@w:id", namespaces=NS)
        Normal = Definitions.xpath(f"./w:{s}[not(@w:type) or @w:type='normal']/@w:id", namespaces=NS)
        if len(Ids) != len(set(Ids)) or not set(References) <= set(Normal):
            raise ValueError(f"Missing or duplicate {s} definition")
    Before = _xml(contentParts["word/document.xml"])
    _unwrapTables(Before)
    Body = deepcopy(Document.find("w:body", NS))
    Manifest = json.loads(parts[MARKER])
    if Manifest["titleRemoved"]:
        x = Before.find("w:body/w:p", NS)
        x.getparent().remove(x)
    for x in list(Body)[:Manifest["frontMatterElements"]]:
        Body.remove(x)
    for x in Manifest["appendices"]:
        Bookmark = _one(Body.xpath("./w:bookmarkStart[@w:name=$name]", namespaces=NS, name=x["bookmark"]), "output appendix bookmark")
        Table = Bookmark.getnext()
        Heading = _one(Table.findall("w:tr/w:tc/w:p", NS), "appendix cover heading")
        Body.replace(Table, Heading)
    if Before.xpath(".//w:t/text()", namespaces=NS) != Body.xpath(".//w:t/text()", namespaces=NS):
        raise ValueError("Body text or text order changed")
    for s in ("m:oMath", "w:tblPr", "w:tblGrid", "w:tcPr", "w:trPr", "w:hyperlink", "w:drawing", "w:bookmarkStart", "w:bookmarkEnd", "w:footnoteReference", "w:endnoteReference"):
        LIST = [etree.tostring(v, method="c14n", exclusive=True, with_comments=False) for v in Before.findall(".//" + s, NS)]
        AUX = [etree.tostring(v, method="c14n", exclusive=True, with_comments=False) for v in Body.findall(".//" + s, NS)]
        if LIST != AUX:
            raise ValueError(f"Preserved body object changed: {s}")
    if Document.xpath(".//w:instrText[contains(.,'FORMTEXT') or contains(.,'MACROBUTTON')]", namespaces=NS):
        raise ValueError("Legacy placeholder remains in composed document")
    for s in ("word/styles.xml", "word/numbering.xml"):
        for x in _xml(contentParts[s]):
            if not any(etree.tostring(x, method="c14n") == etree.tostring(v, method="c14n") for v in Trees[s]):
                raise ValueError(f"Original definition changed: {s}")
    Mutable = {"word/document.xml", "word/styles.xml", "word/numbering.xml", "word/_rels/document.xml.rels", "word/settings.xml", "word/_rels/settings.xml.rels", "[Content_Types].xml"}
    for s, x in Trees.items():
        if x.tag in (f"{{{W}}}hdr", f"{{{W}}}ftr"):
            Mutable.add(s)
    for s in contentParts:
        if s not in Mutable and parts.get(s) != contentParts[s]:
            raise ValueError(f"Preserve-only part changed: {s}")


def composeDocument(templatePath, contentPath, specPath, outputPath):
    Template = _readTemplate(templatePath)
    Spec = _readSpec(specPath)
    Content = readPackage(contentPath)
    if MARKER in Content:
        raise ValueError("Document is already composed")
    Parts = dict(Content)
    Document = _xml(Parts["word/document.xml"])
    Body = Document.find("w:body", NS)
    if len(Document.findall(".//w:sectPr", NS)) != 1 or Body.find("w:sectPr", NS) is None:
        raise ValueError("CAN composition requires one terminal section; internal sections are unsupported")
    Repairs = normalizeParagraphs(Document)
    Repairs["tableWrappers"] = _unwrapTables(Document)
    # Pandoc emits Compact in every native data-table cell. Flextables and
    # Quarto layout wrappers keep their own paragraph and cell formatting.
    for x in Document.xpath(".//w:tbl[w:tblPr/w:tblStyle/@w:val='SRKDataTable']", namespaces=NS):
        for v in x.findall("w:tr", NS):
            s = "TableHeading" if v.find("w:trPr/w:tblHeader", NS) is not None else "SRKTableText"
            for t in v.xpath("./w:tc/w:p/w:pPr/w:pStyle[@w:val='Compact']", namespaces=NS):
                t.set(f"{{{W}}}val", s)
    TitleRemoved = False
    if len(Body) and Body[0].xpath("./w:pPr/w:pStyle[@w:val='Title']", namespaces=NS):
        if any(x.tag not in {f"{{{W}}}pPr", f"{{{W}}}r"} for x in Body[0]) or any(
                x.tag not in {f"{{{W}}}rPr", f"{{{W}}}t"} for v in Body[0].findall("w:r", NS) for x in v):
            raise ValueError("Rendered title contains an object that cannot be removed")
        # Title is Quarto's generated duplicate. Pandoc smart typography may
        # change its text; the explicit master metadata owns the cover text.
        Body.remove(Body[0])
        TitleRemoved = True
    SectionBody = Body.find("w:sectPr", NS)
    AppendixPoints = []
    for x in Spec["appendices"]:
        v = _one(Body.xpath("./w:bookmarkStart[@w:name=$name]", namespaces=NS, name=x["bookmark"]), "appendix bookmark " + x["bookmark"])
        Heading = v.getnext()
        if Heading is None or Heading.tag != f"{{{W}}}p" or not Heading.xpath("./w:pPr/w:pStyle[@w:val='Heading1']", namespaces=NS):
            raise ValueError("Appendix bookmark must immediately precede a Heading1 paragraph")
        AppendixPoints.append((v, Heading))
    if [Body.index(x[0]) for x in AppendixPoints] != sorted(Body.index(x[0]) for x in AppendixPoints):
        raise ValueError("Appendix order differs from content order")
    Styles = _xml(Parts["word/styles.xml"])
    Numbering = _xml(Parts["word/numbering.xml"])
    Relationships = _xml(Parts["word/_rels/document.xml.rels"])
    Types = _xml(Parts["[Content_Types].xml"])
    Cover = _xml(Template["cover.xml"])
    _clearParagraphIds(Cover)
    TitlePage = _xml(Template["title-page.xml"])
    _clearParagraphIds(TitlePage)
    Footer = _xml(Template["cover-footer.xml"])
    for s, v in Spec["cover"].items():
        x = _one(Cover.xpath(".//w:p[.//w:t=$token]", namespaces=NS, token="{{" + s + "}}"), "prepared cover slot " + s)
        _replaceText(x, v)
    Labels = {"issue": "Project No.:" if Spec["lang"] == "en" else "Proyecto:",
              "fileName": "File Name:" if Spec["lang"] == "en" else "Archivo:",
              "clientWeb": "Web:", "companyWeb": "Web:"}
    for s, v in {**Spec["cover"], **Spec["titlePage"]}.items():
        x = _one(TitlePage.xpath(".//w:p[.//w:t=$token]", namespaces=NS, token="{{" + s + "}}"), "prepared title page slot " + s)
        if s.endswith("Address"):
            Parent = x.getparent()
            for t in v:
                y = deepcopy(x)
                _replaceText(y, t)
                Parent.insert(Parent.index(x), y)
            Parent.remove(x)
        else:
            _replaceText(x, v)
            if s in Labels and v:
                y = x.find("w:r", NS)
                t = etree.Element(f"{{{W}}}t")
                t.text = Labels[s]
                n = 1 if y.find("w:rPr", NS) is not None else 0
                y.insert(n, t)
                y.insert(n + 1, etree.Element(f"{{{W}}}tab"))
    if Spec["lang"] == "es":
        for s, v in (("Prepared for", "Preparado para"), ("Prepared by", "Preparado por")):
            for x in (Cover, TitlePage):
                _one(x.xpath(".//w:t[.=$label]", namespaces=NS, label=s), "preliminary label " + s).text = v
    Required = set(Cover.xpath(".//w:pStyle/@w:val | .//w:rStyle/@w:val | .//w:tblStyle/@w:val", namespaces=NS))
    Required.update(TitlePage.xpath(".//w:pStyle/@w:val | .//w:rStyle/@w:val | .//w:tblStyle/@w:val", namespaces=NS))
    Required.update(Footer.xpath(".//w:pStyle/@w:val | .//w:rStyle/@w:val", namespaces=NS))
    Required.update(("Heading8", "Heading9", "BodyText", "Normal"))
    Mapping = _importStyles(Styles, Numbering, stylesSource=_xml(Template["styles.xml"]), numberingSource=_xml(Template["numbering.xml"]), required=Required)
    for x in (Cover, TitlePage, Footer):
        for v in x.xpath(".//w:pStyle | .//w:rStyle | .//w:tblStyle", namespaces=NS):
            v.set(f"{{{W}}}val", Mapping["styles"][v.get(f"{{{W}}}val")])
    ImageId = _addPart(Parts, Relationships, Types, name="word/media/srk-na-logo.wmf", content=Template["logo.wmf"], kind="image")
    for x in Cover.xpath(".//*[@r:embed]", namespaces=NS) + TitlePage.xpath(".//*[@r:embed]", namespaces=NS):
        x.set(f"{{{R}}}embed", ImageId)
    n = max([int(x) for x in Document.xpath(".//*[local-name()='docPr']/@id")] + [0])
    for i, x in enumerate(Cover.xpath(".//*[local-name()='docPr']") + TitlePage.xpath(".//*[local-name()='docPr']"), start=n + 1):
        x.set("id", str(i))
    References = []
    for s, v in (("header", "hdr"), ("footer", "ftr")):
        x = etree.Element(f"{{{W}}}{v}", nsmap={"w": W})
        etree.SubElement(x, f"{{{W}}}p")
        v = _addPart(Parts, Relationships, Types, name=f"word/srk-empty-{s}.xml", content=_bytes(x), kind=s)
        for t in ("default", "first", "even"):
            References.append(etree.Element(f"{{{W}}}{s}Reference", {f"{{{W}}}type": t, f"{{{R}}}id": v}))
    CoverFooter = _addPart(Parts, Relationships, Types, name="word/srk-cover-footer.xml", content=_bytes(Footer), kind="footer")
    ReferencesCover = deepcopy(References)
    for x in ReferencesCover:
        if x.tag == f"{{{W}}}footerReference":
            x.set(f"{{{R}}}id", CoverFooter)
    ReferencesBody = list(SectionBody.findall("w:headerReference", NS)) + list(SectionBody.findall("w:footerReference", NS))
    for s in ("header", "footer"):
        x = _one([v for v in ReferencesBody if v.tag == f"{{{W}}}{s}Reference" and v.get(f"{{{W}}}type") == "default"], "default body " + s)
        for t in ("first", "even"):
            if not any(v.tag == x.tag and v.get(f"{{{W}}}type") == t for v in ReferencesBody):
                v = deepcopy(x)
                v.set(f"{{{W}}}type", t)
                ReferencesBody.append(v)
    SectionMain = _section(SectionBody, references=ReferencesBody, start=1)
    SectionContent = _section(SectionBody, references=ReferencesBody, start=None)
    # Content before the first top-level heading is Quarto's TOC and the
    # report's signature page. Keep its bookmarks with the heading itself.
    Headings = Body.xpath("./w:p[w:pPr/w:pStyle/@w:val='Heading1']", namespaces=NS)
    Start = Headings[0] if Headings else None
    while Start is not None and Start.getprevious() is not None and Start.getprevious().tag == f"{{{W}}}bookmarkStart":
        Start = Start.getprevious()
    if Start is not None and Body.index(Start) > 0:
        Section = _section(SectionBody, references=ReferencesBody, start=None, numberFormat="lowerRoman")
        x = Start.getprevious()
        if (x.tag == f"{{{W}}}p" and len(x.findall("w:r/w:br", NS)) == 1
                and x.find("w:r/w:br", NS).get(f"{{{W}}}type") == "page"
                and not x.xpath(".//w:t | .//w:drawing | .//w:bookmarkStart | .//w:bookmarkEnd | .//w:footnoteReference | .//m:oMath", namespaces=NS)
                and all(v.tag in {f"{{{W}}}pPr", f"{{{W}}}r"} for v in x)
                and all(v.tag in {f"{{{W}}}rPr", f"{{{W}}}br"} for y in x.findall("w:r", NS) for v in y)):
            x.find("w:r/w:br", NS).getparent().remove(x.find("w:r/w:br", NS))
            Properties = x.find("w:pPr", NS)
            if Properties is None:
                Properties = etree.Element(f"{{{W}}}pPr")
                x.insert(0, Properties)
            Properties.append(Section)
        else:
            Body.insert(Body.index(Start), _sectionParagraph(Section))
    Body.remove(SectionBody)
    CoverChildren = list(Cover)
    FrontMatter = [*CoverChildren, _sectionParagraph(_section(_xml(Template["cover-section.xml"]), references=ReferencesCover, start=None)),
                   *list(TitlePage), _sectionParagraph(_section(_xml(Template["cover-section.xml"]), references=References, start=2, numberFormat="lowerRoman"))]
    for i, x in enumerate(FrontMatter):
        Body.insert(i, x)
    for i, (Bookmark, Heading) in enumerate(AppendixPoints):
        Body.insert(Body.index(Bookmark), _sectionParagraph(SectionMain if i == 0 else SectionContent))
        Properties = deepcopy(_xml(Template["appendix-heading.xml"]).find("w:pPr", NS))
        Properties.find("w:pStyle", NS).set(f"{{{W}}}val", Mapping["styles"]["Heading8"])
        # Keep the source H1's outline role while using CAN's divider style.
        etree.SubElement(Properties, f"{{{W}}}outlineLvl", {f"{{{W}}}val": "0"})
        for x in Properties.findall("w:numPr", NS):
            Properties.remove(x)
        etree.SubElement(etree.SubElement(Properties, f"{{{W}}}numPr"), f"{{{W}}}numId", {f"{{{W}}}val": "0"})
        etree.SubElement(Properties, f"{{{W}}}pageBreakBefore", {f"{{{W}}}val": "0"})
        etree.SubElement(Properties, f"{{{W}}}keepNext", {f"{{{W}}}val": "0"})
        Heading.remove(Heading.find("w:pPr", NS))
        Heading.insert(0, Properties)
        SectionAppendix = _xml(Template["appendix-section.xml"])
        SectionAppendix.find("w:vAlign", NS).set(f"{{{W}}}val", "top")
        n = Body.index(Heading)
        Body.insert(n, _appendixTable(Heading, SectionAppendix))
        Table = Body[n]
        Body.insert(Body.index(Table) + 1, _sectionParagraph(_section(SectionAppendix, references=References, start=None)))
    Body.append(SectionContent if AppendixPoints else SectionMain)
    Fields = set()
    Ids = {x.get(f"{{{R}}}id") for x in ReferencesBody}
    for s in {posixpath.normpath(posixpath.join("word", x.get("Target"))) for x in Relationships if x.get("Id") in Ids}:
        if s in Content:
            x = _xml(Parts[s])
            Fields.update(_hydrateHeaderFooter(x, Spec["headerFooter"]))
            Parts[s] = _bytes(x)
    if Fields != set(Spec["headerFooter"]):
        raise ValueError("Header/footer metadata controls missing: " + ", ".join(sorted(set(Spec["headerFooter"]) - Fields)))
    Settings = _xml(Parts["word/settings.xml"])
    for x in Settings.findall("w:attachedTemplate", NS) + Settings.findall("w:updateFields", NS):
        Settings.remove(x)
    Parts["word/settings.xml"] = _bytes(Settings)
    if "word/_rels/settings.xml.rels" in Parts:
        x = _xml(Parts["word/_rels/settings.xml.rels"])
        for v in list(x):
            if v.get("Type") == R + "/attachedTemplate":
                x.remove(v)
        Parts["word/_rels/settings.xml.rels"] = _bytes(x)
    normalizeParagraphs(Document)
    Manifest = {"format": FORMAT, "sourceSha256": DIGEST, "contentSha256": sha256(Path(contentPath).read_bytes()).hexdigest(), "specSha256": sha256(Path(specPath).read_bytes()).hexdigest(), "coverElements": len(CoverChildren), "frontMatterElements": len(FrontMatter), "titleRemoved": TitleRemoved, "appendices": Spec["appendices"], "repairs": Repairs, "mapping": Mapping}
    Parts[MARKER] = (json.dumps(Manifest, ensure_ascii=False, indent=2) + "\n").encode()
    etree.SubElement(Types, f"{{{CT}}}Override", PartName="/" + MARKER, ContentType="application/json")
    for s, x in (("word/document.xml", Document), ("word/styles.xml", Styles), ("word/numbering.xml", Numbering), ("word/_rels/document.xml.rels", Relationships), ("[Content_Types].xml", Types)):
        Parts[s] = _bytes(x)
    validatePackage(Parts, contentParts=Content)
    writePackage(Parts, outputPath=outputPath, inputPaths=[templatePath, contentPath, specPath])
    return Manifest


def main():
    Parser = argparse.ArgumentParser(description=__doc__)
    Commands = Parser.add_subparsers(dest="command", required=True)
    x = Commands.add_parser("prepare-template")
    x.add_argument("--source", required=True, type=Path)
    x.add_argument("--output", required=True, type=Path)
    x = Commands.add_parser("compose")
    for s in ("template", "content", "spec", "output"):
        x.add_argument("--" + s, required=True, type=Path)
    x = Commands.add_parser("check-reference")
    x.add_argument("--reference", required=True, type=Path)
    ARGS = Parser.parse_args()
    if ARGS.command == "prepare-template":
        prepareTemplate(sourcePath=ARGS.source, outputPath=ARGS.output)
    if ARGS.command == "compose":
        composeDocument(templatePath=ARGS.template, contentPath=ARGS.content, specPath=ARGS.spec, outputPath=ARGS.output)
    if ARGS.command == "check-reference":
        checkReference(ARGS.reference)
        return
    print(json.dumps({"output": str(ARGS.output.resolve()), "sha256": sha256(ARGS.output.read_bytes()).hexdigest()}))


if __name__ == "__main__":
    main()
