"""Python interface for the NGR (Next Generation Reporting) R package.

This module defines the public Python API. At this stage it only exposes
**stubs** for :func:`buildPlot` and :func:`buildTable` whose signatures mirror
the corresponding R functions.
"""

from __future__ import annotations

from typing import Any, Optional

__all__ = ["buildPlot", "buildTable"]
__version__ = "0.0.1"


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
