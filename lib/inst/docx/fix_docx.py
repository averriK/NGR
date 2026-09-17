#!/usr/bin/env python3
"""
Patch Quarto/Pandoc DOCX output after render.

The fixes are intentionally limited to word/document.xml and word/styles.xml:
  1. Make tables use autofit layout.
  2. Add an empty paragraph before a table-cell close when the cell ends in a
     nested table.
  3. Merge duplicate paragraph-property blocks generated around captions.
  4. Keep a plain Appendix marker from consuming appendix numbering.
  5. Rebind appendix custom styles when Pandoc creates BodyText fallbacks.

The implementation uses surgical text edits instead of XML reserialization so
namespace prefixes and unrelated OOXML parts remain untouched.
"""
from __future__ import annotations

import argparse
import os
import re
import shutil
import sys
import zipfile
from pathlib import Path
from xml.sax.saxutils import unescape


APPENDIX_STYLE_BASES = {
    "AppHead1": ("Appx1Cover", "SectionCover", "Heading1"),
    "Head2NonTOC": ("Appx2Cover", "TOCHeading2", "Heading2"),
    "Head3NonTOC": ("TOC3Heading", "Heading3", "TOC4Heading"),
}


def collect_inputs(cli_inputs: list[str], quarto_env_var: str) -> list[Path]:
    files: list[Path] = []

    for item in cli_inputs:
        path = Path(item).expanduser().resolve()
        if path.suffix.lower() != ".docx":
            continue
        if not path.exists():
            raise SystemExit(f"[fix_docx] not found: {path}")
        files.append(path)

    if not files and quarto_env_var:
        for line in os.getenv(quarto_env_var, "").splitlines():
            output = line.strip()
            if not output or not output.lower().endswith(".docx"):
                continue
            path = Path(output)
            if not path.is_absolute():
                path = (Path.cwd() / path).resolve()
            if path.exists():
                files.append(path)

    if not files:
        raise SystemExit(
            "[fix_docx] no inputs; pass DOCX paths or use "
            "QUARTO_PROJECT_OUTPUT_FILES"
        )

    seen: set[Path] = set()
    unique_files: list[Path] = []
    for path in files:
        if path in seen:
            continue
        unique_files.append(path)
        seen.add(path)

    return unique_files


def patch_tables(xml_bytes: bytes) -> tuple[bytes, int]:
    text = xml_bytes.decode("utf-8")
    original = text

    text = re.sub(
        r'(<w:tblLayout\b[^>]*w:type=")fixed(")',
        r"\g<1>autofit\2",
        text,
    )
    text = re.sub(
        r"(<w:tblLayout)(\s*/>)",
        r'\1 w:type="autofit"\2',
        text,
    )

    def ensure_tbl_layout(match: re.Match[str]) -> str:
        block = match.group(0)
        if "w:tblLayout" in block:
            return block
        return re.sub(
            r"(<w:tblPr\b[^>]*>)",
            r'\1<w:tblLayout w:type="autofit"/>',
            block,
            count=1,
        )

    text = re.sub(
        r"<w:tblPr\b[^>]*>.*?</w:tblPr>",
        ensure_tbl_layout,
        text,
        flags=re.DOTALL,
    )
    text = re.sub(r"<w:tblW\b[^/]*/>\s*", "", text)
    text = re.sub(
        r"<w:tcW\b[^/]*/>",
        '<w:tcW w:w="0" w:type="auto"/>',
        text,
    )

    if text == original:
        return xml_bytes, 0

    count = len(re.findall(r'<w:tblLayout\b[^>]*w:type="autofit"', text))
    return text.encode("utf-8"), count


def patch_cell_endings(xml_bytes: bytes) -> tuple[bytes, int]:
    text = xml_bytes.decode("utf-8")
    text, count = re.subn(
        r"(</w:tbl>)((?:\s|<w:bookmarkEnd[^/]*/>)*)(</w:tc>)",
        r"\1\2<w:p/>\3",
        text,
    )

    if count == 0:
        return xml_bytes, 0
    return text.encode("utf-8"), count


def patch_duplicate_ppr(xml_bytes: bytes) -> tuple[bytes, int]:
    text = xml_bytes.decode("utf-8")
    count = 0
    result: list[str] = []
    pos = 0

    for join in re.finditer(r"</w:pPr>(\s*)<w:pPr>", text):
        open1 = text.rfind("<w:pPr>", pos, join.start())
        if open1 == -1:
            continue

        close2 = text.find("</w:pPr>", join.end())
        if close2 == -1:
            continue
        close2_end = close2 + len("</w:pPr>")

        ppr2_content = text[join.end():close2]
        ppr2_content = re.sub(r"<w:spacing[^/]*/>\s*", "", ppr2_content)

        result.append(text[pos:open1])
        result.append(f"<w:pPr>{ppr2_content}</w:pPr>")
        pos = close2_end
        count += 1

    if count == 0:
        return xml_bytes, 0

    result.append(text[pos:])
    return "".join(result).encode("utf-8"), count


def paragraph_text(paragraph_block: str) -> str:
    parts = re.findall(
        r"<w:t(?:\s[^>]*)?>(.*?)</w:t>",
        paragraph_block,
        flags=re.DOTALL,
    )
    return "".join(unescape(part) for part in parts).strip()


