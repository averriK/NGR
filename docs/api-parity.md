# NGR R ↔ Python API parity

This document tracks the implementation status of the public NGR R API versus
its Python implementation (`ngr`). For now we focus on:

- `buildPlot` and its variants
- `buildTable`
- the `show*` helpers

## Status legend

- `not-implemented`  → no Python implementation yet
- `partial`          → exists but is missing options/behaviour
- `complete`         → reasonably close parity with the R version

## Prioritised functions

### buildPlot y derivados

**R/Python mapping notes:** the R API uses function names with dots (e.g.
`buildPlot.Bar`, `buildPlot.Histogram`). The Python API will use very similar
names but in a Python-friendly style (e.g. `buildPlotBar`,
`buildPlotHistogram`), keeping prefixes and semantics aligned.

| R function             | Python name        | Status          | Initial notes |
|------------------------|--------------------|-----------------|-----------------|
| `buildPlot`            | `buildPlot`        | partial         | Stub implemented in Python (`ngr.buildPlot`) with equivalent signature; plotting logic still missing. |
| `buildPlotBar` (`buildPlot.Bar`) | `buildPlotBar`     | not-implemented | Specialised wrapper around `buildPlot` for bar/column charts. |
| `buildPlotHistogram` (`buildPlot.Histogram`) | `buildPlotHistogram` | not-implemented | Specialised wrapper for histograms/densities. |
| `buildPlotHist2D` (`buildPlot.Hist2D`)     | `buildPlotHist2D`  | not-implemented | 2D histogram / contour; in Python planned via Highcharts for Python (`highcharts-core`). |
| `buildPlotHist3D` (`buildPlot.Hist3D`)     | `buildPlotHist3D`  | not-implemented | 3D bar histogram; in Python planned via Highcharts for Python (`highcharts-core`). |
| `buildPlotModel` (`buildPlot.Model`)      | `buildPlotModel`   | not-implemented | Model plot (lines + points in log–log space). |

#### Firmas Python propuestas (resumen)

```python path=null start=null
# Input data is expected as tabular structures (exact Python types TBD).
# Names and argument meanings follow the R version, adapted to Python.

def buildPlot(
    data_lines=None,
    data_points=None,
    line_type="line",
    plot_title=None,
    plot_subtitle=None,
    plot_height=None,
    plot_width=None,
    xAxis_legend="X",
    yAxis_legend="Y",
    group_legend="ID",
    color_palette="Dark 3",
    line_style="solid",
    point_style="circle",
    line_size=1.0,
    point_size=3.0,
    xAxis_log=False,
    yAxis_log=False,
    xAxis_reverse=False,
    yAxis_reverse=False,
    xAxis_max=None,
    yAxis_max=None,
    xAxis_min=None,
    yAxis_min=None,
    xAxis_label=True,
    yAxis_label=True,
    legend_layout="horizontal",
    legend_align="right",
    legend_valign="top",
    legend_show=True,
    plot_save=False,
    plot_theme=None,
    xAxis_legend_fontsize="14px",
    yAxis_legend_fontsize="14px",
    group_legend_fontsize="12px",
    plot_title_fontsize="24px",
    plot_subtitle_fontsize="18px",
    print_max_abs=False,
    point_dataLabels=False,
    plot_filename=None,
    fill_opacity=0.3,
    fill_legend=None,
    fill_max=".max",
    fill_min=".min",
    fill_minmax=False,
    interpolation_method="linear",
):
    ...


def buildPlotBar(data, **kwargs):
    """Equivalent to ``buildPlot.Bar`` in R, with the same key arguments.
    ``data`` will typically be a DataFrame with columns X, Y, ID.
    """
    ...


def buildPlotHistogram(data, **kwargs):
    ...


def buildPlotHist2D(data, **kwargs):
    ...


def buildPlotHist3D(data, **kwargs):
    ...


def buildPlotModel(data_lines, data_points, xAxis_legend, yAxis_legend,
                   line_width=1.5, point_size=2, point_shape="circle"):
    ...
```

> Note: In R, dots are used in function names; in Python this is discouraged.
> We therefore use a very similar but Python-friendly naming convention
> (`buildPlotBar`, `buildPlotHistogram`, etc.), keeping the same prefixes to
> make the mapping obvious.

### Tables

| R function   | Python name | Status          | Initial notes |
|-------------|-------------|-----------------|---------------|
| `buildTable`| `buildTable`| partial         | Stub implemented in Python (`ngr.buildTable`) with equivalent signature; table rendering logic still missing. |

### Presentation helpers `show*`

| R function             | Python name          | Status          | Initial notes |
|------------------------|----------------------|-----------------|---------------|
| `showCode`             | `showCode`           | not-implemented | Show source code with syntax highlighting / nicer view. |
| `showHTML`             | `showHTML`           | not-implemented | Display/render HTML (e.g. in a notebook or browser). |
| `showPDF`              | `showPDF`            | not-implemented | Open/render PDFs; in Python this may delegate to the OS or embedded viewers. |
| `showMarkdownRendered` | `showMarkdownRendered` | not-implemented | Render Markdown to HTML/terminal. |
| `showGithubREADME`     | `showGithubREADME`   | not-implemented | Fetch and display a GitHub README; in Python this may use `requests`/GitHub API. |
| `showASCII`            | `showASCII`         | not-implemented | ASCII effects in terminal; keep similar visual behaviour. |
| `showTypewriter`       | `showTypewriter`    | not-implemented | Typewriter-style animation; e.g. in terminal/notebook. |
| `rotateTypewriter`     | `rotateTypewriter`  | not-implemented | Rotating typewriter effect over multiple texts. |
| `buildIndexTypewriter` | `buildIndexTypewriter` | not-implemented | Build an index-style typewriter view; requires inspecting the R implementation. |

## Next steps

1. For each function above, capture the exact R signature (arguments, defaults)
   and propose the closest reasonable Python signature.
2. Document unavoidable type differences (e.g. R `data.table` to whatever
   Python tabular representation is chosen) and behaviour differences.
3. Implement an initial subset (all `show*`) under `python/src/ngr/`, with
   tests in `python/tests/`.
4. Update the "Status" column as implementations progress and publish new
   PyPI versions (`0.1.x`) accordingly.
