"""Python interface for the NGR (Next Generation Reporting) R package.

This module defines the public Python API. At this stage it only exposes
**stubs** for :func:`buildPlot` and :func:`buildTable` whose signatures mirror
the corresponding R functions.
"""

from __future__ import annotations

from typing import Any, Optional

__all__ = ["buildPlot", "buildTable"]
__version__ = "0.0.1"


def _require_greater_tables():
    """Import pandas + greater_tables lazily and fail with a clear message.

    This keeps the ngr package importable even if the optional Python
    backends are not installed.
    """
    try:
        import pandas as pd  # type: ignore
    except ImportError as exc:  # pragma: no cover - import error path
        raise ImportError(
            "ngr.buildTable() requires pandas. Install it with 'pip install pandas'."
        ) from exc

    try:
        from greater_tables import GT  # type: ignore
    except ImportError as exc:  # pragma: no cover - import error path
        raise ImportError(
            "ngr.buildTable() requires greater_tables. Install it with 'pip install greater-tables'."
        ) from exc

    return pd, GT


def _to_dataframe(x: Any, pd_module: Any) -> "pd.DataFrame":
    """Best-effort conversion of user input to a pandas.DataFrame.

    This mirrors the R behaviour of accepting data.frame/data.table inputs,
    but in Python we keep the contract deliberately loose for now.
    """
    pd = pd_module

    if isinstance(x, pd.DataFrame):
        return x

    # Simple and conservative conversions; can be extended later
    if isinstance(x, dict):
        return pd.DataFrame(x)
    if isinstance(x, (list, tuple)):
        return pd.DataFrame(x)

    raise TypeError(
        "ngr.buildTable(): unsupported input type for 'x'; provide a pandas.DataFrame "
        "or a dict/list/tuple that can be converted into one."
    )


def buildPlot(
    library: Optional[str] = None,
    plot_type: Optional[str] = None,
    data_lines: Any = None,
    data_points: Any = None,
    line_type: str = "line",
    plot_title: Optional[str] = None,
    plot_subtitle: Optional[str] = None,
    plot_height: Optional[float] = None,
    plot_width: Optional[float] = None,
    xAxis_legend: str = "X",
    yAxis_legend: str = "Y",
    group_legend: str = "ID",
    color_palette: str = "Dark 3",
    line_style: str = "solid",
    point_style: str = "circle",
    line_size: float = 1.0,
    point_size: float = 3.0,
    xAxis_log: bool = False,
    yAxis_log: bool = False,
    xAxis_reverse: bool = False,
    yAxis_reverse: bool = False,
    xAxis_max: Optional[float] = None,
    yAxis_max: Optional[float] = None,
    xAxis_min: Optional[float] = None,
    yAxis_min: Optional[float] = None,
    xAxis_label: bool = True,
    yAxis_label: bool = True,
    legend_layout: str = "horizontal",
    legend_align: str = "right",
    legend_valign: str = "top",
    legend_show: bool = True,
    plot_save: bool = False,
    plot_theme: Any = None,
    xAxis_legend_fontsize: str = "14px",
    yAxis_legend_fontsize: str = "14px",
    group_legend_fontsize: str = "12px",
    plot_title_fontsize: str = "24px",
    plot_subtitle_fontsize: str = "18px",
    print_max_abs: bool = False,
    point_dataLabels: bool = False,
    plot_filename: Optional[str] = None,
    fill_opacity: float = 0.3,
    fill_legend: Optional[str] = None,
    fill_max: str = ".max",
    fill_min: str = ".min",
    fill_minmax: bool = False,
    interpolation_method: str = "linear",
) -> Any:
"""Build a plot equivalent to :func:`buildPlot` in R.

    This is a *stub implementation*: the signature mirrors the R function of
    the same name, but no plotting logic is implemented yet.

    Parameters
    ----------
    library, plot_type
        Kept for compatibility with the R version (both are deprecated there).
    data_lines, data_points
        Inputs equivalent to ``data.lines`` and ``data.points`` in R.
        In Python these will be tabular structures with columns
        ``ID``, ``X`` and ``Y`` (exact type still to be decided).

    Other parameters
        Preserve the same meaning as in the R function: titles, axes, legend,
        styles, sizes, saving options, interpolation, etc.

    Returns
    -------
    Any
        In the future, a figure object (e.g. from ``plotly`` or
        ``matplotlib``). For now this always raises :class:`NotImplementedError`.
    """

    raise NotImplementedError("buildPlot() aún no está implementada en ngr (Python).")


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
    """Build a table equivalent to :func:`buildTable` in R.

    This is an initial implementation: it wires the R-style API to a modern
    Python table backend (Greater Tables / ``greater_tables.GT``) so that
    Quarto can render high-quality HTML tables from Python chunks.

    Parameters
    ----------
    x
        Input data equivalent to ``.x`` in R, i.e. a tabular structure whose
        exact Python representation is still to be decided.
    library
        Table backend selector. Currently only ``"gt"`` is supported on the
        Python side and is mapped to :class:`greater_tables.GT`.
    format
        Desired output format ("html", "pdf", "docx", etc.). For now this is
        mostly informational; the HTML representation is used by Quarto.

    Returns
    -------
    Any
        A table object that Quarto can render (currently a ``GT`` instance).
    """

    if library != "gt":
        raise NotImplementedError(
            "ngr.buildTable() currently only supports library='gt' on the Python "
            "side."
        )

    pd, GT = _require_greater_tables()
    df = _to_dataframe(x, pd)

    # Minimal mapping for now: construct a GT table from the DataFrame.
    # Styling options (fonts, borders, alignment, etc.) can be wired
    # progressively to GT as we refine the design.
    tbl = GT(df)

    # Caption support, if GT exposes a suitable attribute or method.
    # We avoid guessing too much here; this is a placeholder for future
    # integration once the exact GT API usage is agreed.
    if caption is not None:
        # Many table libraries use 'title' or 'caption' arguments; adapt as
        # needed once the final GT API is confirmed.
        try:  # pragma: no cover - defensive path
            tbl.caption = caption  # type: ignore[attr-defined]
        except Exception:
            # Fallback: ignore caption if the backend does not support it in
            # this way. We'll wire this up properly once GT usage is fixed.
            pass

    return tbl
