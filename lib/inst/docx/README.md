# CAN DOCX resources

`quartoRender()` owns the complete render. It validates master metadata, resolves
appendix heading IDs with Pandoc, runs Quarto once, and invokes this installed
Python compositor before delivering each DOCX. The CLI uses that same R API.
These Python commands are private build/process interfaces, not a separate user CLI.

Python 3.9+ and `lxml` are required for DOCX only. Provision `lxml` explicitly in
the interpreter R resolves (`python3 -m pip install lxml`, or
`python -m pip install lxml` on Windows). Import failures are reported before
Quarto runs; NGR never installs Python modules on import or render.

## Generation

The admitted source is the human-formatted
`dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.docx`, SHA-256
`7ec329ffa48eea32f473cd9efcf1b39c054bdc43b7f1e8de4d1c0884e83d7605`.
Both generators reject another source. Run from the repository root:

```sh
python3 lib/inst/docx/build_reference.py --source dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.docx --output lib/inst/docx/reference.docx
python3 lib/inst/docx/compose_docx.py prepare-template --source dev/lib/CAPR003324_Crawford_SeismicHazard_20260831.docx --output lib/inst/docx/srk-template.zip
cp lib/inst/docx/reference.docx cli/scaffold/styles/reference.docx
python3 lib/inst/docx/compose_docx.py check-reference --reference cli/scaffold/styles/reference.docx
```

ZIP timestamps and member ordering are fixed. The reference and scaffold copy
must be byte-identical. The source report is needed only for regeneration;
the installed renderer consumes the prepared resources and never reads `dev/`.
The ZIP contains normalized components; it is not a Word `.dotx` template.

## Style and object contract

CAN supplies Letter geometry, Arial body/headings/captions/notes, list definitions,
cover typography and original SRK logo. `SRKTableText` is CAN's paragraph style
originally named `Table`. Pandoc's `Table` remains a borderless layout style;
`SRKDataTable` carries the rules extracted from CAN's first body table.
Pandoc paragraph roles inherit their CAN equivalents.

Quarto owns all resolved heading, caption, equation and appendix numbers. Native
Word numbering is removed from Heading1–4; Heading1–3 retain CAN's hanging indent
and use a tab after the resolved number. The equation filter preserves editable
math and places its resolved label at a right tab.

The compositor repairs only known duplicate paragraph properties and missing
terminal cell paragraphs. It unwraps the recognized one-cell Quarto caption/table
container so LibreOffice can repeat the inner table's header. The semantic table,
its caption, bookmarks, widths, grids, merges and row properties are retained.
The terminal empty paragraph supplies CAN's separation before subsequent text.
Other table shapes are preserved. Unknown property conflicts fail.

The body and all appendices share one bibliography and keep Quarto's resolved
links. Composition removes the request to update all fields on opening, which
can cause Word's external-file warning. Native PAGE fields remain live and are
recalculated by the page layout engine independently of that request. Other
fields, such as a Word table of contents, may require a manual update in Word.
Input requires one terminal section and each appendix bookmark immediately
before its Heading1. Internal body/landscape sections are explicitly unsupported.
Composition validates references, styles/numbering, inheritance cycles, notes,
bookmarks, content order and preserved objects before writing a sibling temporary
file and replacing the destination. This is not full OOXML schema validation.

## Checks and migration

`python3 lib/tests/test_docx.py` and the same command with `-O` exercise a real
Quarto fixture, object preservation, zero/two/three appendices and error cases.
R tests cover the installed API; `cli/tests/test_render.py` covers installed CLI
individual and manifest routes. Rendered Word and LibreOffice PDF review remains
necessary for new layouts and template revisions.

Projects keep their own reference and profile. Follow the explicit migration in
`cli/README.md`; render diagnoses an incompatible reference without overwriting it.
Custom references may retain the required roles and metadata controls; compatibility
does not certify their visual design. No scientific Crawford content is copied
into generated reports.
