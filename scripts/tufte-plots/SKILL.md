---
name: tufte-plots
description: Use whenever generating, editing, or saving figures with matplotlib, seaborn, or pandas .plot(). Applies the user's Tuftian aesthetic — minimum non-data ink, no chart junk over the data, rank-ordered color for ordered levels, sparse concise ticks, Adwaita Sans, no titles, off-plot legends. Activate even for "quick" plots; the user does not want default matplotlib output.
---

# Tufte Plots

**One goal: the data region is unencumbered by chart junk.** Every rule below is
a consequence of that. When a case is not covered, fall back to the goal.

`SKILL.md` is the rules; `style.py` is the reference. Read `style.py` the first
time you reach for a helper in a session — it carries exact signatures and the
reasoning behind each default.

## Quick start

```python
import os, sys
from pathlib import Path
_here = Path(__file__).resolve().parent if "__file__" in globals() else Path.cwd()
for _c in [os.environ.get("TUFTE_STYLE_DIR"), _here, _here / "_style",
           *(p / "scripts" for p in _here.parents[:4]),
           Path.home() / ".claude/skills/tufte-plots"]:
    if _c and (Path(_c) / "style.py").is_file():
        sys.path.insert(0, str(_c)); break
else:
    raise SystemExit("style.py not found — copy it next to this script")

import matplotlib.pyplot as plt
from style import (apply_tufte, palette_for, ordinal_colors, place_legend,
                   finish_axes, despine, embedding_axes, categorical_ticks,
                   add_colorbar, level_legend, PRIMARY_INK, SECONDARY_INK)

apply_tufte()

fig, ax = plt.subplots(figsize=(4, 4))
ax.scatter(df.sepal_length, df.petal_length, s=12, alpha=0.6, color=PRIMARY_INK)
ax.set_xlabel("Sepal length (cm)")
ax.set_ylabel("Petal length (cm)")
finish_axes(ax)
fig.savefig("out.svg")
```

**If the script will run anywhere but this machine** — a repo you push, a
container, a cluster job — copy `style.py` into the project (`scripts/style.py`)
and commit it. It is one dependency-free file; that copy *is* the install, and
the bootstrap finds it before `~/.claude`.

## The four calls

Everything else is optional. These are not.

```python
apply_tufte()                       # once per script
colors, cmap = palette_for(levels)  # whenever color encodes something
place_legend(ax)                    # if there is a legend at all
finish_axes(ax)                     # LAST, on every dimensioned panel
```

`finish_axes` despines, sets sparse round ticks with concise labels, and squares
the data area. Skipping it is the single most common way to fail this skill.

## Hard rules

1. **`finish_axes(ax)` is the last call on every dimensioned panel.** Never set
   ticks, tick labels, or formatters by hand. `range_frame` is gone — do not use it.
2. **Nothing goes over the data unless the user asked for it.** See below.
3. **Do not describe the figure you just made.** See below.
4. **Deliver the figure before inspecting it.** Do not render a PNG preview and
   look at it before handing the figure over — that roughly doubles the token
   cost and makes the user wait on a check they did not ask for. Save the
   figure, show it, stop. Look at it only if they report a problem or ask for a
   change; then the inspection is aimed at something real. `finish_axes` and the
   rules below exist so the first render is right without a rehearsal.
5. **Color follows what the levels *are*** — see the decision table. Ordered or
   numeric levels never get the nominal palette.
6. **Type comes from rcParams.** Never pass `fontsize=` to ticks, legend, or
   annotations. For word axes call `categorical_ticks(ax)`, which bumps them to
   body size and rotates only if needed.
   The ladder is two-tier: body text (labels, legend, titles) at 8 pt, and only
   genuinely small labels (tick labels) at 5 pt. Never put body text at 5 pt or
   shrink below 5 pt to fit — cut words instead. Default family is Adwaita Sans;
   ink is true black (`PRIMARY_INK` = `#000000`).
7. **Size: `figsize=(4, 4)`. This is the answer almost every time.**
   A bigger canvas does not add information — it shrinks the type relative to
   the figure, which is the opposite of what you want. Go wider only when the
   x-axis genuinely carries a long sequence, and then `(5, 3)` with
   `finish_axes(ax, box_aspect=3/5)`. Do not exceed 4 in on either side of a
   single panel unasked. **Publication figures are the exception** — there the
   width is set by the journal column via `publication-figures`' `figure()`, not
   by this default. Never shrink text to make something fit — cut words.
