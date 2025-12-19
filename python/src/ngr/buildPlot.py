from __future__ import annotations

from typing import Any, Optional


def buildPlot(
    library: Optional[str] = None,          # seaborn y plotly
    plot_type: Optional[str] = None,        # forzar un tipo de gráfico
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
    """
    Build a plot equivalent to :func:`buildPlot` in R.

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