def patch_appendix_marker(
    xml_bytes: bytes,
    section_cover_available: bool = False,
) -> tuple[bytes, int]:
    if not section_cover_available:
        return xml_bytes, 0

    text = xml_bytes.decode("utf-8")
    count = 0

    def replace_marker(match: re.Match[str]) -> str:
        nonlocal count
        block = match.group(0)
        if '<w:pStyle w:val="AppHead1"' not in block:
            return block
        marker = paragraph_text(block).lower().rstrip(".")
        if marker not in {"appendix", "appendices"}:
            return block

        patched = re.sub(
            r'(<w:pStyle\b[^>]*\bw:val=")AppHead1(")',
            r"\1SectionCover\2",
            block,
            count=1,
        )
        if patched != block:
            count += 1
        return patched

    text = re.sub(
        r"<w:p\b[^>]*>.*?</w:p>",
        replace_marker,
        text,
        flags=re.DOTALL,
    )

    if count == 0:
        return xml_bytes, 0
    return text.encode("utf-8"), count


def style_exists(text: str, style_id: str) -> bool:
    return re.search(
        rf'<w:style\b[^>]*\bw:styleId="{re.escape(style_id)}"',
        text,
    ) is not None


def is_pandoc_style_fallback(style_block: str) -> bool:
    return (
        '<w:basedOn w:val="BodyText"' in style_block
        and "<w:pPr" not in style_block
        and "<w:rPr" not in style_block
    )


def appendix_style_block(style_id: str, based_on: str) -> str:
    return (
        f'<w:style w:type="paragraph" w:customStyle="1" '
        f'w:styleId="{style_id}">'
        f'<w:name w:val="{style_id}"/>'
        f'<w:basedOn w:val="{based_on}"/>'
        '<w:next w:val="Normal"/>'
        '<w:qFormat/>'
        '</w:style>'
    )


def patch_appendix_styles(xml_bytes: bytes) -> tuple[bytes, int]:
    text = xml_bytes.decode("utf-8")
    count = 0

    for style_id, base_candidates in APPENDIX_STYLE_BASES.items():
        pattern = (
            rf'(<w:style\b[^>]*\bw:styleId="{re.escape(style_id)}"'
            rf'[^>]*>.*?</w:style>)'
        )
        match = re.search(pattern, text, flags=re.DOTALL)
        if match is None or not is_pandoc_style_fallback(match.group(1)):
            continue

        based_on = next(
            (
                candidate
                for candidate in base_candidates
                if style_exists(text, candidate)
            ),
            "",
        )
        if not based_on:
            continue

        text = (
            text[: match.start(1)]
            + appendix_style_block(style_id, based_on)
            + text[match.end(1):]
        )
        count += 1

    if count == 0:
        return xml_bytes, 0
    return text.encode("utf-8"), count


def fix_docx(docx_path: Path, dry_run: bool = False) -> dict[str, int]:
    stats = {
        "tables": 0,
        "cell_endings": 0,
        "duplicate_ppr": 0,
        "appendix_markers": 0,
        "appendix_styles": 0,
    }

    if dry_run:
        with zipfile.ZipFile(docx_path, "r") as archive:
            try:
                styles = archive.read("word/styles.xml")
            except KeyError:
                styles = b""
            section_cover_available = (
                bool(styles)
                and style_exists(styles.decode("utf-8"), "SectionCover")
            )

            document = archive.read("word/document.xml")
            _, stats["cell_endings"] = patch_cell_endings(document)
            _, stats["tables"] = patch_tables(document)
            _, stats["duplicate_ppr"] = patch_duplicate_ppr(document)
            _, stats["appendix_markers"] = patch_appendix_marker(
                document,
                section_cover_available,
            )
            if styles:
                _, stats["appendix_styles"] = patch_appendix_styles(styles)
        return stats

    tmp = docx_path.with_suffix(".fix.tmp")
    try:
        with zipfile.ZipFile(docx_path, "r") as zin, zipfile.ZipFile(
            tmp,
            "w",
            zipfile.ZIP_DEFLATED,
        ) as zout:
            try:
                styles_text = zin.read("word/styles.xml").decode("utf-8")
            except KeyError:
                styles_text = ""
            section_cover_available = style_exists(styles_text, "SectionCover")

            for item in zin.infolist():
                data = zin.read(item.filename)
                if item.filename == "word/document.xml":
                    data, stats["cell_endings"] = patch_cell_endings(data)
                    data, stats["tables"] = patch_tables(data)
                    data, stats["duplicate_ppr"] = patch_duplicate_ppr(data)
                    data, stats["appendix_markers"] = patch_appendix_marker(
                        data,
                        section_cover_available,
                    )
                elif item.filename == "word/styles.xml":
                    data, stats["appendix_styles"] = patch_appendix_styles(data)
                zout.writestr(item, data)
        shutil.move(str(tmp), str(docx_path))
    finally:
        tmp.unlink(missing_ok=True)

    return stats


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Patch Quarto/Pandoc DOCX post-processing issues.",
    )
    parser.add_argument("inputs", nargs="*", metavar="FILE")
    parser.add_argument(
        "--quarto-env-var",
        default="QUARTO_PROJECT_OUTPUT_FILES",
        help="environment variable containing DOCX output files",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="count fixes without modifying files",
    )
    args = parser.parse_args(argv)

    for docx in collect_inputs(args.inputs, args.quarto_env_var):
        stats = fix_docx(docx, dry_run=args.dry_run)
        verb = "would fix" if args.dry_run else "fixed"
        parts = [f"{value} {key}" for key, value in stats.items() if value > 0]
        summary = ", ".join(parts) if parts else "nothing to fix"
        print(f"[fix_docx] {verb}: {summary} in {docx.name}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