8. **No grid, no background fill, no top/right spines.** `finish_axes` handles it.
9. **Embeddings get no axes at all.** UMAP, t-SNE, PCA, MDS, diffusion maps —
   the coordinates carry no units, so ticks and spines invite comparing
   meaningless numbers. Call `embedding_axes(ax)`, not `finish_axes`. Do not
   label the axes: "UMAP 1" names an axis with no units and no direction. Say
   which embedding it is in the caption or a panel title.
10. **Axis labels in plain English, sentence case, units in parens** —
    `"Sequence length (bp)"`, never `"seq_len"`.
11. **Legends live outside the axes, preferentially BELOW the plot.**
    `place_legend(ax)` does this. Below costs height; a right-hand legend costs
    width and can squeeze the panel to half the figure. Use `side="right"` only
    when labels are too long to lay out horizontally.
    **A legend is mandatory whenever colour, marker, or line style encodes a
    variable** — do not ship an encoded figure without one unless the user
    explicitly asked for no legend, or every series is already named by
    `label_lines_directly`. The only figures that legitimately have no legend
    are single-series plots (nothing to distinguish) and directly-labelled ones.
    **Always verify the legend does not physically overlap the data or the
    axes.** This is a programmatic bbox check, not a visual preview (it does not
    trigger rule 4): after the final `place_legend`, draw the canvas and compare
    the legend's window extent against the axes data area and every artist —
    ```python
    fig.canvas.draw()
    r = fig.canvas.get_renderer()
    leg = ax.get_legend()
    lb = leg.get_window_extent(r)
    bad = lb.overlaps(ax.get_window_extent(r))          # legend over its own axes
    ```
    If it overlaps, move the legend out (below, or `side="right"`), shrink the
    data area, or drop to `ncol`-wide below — never leave a legend sitting on
    top of the marks. `place_legend(ax)` puts it outside by default; the check
    catches the cases where a hand-placed `loc=` or a crowded panel breaks that.
12. **Titles are off by default** — a standalone panel's title duplicates the
    caption. **Per-panel titles are required for small multiples**: they are how
    the reader knows which subset each panel shows. One short line, **sentence
    case like an axis label, no period** — capitalize the first letter even when
    the underlying data value is lowercase (`setosa` → `Setosa`). Titles are
    prose, not raw values. Leave case-sensitive identifiers as they are (gene
    symbols, software names, `pH`).
13. **Lines `linewidth=1.0`, markers small (`s=10–20`), alpha when marks
    overlap.** Primary data in `PRIMARY_INK`; anything secondary in
    `SECONDARY_INK`.
14. **Panel letters (a, b, c ...) are bold** — the one place the house style uses
     bold, since they index the figure rather than label a data dimension. Draw
     them with `panel_label(ax, "a")`: it requests `fontweight="bold"` and, when
     the active family ships no usable bold face (Adwaita Sans is a variable font
     whose bold weight matplotlib cannot extract here), adds a proportional
     synthetic-bold stroke so the letter reads bold regardless.
15. **seaborn is not guaranteed installed.** Write matplotlib.
15. **Save SVG by default**, white background, no transparency.

## Color: pick by what the levels are

| levels | what they are | call |
|---|---|---|
| 1 | nothing to distinguish | `PRIMARY_INK` — a hue would be decoration |
| 2, equal status | peer comparison | `two_color_palette` |
| 2, one is the point | callout vs background | `callout_palette` |
| 3–4, **unordered names** | nominal — species, methods, datasets | `categorical_palette` |
| **any count, ordered or numeric** — lr, dose, timepoint, k, depth, quantile | ordinal / quantitative | **`ordinal_colors(levels)` — never `categorical_palette`** |
| continuous per-point value | quantitative | `viridis` + `add_colorbar(ax, values, label=...)` |

`categorical_palette` asserts *"these are different kinds."* A learning-rate
sweep is not four kinds — it is one axis sampled four times. Four unrelated hues
throw away the ordering the reader needs. Mapping color by *value* instead is no
better: `1e-4, 1e-3, 1e-2` all land in the same dark purple. `ordinal_colors`
spaces levels uniformly **by rank**, so every step is equally visible.

**The test:** would swapping two of these colors change the meaning? If no, the
levels are ordered — use `ordinal_colors`. When unsure call `palette_for(levels)`;
it reads the levels and decides. Numeric levels route to the ramp on their own;
if they are really names that happen to be numbers (cluster 0/1/2), say so with
`kind="nominal"`.

With few enough named levels, pair `ordinal_colors` with `level_legend(ax, mapping)`.
With a genuinely continuous per-point value, use a colorbar.

