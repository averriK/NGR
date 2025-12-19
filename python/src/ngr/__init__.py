"""
Python interface for the NGR (Next Generation Reporting) R package.

This module defines the public Python API. At this stage it only exposes
**stubs** for :func:`buildPlot` and :func:`buildTable` whose signatures mirror
the corresponding R functions.
"""

from __future__ import annotations

from typing import Any, Optional

__all__ = ["buildPlot", "buildTable"]
__version__ = "0.0.1"


def buildTable(
    x: Any,
    library: str = "gt",
    format: str = "html",
    font_size_header: int = 14,
    font_size_body: int = 12,
    font_family_header: str = "Arial",
    font_family_body: str = "Arial",
    caption: Optional[str] = None,
    font_bold_header: bool = True,
    font_bold_body: bool = False,
    font_bold_all: Optional[bool] = None,
    font_size_all: Optional[int] = None,
    font_family_all: Optional[str] = None,
    vlines_show: bool = False,
    hlines_show: bool = True,
    vlines_color: str = "grey",
    hlines_color: str = "grey",
    vlines_size: int = 1,
    hlines_size: int = 1,
    align_header: str = "center",
    align_body: str = "left",
) -> Any:
    """
    Build a table equivalent to :func:`buildTable` in R.

    This is a *stub*: it exposes (most of) the same API as the R version for
    the main options (backend library, output format and styling), but it
    does not render anything yet.

    Parameters
    ----------
    x
        Input data equivalent to ``.x`` in R, i.e. a tabular structure whose
        exact Python representation is still to be decided.
    library
        Table backend ("gt", "flextable", "kable" or a future Python
        equivalent).
    format
        Desired output format ("html", "pdf", "docx", etc.).

    Returns
    -------
    Any
        In the future, a rendered table object. For now this always raises
        :class:`NotImplementedError`.
    """

    raise NotImplementedError("buildTable() aún no está implementada en ngr (Python).")