Banned outright: `tab10`, `tab20`, `jet`, `rainbow`, `hsv`, `turbo`,
ColorBrewer `Set1`. Sequential default is `viridis` (`mako`/`crest` are seaborn-only).

## Nothing over the data unless asked

Do not add annotations, callout text, leader lines, arrows, reference or
threshold lines, shaded spans (`axvspan`/`axhspan`/`fill_between` as highlight),
significance bars, trend lines, or inline statistics **unless the user asked
for them**. Plot the data, label the axes, stop.

These marks are non-data ink placed on top of the data. The reader did not ask
what to look at, and you do not yet know what the figure is arguing.

*Available on request* — use these when the user asks, not before:
`reference_line(ax, v, label=...)`, `rug(ax, x=...)`, `panel_stat`,
`significance_bar`. The one exception is `label_lines_directly(ax, {...})` used
**in place of** a legend on ≤4 series: that relocates ink the figure already
spends rather than adding any.

## Do not narrate the figure

The user asked for this plot. They can see it. Say where you saved it and stop.

No sentences explaining what the plot shows, what the axes are, which colors you
used, or what the reader should notice. Decisions worth a clause — why small
multiples, why a log axis, a caveat about the data — are fine. Describing the
result is not.

## Techniques to prefer

- **Small multiples** over overlay when comparing groups:
  `fig, axes = plt.subplots(1, n, sharey=True, figsize=(n*1.6, 1.9))`. Same
  scale, same axes, per-panel titles; the eye does the comparison. Keep panels
  small — four panels at 1.6 in each read better than four at 2.5 in. The gutter
  between them comes from `apply_tufte()`; do not close it up. Panels that
  nearly touch read as one continuous axis, which is the whole failure mode
  small multiples exist to avoid.
  Label a shared axis **once** with `fig.supxlabel(...)` / `fig.supylabel(...)`,
  not on every panel — repeated labels are redundant ink and get squeezed out of
  short figures. Pass `box_aspect=None` to `finish_axes` on these panels and let
  the layout size them.
- **Histograms are filled**, in `PRIMARY_INK` (or one palette color), not drawn
  as `histtype="step"` outlines. An outline spends ink on the boundary rather
  than the quantity and reads as a line chart.
  For comparing groups, **default to small multiples** on shared bins and scale.
  If the user asks for a single overlaid panel, give them one — but overlay two
  levels as a callout (highlight vs pooled background), not N translucent fills:
  three alpha fills produce six colors for three categories, and the mixtures
  are in neither the palette nor the legend. Normalize (`density=True`) or state
  both n when the groups differ in size. Which of the two to use is the user's
  call, not yours; small multiples is only the default.
- **Direct labeling** over a legend when ≤4 series — `label_lines_directly`.
- **Flip horizontal** when category names are long: `orient="h"`, or swap x/y.
  Level text reads faster than rotated text and does not constrain height.
- **Show n**: when plotting summaries, overlay the raw points with a jittered
  `ax.scatter(..., s=6, alpha=0.4)` if n is small enough.

## Anti-patterns to refuse

Pie and donut charts, stacked area, 3D anything, dual/twin y-axes that re-encode
one variable. Say so in one sentence and offer the honest alternative — no
lecture. Also refuse: hatching, gradients, drop shadows, beveled bars; unfilled
(`histtype="step"`) histograms; redundant
encoding; heavy opaque markers on dense scatter; minor ticks off a log axis;
pure black (`#000` — use `PRIMARY_INK`); pure black (`#000` — use `PRIMARY_INK`); hand-set tick labels or font sizes.

## seaborn (optional)

Not guaranteed installed — check `importlib.util.find_spec("seaborn")` before
importing. Replacements: `sns.despine` → `despine(ax)` (or just `finish_axes`);
`sns.color_palette("Set2")` → `palette_for(levels)`; `sns.stripplot` → jittered
`ax.scatter`; `mako`/`crest` → `viridis`. If seaborn *is* present: call
`apply_tufte()` after any `sns.set_*`, pass `palette=` explicitly, and still end
with `finish_axes(ax)`.

## You have failed this skill if

The figure has a title on a standalone panel, gridlines, tab10 colors, an
in-plot legend, **a tick label longer than 6 characters**, **four hues for a
numeric sweep**, **anything drawn over the data that was not asked for**, a
non-square data area on a square figure, **a single panel bigger than 4 in**,
**small-multiple panels with no visible gutter between them**, **an encoded
figure with no legend** (colour/marker/line style carries meaning but nothing
names the levels, and the user did not ask for no legend), or **a legend
physically overlapping the data or axes** — or if your reply describes the plot
back to the user.
