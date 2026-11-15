"""Tufte-inspired plotting helpers for matplotlib.

The goal is one thing: **the data region is unencumbered by chart junk.** Every
helper here either removes non-data ink or makes the data easier to read.

Usage::

    from style import apply_tufte, palette_for, place_legend, finish_axes
    apply_tufte()
    fig, ax = plt.subplots(figsize=(4, 4))
    ...
    place_legend(ax)      # if there is a legend at all
    finish_axes(ax)       # LAST call on every dimensioned panel

INVARIANT -- do not break this: this module is ONE FILE depending on matplotlib
alone. No numpy, no pandas, no seaborn, and no ``matplotlib.pyplot`` at import
time (pyplot is imported lazily, only where an ``ax=None`` default needs it).
That is what makes ``cp style.py <repo>/scripts/`` a complete install on any
machine.
"""

from __future__ import annotations

import math
import os
import re
import warnings

import matplotlib as mpl
import matplotlib.ticker as mticker
from matplotlib import font_manager
from matplotlib.cm import ScalarMappable
from matplotlib.colors import LinearSegmentedColormap, LogNorm, Normalize, to_hex
from matplotlib.lines import Line2D

__version__ = "2.0.0"

__all__ = [
    # setup
    "apply_tufte", "available_font", "diagnostics",
    # finishing
    "finish_axes", "despine", "nice_ticks", "log_ticks", "ConciseFormatter",
    "embedding_axes", "categorical_ticks",
    # color
    "palette_for", "ordinal_colors", "use_colors", "level_legend",
    "continuous_norm", "add_colorbar",
    "categorical_palette", "two_color_palette", "callout_palette",
    "diverging_palette", "NOMINAL_EXTENDED", "SEQUENTIAL_CMAP", "BANNED_CMAPS",
    "PRIMARY_INK", "SECONDARY_INK",
    # legend / labels
    "place_legend", "label_lines_directly", "panel_label",
    # opt-in overlays (never volunteer these)
    "reference_line", "rug",
    # deprecated
    "range_frame",
]


# ---- Palettes ----------------------------------------------------------------

# Nominal, 3-4 levels: Paul Tol "high-contrast" (blue / gold / red) + neutral
# grey. Use ONLY for unordered categories -- species, methods, datasets.
categorical_palette = ["#004488", "#DDAA33", "#BB5566", "#999999"]

# Two-level peer comparison: Tol navy + Tol gold. Strong L* asymmetry so one
# color leads.
two_color_palette = ["#004488", "#DDAA33"]

# Two-level callout: highlight (Tol red) vs muted background. Use when one level
# is the protagonist of the analysis.
callout_palette = ["#BB5566", "#bcbcbc"]

# 5-8 nominal levels: Paul Tol "muted". Reconsider the chart before using it.
NOMINAL_EXTENDED = ["#332288", "#88CCEE", "#44AA99", "#117733",
                    "#DDCC77", "#CC6677", "#AA4499", "#882255"]

diverging_palette = LinearSegmentedColormap.from_list(
    "custom_diverging", ["#004488", "#FAFAFA", "#BB5566"],
)

# Sequential default. viridis ships with matplotlib -- seaborn's mako/crest do
# not, and this module must not assume seaborn is installed.
SEQUENTIAL_CMAP = "viridis"

BANNED_CMAPS = frozenset({
    "jet", "rainbow", "hsv", "turbo", "gist_rainbow", "nipy_spectral",
    "tab10", "tab20", "Set1", "flag", "prism",
})

PRIMARY_INK = "#000000"
SECONDARY_INK = "#bbbbbb"

# Trim points for sampling a continuous map: skip the near-black end (collides
# with PRIMARY_INK) and the pure-yellow end (invisible on white).
_CMAP_TRIM = {
    "viridis": (0.15, 0.90), "magma": (0.15, 0.85), "inferno": (0.15, 0.85),
    "plasma": (0.10, 0.90), "cividis": (0.10, 0.95),
    "Blues": (0.30, 0.95), "Greys": (0.30, 0.95), "Greens": (0.30, 0.95),
}

_FONT_STACK = ("Adwaita Sans", "Helvetica", "Helvetica Neue", "Arial", "Nimbus Sans",
               "Liberation Sans", "TeX Gyre Heros", "DejaVu Sans")

_ORDERED_VOCAB = (
    ("low", "medium", "high"), ("low", "med", "high"),
    ("none", "low", "moderate", "high", "severe"),
    ("small", "medium", "large"), ("s", "m", "l", "xl"),
    ("pre", "post"), ("before", "after"), ("baseline", "treated"),
    ("first", "second", "third"), ("early", "mid", "late"),
    ("mon", "tue", "wed", "thu", "fri", "sat", "sun"),
    ("q1", "q2", "q3", "q4"),
)

_NUMERIC_TOKEN = re.compile(r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?")

# Prefixes that name an identifier, not a quantity. "cluster 0/1/2" are three
# names that happen to be numbered; "day 3/7/14" is one axis sampled three
# times. Only the second gets a ramp.
_NOMINAL_ID_WORDS = frozenset({
    "cluster", "group", "class", "id", "sample", "subject", "patient", "batch",
    "replicate", "rep", "fold", "arm", "site", "seed", "run", "cell", "gene",
    "chr", "chrom", "lane", "well", "plate", "donor", "mouse", "subj",
})
_SUPER = str.maketrans("-0123456789", "⁻⁰¹²³⁴⁵⁶⁷⁸⁹")
_SCALE_SUFFIX = re.compile(r"\s*[,(]?\s*×10[⁻⁰¹²³⁴⁵⁶⁷⁸⁹]+\)?$")
_ENG = {-12: "p", -9: "n", -6: "µ", -3: "m", 0: "", 3: "k", 6: "M", 9: "G", 12: "T"}


# ---- setup -------------------------------------------------------------------

def available_font(preferred=_FONT_STACK) -> str:
    """First font family in `preferred` that is actually installed.

    Probing beats matplotlib's silent fallback: the fallback works, but it emits
    a ``findfont`` warning per text object and leaves no record of which family
    was used -- so a figure that looks wrong on a cluster is unexplainable.
    Set ``TUFTE_FONT`` to override, ``TUFTE_NO_FONT_PROBE=1`` to skip the probe.
    """
    override = os.environ.get("TUFTE_FONT")
    if override:
        return override
    if os.environ.get("TUFTE_NO_FONT_PROBE"):
        return preferred[-1]
    try:
        installed = {f.name for f in font_manager.fontManager.ttflist}
    except Exception:
        return preferred[-1]
    for name in preferred:
        if name in installed:
            return name
    return "DejaVu Sans"


def apply_tufte(font: str = "Adwaita Sans", *, verbose: bool = False) -> dict:
    """Apply the Tufte rcParams. Call once at script start.

    Returns a diagnostics dict (resolved font, backend, versions) so a run can
    say what it actually rendered with.
    """
    stack = (font,) + tuple(f for f in _FONT_STACK if f != font)
    resolved = available_font(stack)

    mpl.rcParams.update({
        # Typography
        "font.family": "sans-serif",
        "font.sans-serif": [resolved, "DejaVu Sans"],
        "font.size": 8,
        # Panel titles are subordinate to axis labels -- they name the subset,
        # they do not label a dimension. At the same 9pt they compete with the
        # axis labels for the eye; one step down settles the hierarchy.
        "axes.titlesize": 8,
        "figure.titlesize": 8,
        "axes.labelsize": 8,
        "xtick.labelsize": 5,
        "ytick.labelsize": 5,
        "legend.fontsize": 8,

        # Figure
        "figure.figsize": (4, 4),
        "figure.dpi": 140,
        "figure.facecolor": "white",
        "figure.constrained_layout.use": True,
        "figure.constrained_layout.h_pad": 0.04,
        "figure.constrained_layout.w_pad": 0.04,
        # Small multiples need a visible gutter or the panels read as one
        # continuous axis -- especially under sharey, where nothing sits
        # between them. These give a gap of roughly 15% of panel width;
        # matplotlib's 0.02 default gives 8%, which is not enough.
        "figure.constrained_layout.wspace": 0.10,
        "figure.constrained_layout.hspace": 0.12,

        # Save
        "savefig.dpi": 300,
        "savefig.bbox": "tight",
        "savefig.pad_inches": 0.02,
        "savefig.facecolor": "white",
        "savefig.transparent": False,
        "svg.fonttype": "none",
        "pdf.fonttype": 42,
        "ps.fonttype": 42,

        # Axes -- minimise non-data ink
        "axes.facecolor": "white",
        "axes.edgecolor": PRIMARY_INK,
        "axes.linewidth": 0.6,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.grid": False,
        "axes.titlepad": 6,
        "axes.labelcolor": PRIMARY_INK,
        "axes.prop_cycle": mpl.cycler(color=categorical_palette),
        # Defense in depth if finish_axes is skipped: no "+1.2e6" corner text.
        "axes.formatter.useoffset": False,
        "axes.formatter.use_mathtext": True,
        "axes.formatter.limits": (-3, 4),

        # Ticks
        "xtick.direction": "out",
        "ytick.direction": "out",
        "xtick.major.size": 3,
        "ytick.major.size": 3,
        "xtick.major.width": 0.6,
        "ytick.major.width": 0.6,
        "xtick.major.pad": 2,
        "ytick.major.pad": 2,
        "xtick.color": PRIMARY_INK,
        "ytick.color": PRIMARY_INK,
        "xtick.minor.visible": False,
        "ytick.minor.visible": False,

        # Lines / markers
        "lines.linewidth": 1.0,
        "lines.markersize": 3,
        "lines.solid_capstyle": "round",

        # Images
        "image.cmap": SEQUENTIAL_CMAP,

        # Legend -- frameless, placed off-plot by place_legend
        "legend.frameon": False,
        "legend.borderaxespad": 0.0,
        "legend.handlelength": 1.4,
        "legend.handletextpad": 0.5,
        "legend.labelspacing": 0.35,
        "legend.columnspacing": 1.2,

        # Text
        "text.color": PRIMARY_INK,
    })

    info = diagnostics(font_requested=font, font_resolved=resolved)
    if verbose:
        for k, v in info.items():
            print(f"{k:16s} {v}")
    return info


def diagnostics(font_requested: str = "Adwaita Sans", font_resolved: str | None = None) -> dict:
    """What this machine will actually render with."""
    return {
        "style_version": __version__,
        "mpl_version": mpl.__version__,
        "backend": mpl.get_backend(),
        "font_requested": font_requested,
        "font_resolved": font_resolved or available_font(),
        "font_rcparam": list(mpl.rcParams["font.sans-serif"])[:2],
    }


# ---- internals ---------------------------------------------------------------

def _resolve_ax(ax):
    if ax is not None:
        return ax
    import matplotlib.pyplot as plt  # lazy: keeps pyplot out of import time
    return plt.gca()


def _strip_zeros(s: str) -> str:
    if "." in s:
        s = s.rstrip("0").rstrip(".")
    return s or "0"


def _axis_is_categorical(axis) -> bool:
    if getattr(axis, "units", None) is not None:
        return True
    # `axis.converter` is deprecated in matplotlib 3.10; touching it warns.
    getter = getattr(axis, "get_converter", None)
    conv = getter() if callable(getter) else getattr(axis, "converter", None)
    if conv is not None:
        return True
    return isinstance(axis.get_major_formatter(), mticker.FixedFormatter)


def _axis_is_datetime(axis) -> bool:
    try:
        import matplotlib.dates as mdates
    except Exception:
        return False
    return isinstance(axis.get_major_locator(), mdates.DateLocator) or \
        isinstance(axis.get_major_formatter(), mdates.DateFormatter)


def _auto_nbins(ax, which: str) -> int:
    """Tick count from the axis's physical length: short panels get fewer.

    The 1.4 coefficient is calibrated, not guessed. MaxNLocator's `nbins` is an
    upper bound on *intervals*, and ticks landing outside the view are dropped,
    so a smaller number than you expect actually renders. At 1.2 a standard
    3.5in panel resolved to nbins=3, which on a 4.3-7.9 range leaves only two
    labelled ticks and strands the bottom of the axis. 1.4 puts that panel at 4
    (three to four visible ticks) while a 1.5in small-multiple panel still
    gets 2.
    """
    try:
        fig_w, fig_h = ax.figure.get_size_inches()
        pos = ax.get_position()
        length = pos.width * fig_w if which == "x" else pos.height * fig_h
    except Exception:
        length = 3.0
    return max(2, min(5, int(round(1.4 * length))))


def _superscript(exp: int) -> str:
    return str(exp).translate(_SUPER)


def _with_scale(label: str, exp: int) -> str:
    """Move a shared power of ten into the axis label, idempotently."""
    base = _SCALE_SUFFIX.sub("", label or "").rstrip()
    if not exp:
        return base
    suffix = f"×10{_superscript(exp)}"
    if base.endswith(")"):
        return f"{base[:-1]}, {suffix})"
    return f"{base} ({suffix})" if base else f"{suffix}"


# ---- tick formatting ---------------------------------------------------------

class ConciseFormatter(mticker.Formatter):
    """Short tick labels: fewest significant figures that still distinguish ticks.

    Implemented as a Formatter subclass rather than a frozen FuncFormatter
    because matplotlib calls ``set_locs`` before every draw -- so the precision
    decision re-derives itself if the limits change later, and calling
    ``set_xlim`` after ``finish_axes`` cannot resurrect long labels.
    """

    def __init__(self, *, sigfigs: int = 2, integer: bool | None = None,
                 factor: float = 1.0, eng: bool | None = None):
        self.sigfigs = sigfigs
        self._integer = integer
        self.factor = factor or 1.0
        self._eng = eng
        self._mode = "dec"
        self._dec = 2
        self._exp3 = 0

    def set_locs(self, locs):
        vals = [v / self.factor for v in locs if v is not None and math.isfinite(v)]
        if self.axis is not None:
            try:
                lo, hi = sorted(self.axis.get_view_interval())
                inside = [v for v in vals if lo - 1e-9 <= v * self.factor <= hi + 1e-9]
                vals = inside or vals
            except Exception:
                pass
        if not vals:
            return
        nz = [abs(v) for v in vals if v]
        amax = max(nz) if nz else 0.0
        uniq = sorted(set(vals))
        step = min((b - a for a, b in zip(uniq, uniq[1:])), default=abs(amax) or 1.0)
        step = abs(step) or (abs(amax) or 1.0)

        integer = self._integer
        if integer is None:
            integer = all(abs(v - round(v)) < 1e-9 for v in vals) and step >= 1 - 1e-9

        # Engineering suffixes only outside the comfortable decimal band --
        # EngFormatter would happily render 0.5 as "500m", which is worse.
        big_or_small = amax and (amax >= 1e4 or amax < 1e-3)
        use_eng = self._eng if self._eng is not None else bool(big_or_small)

        if use_eng and amax:
            exp3 = int(math.floor(math.log10(amax) / 3) * 3)
            self._exp3 = max(min(exp3, 12), -12)
            scaled_step = step / (10 ** self._exp3)
            self._mode = "eng"
            self._dec = _decimals(scaled_step, self.sigfigs)
        elif integer:
            self._mode = "int"
            self._dec = 0
        else:
            self._mode = "dec"
            self._dec = _decimals(step, self.sigfigs)

    def __call__(self, x, pos=None):
        v = x / self.factor
        if not math.isfinite(v):
            return ""
        if self._mode == "int":
            s = f"{v:.0f}"
        elif self._mode == "eng":
            s = _strip_zeros(f"{v / (10 ** self._exp3):.{self._dec}f}")
            if s not in ("0", "-0"):        # "0M" is noise; zero is just zero
                s += _ENG.get(self._exp3, "")
        else:
            s = _strip_zeros(f"{v:.{self._dec}f}")
        if s in ("-0", "-0.0"):
            s = "0"
        if mpl.rcParams.get("axes.unicode_minus", True):
            s = s.replace("-", "−")
        return s


def _decimals(step: float, sigfigs: int) -> int:
    if step <= 0 or not math.isfinite(step):
        return 1
    return int(max(0, min(6, sigfigs - 1 - math.floor(math.log10(step)))))


def nice_ticks(ax=None, axis: str = "both", *, nbins="auto", integer=None,
               scale_into_label: bool = True, sigfigs: int = 2, prune=None,
               steps=(1, 2, 2.5, 5, 10)) -> None:
    """Round tick positions and concise labels.

    Round positions are what make labels short *by construction*: 0, 0.5, 1
    instead of 0.031, 0.511, 0.990. Log axes delegate to :func:`log_ticks`;
    categorical and datetime axes are left alone.
    """
    ax = _resolve_ax(ax)
    sides = ("x", "y") if axis == "both" else (axis,)

    for side in sides:
        mpl_axis = ax.xaxis if side == "x" else ax.yaxis
        scale = ax.get_xscale() if side == "x" else ax.get_yscale()

        if scale == "log":
            log_ticks(ax, axis=side)
            continue
        if _axis_is_categorical(mpl_axis):
            continue        # words, not numbers -- see categorical_ticks
        if _axis_is_datetime(mpl_axis):
            continue        # matplotlib's date formatter already does this well
        if scale in ("symlog", "asinh"):
            mpl_axis.set_major_formatter(ConciseFormatter(sigfigs=sigfigs))
            continue

        n = _auto_nbins(ax, side) if nbins == "auto" else int(nbins)
        int_axis = bool(integer)
        use_steps = [1, 2, 5, 10] if int_axis else list(steps)
        # min_n_ticks=3, not 2: `nbins` bounds the number of *intervals*, and
        # ticks outside the view are dropped, so a range like 4.3-7.9 resolved
        # to just two labelled ticks (6, 8) and stranded the bottom of the axis.
        # Asking for three guarantees the axis stays anchored at both ends.
        loc = mticker.MaxNLocator(nbins=n, steps=use_steps, min_n_ticks=3,
                                  integer=int_axis, prune=prune)
        mpl_axis.set_major_locator(loc)

        _fix_degenerate(ax, side, mpl_axis, loc)

        factor = 1.0
        if scale_into_label:
            factor = _scale_into_label(ax, side, mpl_axis)

        mpl_axis.set_major_formatter(
            ConciseFormatter(sigfigs=sigfigs, integer=integer, factor=factor))


def _fix_degenerate(ax, side, mpl_axis, loc) -> None:
    """A near-constant range makes MaxNLocator emit the same tick three times.

    e.g. tick_values(0.3, 0.30000000000000004) -> [0.3, 0.3, 0.3], which then
    renders as 0.30000000000000004 once matplotlib gives up on shared digits.
    """
    lo, hi = (ax.get_xlim() if side == "x" else ax.get_ylim())
    if not (math.isfinite(lo) and math.isfinite(hi)):
        return
    ticks = [t for t in loc.tick_values(lo, hi) if lo - 1e-12 <= t <= hi + 1e-12]
    if len({round(t, 12) for t in ticks}) >= 2:
        return
    mid = (lo + hi) / 2.0
    pad = max(abs(mid) * 0.05, 1e-12)
    if side == "x":
        ax.set_xlim(mid - pad, mid + pad)
    else:
        ax.set_ylim(mid - pad, mid + pad)


def _scale_into_label(ax, side, mpl_axis) -> float:
    """Ticks in the millions belong as `Counts (×10⁶)`, not as 1200000 each.

    Returns the divisor the formatter should apply. Only engages when the axis
    already has a label -- otherwise the factor would vanish silently and the
    formatter's engineering suffix is the honest fallback.
    """
    label = mpl_axis.get_label_text()
    if not label:
        return 1.0
    lo, hi = (ax.get_xlim() if side == "x" else ax.get_ylim())
    amax = max(abs(lo), abs(hi))
    if not amax or not math.isfinite(amax) or 1e-3 <= amax < 1e4:
        mpl_axis.set_label_text(_with_scale(label, 0))     # strip a stale suffix
        return 1.0
    exp3 = int(math.floor(math.log10(amax) / 3) * 3)
    exp3 = max(min(exp3, 12), -12)
    if exp3 == 0:
        return 1.0
    mpl_axis.set_label_text(_with_scale(label, exp3))
    return float(10 ** exp3)


def log_ticks(ax=None, axis: str = "both", *, nbins: int = 4, minor: bool = True) -> None:
    """Decade ticks with power labels; faint minor ticks.

    Branches on how many decades are actually shown -- `10^0.3` is unreadable,
    so a sub-decade log axis gets ordinary numerals instead.
    """
    ax = _resolve_ax(ax)
    sides = ("x", "y") if axis == "both" else (axis,)
    for side in sides:
        mpl_axis = ax.xaxis if side == "x" else ax.yaxis
        lo, hi = (ax.get_xlim() if side == "x" else ax.get_ylim())
        if lo <= 0 or hi <= 0:
            continue
        span = math.log10(hi) - math.log10(lo)

        if span >= 2:
            stride = max(1, math.ceil(span / max(1, nbins)))
            mpl_axis.set_major_locator(
                mticker.LogLocator(base=10.0 ** stride, subs=(1.0,), numticks=nbins + 2))
            mpl_axis.set_major_formatter(mticker.LogFormatterSciNotation(labelOnlyBase=True))
        else:
            subs = (1.0, 2.0, 5.0) if span >= 0.7 else (1.0, 1.5, 2.0, 3.0, 5.0, 7.0)
            if span < 0.7:
                warnings.warn(
                    f"log {side}-axis spans only {span:.2f} decades -- a linear "
                    "axis is probably what you want here.", UserWarning, stacklevel=2)
            mpl_axis.set_major_locator(mticker.LogLocator(base=10.0, subs=subs, numticks=nbins + 2))
            mpl_axis.set_major_formatter(ConciseFormatter())

        if minor and span >= 1:
            mpl_axis.set_minor_locator(
                mticker.LogLocator(base=10.0, subs=tuple(range(2, 10)), numticks=50))
            mpl_axis.set_minor_formatter(mticker.NullFormatter())
            ax.tick_params(axis=side, which="minor", length=1.5, width=0.4)


# ---- finishing ---------------------------------------------------------------

def despine(ax=None, *, top: bool = True, right: bool = True, left: bool = False,
            bottom: bool = False, offset: float | None = None,
            trim: bool = False) -> None:
    """Hide spines. Native replacement for ``sns.despine`` -- seaborn is optional.

    `offset` moves the surviving spines outward by N points; `trim` clips them
    to the first and last tick.
    """
    ax = _resolve_ax(ax)
    for side, drop in (("top", top), ("right", right), ("left", left), ("bottom", bottom)):
        if drop:
            ax.spines[side].set_visible(False)
        elif offset:
            ax.spines[side].set_position(("outward", offset))
    if trim:
        for side, axis_obj, lim in (("bottom", ax.xaxis, ax.get_xlim()),
                                    ("left", ax.yaxis, ax.get_ylim())):
            if not ax.spines[side].get_visible():
                continue
            ticks = [t for t in axis_obj.get_majorticklocs()
                     if min(lim) <= t <= max(lim)]
            if len(ticks) >= 2:
                ax.spines[side].set_bounds(min(ticks), max(ticks))


def finish_axes(ax=None, *, x: bool = True, y: bool = True, nbins="auto",
                integer=None, scale_into_label: bool = True, sigfigs: int = 2,
                prune=None, box_aspect: float | None = 1.0,
                offset: float | None = None, trim: bool = False) -> None:
    """The closer. Call it last on every dimensioned panel.

    Does three things, all of which are otherwise forgotten:
      1. despines top and right,
      2. sets sparse round ticks with concise labels,
      3. squares the DATA AREA (`box_aspect`), which a square ``figsize`` does
         not do -- axis labels eat the difference, so a 3.5x3.5in figure with
         both labels lands at about 0.97:1.

    Idempotent. Pass ``box_aspect=3/5`` for the wide form, ``None`` to opt out
    (shared-axis mosaics, panels whose height the layout drives).
    """
    ax = _resolve_ax(ax)
    despine(ax, offset=offset, trim=trim)
    if x or y:
        which = "both" if (x and y) else ("x" if x else "y")
        nice_ticks(ax, axis=which, nbins=nbins, integer=integer,
                   scale_into_label=scale_into_label, sigfigs=sigfigs, prune=prune)
    if box_aspect is not None:
        ax.set_box_aspect(box_aspect)


def range_frame(ax, x=None, y=None) -> None:
    """DEPRECATED -- the range frame is no longer part of this style.

    Forwards to :func:`finish_axes`; `x` and `y` are ignored. Kept for one
    version so existing scripts keep running. Remove at 3.0.0.
    """
    warnings.warn(
        "range_frame() is deprecated and no longer draws a bounded frame; "
        "call finish_axes(ax) instead.", DeprecationWarning, stacklevel=2)
    finish_axes(ax)


def embedding_axes(ax=None, pad: float = 0.06, equal: bool = True) -> None:
    """Strip the frame from a dimensionless embedding (UMAP, t-SNE, PCA, MDS).

    Those coordinates have no units and no interpretable magnitude, so ticks and
    spines are non-data ink inviting the reader to compare meaningless numbers.
    Use this instead of :func:`finish_axes` on any such panel.

    Takes no label arguments on purpose: "UMAP 1" names an axis with no units
    and no meaningful direction. Say which embedding it is in the caption or a
    panel title.
    """
    ax = _resolve_ax(ax)
    ax.set_xticks([])
    ax.set_yticks([])
    for side in ("top", "right", "bottom", "left"):
        ax.spines[side].set_visible(False)
    ax.set_xlabel("")
    ax.set_ylabel("")
    if equal:
        # Distances must read the same in both directions, or the cloud lies.
        # adjustable="box" reshapes the axes box to honour the aspect;
        # adjustable="datalim" would instead overwrite the limits set below and
        # log "Ignoring fixed x limits to fulfill fixed data aspect", silently
        # discarding the padding.
        ax.set_aspect("equal", adjustable="box")
    if pad:
        # margins() survives autoscale and does not fight the aspect the way
        # explicit set_xlim/set_ylim does.
        ax.margins(pad)


def categorical_ticks(ax=None, axis: str = "x", *, rotation: float | None = None):
    """Style word tick labels at body size, rotating only when they need it.

    The 7pt tick default is calibrated for compact numerals; words need body
    size to read. If rotation still leaves them crowded, flip the plot
    horizontal instead (``orient="h"``, or swap x/y) -- level text reads faster
    than angled text.
    """
    ax = _resolve_ax(ax)
    body_size = mpl.rcParams["font.size"]
    sides = ("x", "y") if axis == "both" else (axis,)
    for side in sides:
        ax.tick_params(axis=side, labelsize=body_size)
        if side == "x":
            labels = ax.get_xticklabels()
            rot = rotation
            if rot is None:
                rot = 45 if any(len(t.get_text()) > 6 for t in labels) else 0
            if rot:
                for t in labels:
                    t.set_rotation(rot)
                    t.set_horizontalalignment("right")
        elif side == "y" and rotation is not None:
            for t in ax.get_yticklabels():
                t.set_rotation(rotation)


# ---- color -------------------------------------------------------------------

def _get_cmap(cmap):
    if isinstance(cmap, str):
        if cmap in BANNED_CMAPS:
            raise ValueError(
                f"{cmap!r} is banned by this style: it is not perceptually "
                f"uniform and not CVD-safe. Use {SEQUENTIAL_CMAP!r}.")
        return mpl.colormaps[cmap]
    return cmap


def ordinal_colors(levels, cmap=SEQUENTIAL_CMAP, *, lo: float | None = None,
                   hi: float | None = None, reverse: bool = False,
                   sort: bool = False):
    """Sample a continuous colormap UNIFORMLY BY RANK across ordered levels.

    For ordered or quantitative level sets: learning rates, doses, timepoints,
    k, epochs, quantiles, depths.

    By rank, not by value -- that is the whole point. Mapping
    ``[1e-4, 1e-3, 1e-2, 1e-1]`` by value crushes the first three into
    indistinguishable purples; by rank each step is equally visible.

    Returns ``(colors, {level: color})``.
    """
    levels = list(levels)
    if sort:
        levels = sorted(levels)
    n = len(levels)
    if n == 0:
        return [], {}

    cm = _get_cmap(cmap)
    name = getattr(cm, "name", "")
    d_lo, d_hi = _CMAP_TRIM.get(name, (0.10, 0.92))
    lo = d_lo if lo is None else lo
    hi = d_hi if hi is None else hi

    if n == 1:
        pos = [(lo + hi) / 2.0]
    else:
        pos = [lo + (hi - lo) * i / (n - 1) for i in range(n)]
    if reverse:
        pos = pos[::-1]

    colors = [to_hex(cm(p)) for p in pos]
    return colors, dict(zip(levels, colors))


def _looks_numeric(level) -> bool:
    """True only for things that are actually quantities.

    Deliberately strict about strings: "1e-4" read from a CSV header is a
    number, but "cluster 0" is a name that happens to contain a digit. Getting
    this wrong in the permissive direction is worse -- it would push nominal
    ids onto a ramp, which asserts an order that is not there.
    """
    if isinstance(level, bool):
        return False
    if isinstance(level, (int, float)):
        return True
    text = str(level).strip()
    try:
        float(text)
        return True
    except ValueError:
        pass
    # "k=8", "0.1x", "5 ms", "10%" -- a number wearing a unit.
    return bool(re.fullmatch(r"[A-Za-z]{1,4}\s*=\s*" + _NUMERIC_TOKEN.pattern, text)
                or re.fullmatch(_NUMERIC_TOKEN.pattern + r"\s*[a-zA-Zµ%]{1,3}", text))


def _split_prefix(text: str):
    """Split 'day 14' into ('day', 14.0). None if it is not prefix+number."""
    m = re.fullmatch(r"\s*([A-Za-z_ .-]*?)\s*(" + _NUMERIC_TOKEN.pattern + r")\s*", str(text))
    if not m:
        return None
    try:
        return m.group(1).strip().lower(), float(m.group(2))
    except ValueError:
        return None


def _infer_kind(levels) -> str:
    if all(_looks_numeric(x) for x in levels):
        return "quantitative"

    lowered = [str(x).strip().lower() for x in levels]
    for vocab in _ORDERED_VOCAB:
        if set(lowered) <= set(vocab) and len(lowered) > 1:
            return "ordinal"

    # A shared word prefix over distinct numbers -- "day 3 / day 7 / day 14".
    # Ordered, unless the prefix names an identifier rather than a quantity.
    parts = [_split_prefix(x) for x in levels]
    if len(levels) >= 3 and all(parts):
        prefixes = {p for p, _ in parts}
        values = [v for _, v in parts]
        if len(prefixes) == 1 and len(set(values)) == len(values):
            if prefixes.pop() not in _NOMINAL_ID_WORDS:
                return "ordinal"
    return "nominal"


def palette_for(levels, *, kind: str | None = None, cmap=SEQUENTIAL_CMAP,
                callout=None, lo: float | None = None, hi: float | None = None):
    """Pick colors from what the levels ARE. Returns ``(colors, {level: color})``.

    ============================  =========================================
    levels                        result
    ============================  =========================================
    1                             PRIMARY_INK -- nothing to distinguish
    2, peers                      two_color_palette
    2, one is the point           callout_palette (pass ``callout=<level>``)
    3-4 unordered names           categorical_palette
    ordered or numeric, any n     ordinal_colors -- a uniform ramp
    ============================  =========================================

    Raises if asked for a nominal palette on quantitative levels: a nominal
    palette asserts "these are different kinds", which throws away the ordering
    the reader needs.
    """
    levels = list(levels)
    if not levels:
        return [], {}
    inferred = _infer_kind(levels)
    if kind == "nominal" and inferred == "quantitative":
        # An explicit override is a caller who knows something we don't --
        # cluster 0/1/2 are names that happen to be numbers. Say so and comply.
        # The failure this guard exists to catch is the lazy path (reaching for
        # categorical_palette directly), not a deliberate, stated choice.
        warnings.warn(
            f"levels look quantitative ({levels[:4]}...) but kind='nominal' was "
            "requested, so the ordering will not be encoded. Correct for ids "
            "like cluster 0/1/2; use ordinal_colors(levels) for a real sweep.",
            UserWarning, stacklevel=2)
    kind = kind or inferred

    if kind in ("quantitative", "ordinal"):
        return ordinal_colors(levels, cmap, lo=lo, hi=hi)

    n = len(levels)
    if n == 1:
        colors = [PRIMARY_INK]
    elif n == 2:
        if callout is not None:
            ordered = ([callout] + [x for x in levels if x != callout]
                       if callout in levels else levels)
            return list(callout_palette), dict(zip(ordered, callout_palette))
        colors = list(two_color_palette)
    elif n <= 4:
        colors = categorical_palette[:n]
    elif n <= 8:
        warnings.warn(
            f"{n} nominal categories is more than a reader can track at once -- "
            "consider small multiples instead of one crowded panel.",
            UserWarning, stacklevel=2)
        colors = NOMINAL_EXTENDED[:n]
    else:
        raise ValueError(
            f"{n} nominal categories cannot be distinguished by color. Use small "
            "multiples, or aggregate the tail into an 'other' level.")
    return colors, dict(zip(levels, colors))


def use_colors(ax, colors) -> None:
    """Set the axes' color cycle, so plain plot() calls pick up the palette."""
    _resolve_ax(ax).set_prop_cycle(color=list(colors))


def level_legend(ax=None, mapping: dict | None = None, *, marker: str = "o",
                 line: bool = True, title: str | None = None, **kwargs):
    """Legend built from a ``{level: color}`` mapping, placed off-plot.

    Use with :func:`ordinal_colors` when the levels are few enough to name; use
    :func:`add_colorbar` when the value is genuinely continuous.
    """
    ax = _resolve_ax(ax)
    mapping = mapping or {}
    handles = [
        Line2D([], [], color=c, marker="" if line else marker,
               linestyle="-" if line else "none",
               markersize=4, linewidth=1.0, label=str(k))
        for k, c in mapping.items()
    ]
    return place_legend(ax, handles=handles, labels=[str(k) for k in mapping],
                        title=title, **kwargs)


def continuous_norm(values=None, *, vmin=None, vmax=None, log: bool = False,
                    robust: bool = False):
    """Normalize (or LogNorm) for continuous color. `robust` trims to 2nd/98th pct."""
    if values is not None and (vmin is None or vmax is None):
        vals = sorted(float(v) for v in values if v is not None and math.isfinite(float(v)))
        if vals:
            if robust:
                k = max(0, int(0.02 * (len(vals) - 1)))
                lo_v, hi_v = vals[k], vals[-1 - k]
            else:
                lo_v, hi_v = vals[0], vals[-1]
            vmin = lo_v if vmin is None else vmin
            vmax = hi_v if vmax is None else vmax
    return LogNorm(vmin=vmin, vmax=vmax) if log else Normalize(vmin=vmin, vmax=vmax)


def add_colorbar(ax=None, values=None, *, cmap=SEQUENTIAL_CMAP, norm=None,
                 log: bool = False, label: str = "", nbins: int = 3,
                 fraction: float = 0.035, pad: float = 0.02, **kwargs):
    """Thin, frameless colorbar for a genuinely continuous per-point value."""
    ax = _resolve_ax(ax)
    norm = norm or continuous_norm(values, log=log)
    sm = ScalarMappable(norm=norm, cmap=_get_cmap(cmap))
    sm.set_array([])
    cb = ax.figure.colorbar(sm, ax=ax, fraction=fraction, pad=pad, aspect=30, **kwargs)
    cb.outline.set_visible(False)
    cb.ax.tick_params(size=2, width=0.6, pad=2,
                      labelsize=mpl.rcParams["ytick.labelsize"])
    if log:
        cb.ax.yaxis.set_major_locator(mticker.LogLocator(base=10.0, subs=(1.0,)))
        cb.ax.yaxis.set_major_formatter(mticker.LogFormatterSciNotation(labelOnlyBase=True))
    else:
        cb.ax.yaxis.set_major_locator(
            mticker.MaxNLocator(nbins=nbins, steps=[1, 2, 2.5, 5, 10]))
        cb.ax.yaxis.set_major_formatter(ConciseFormatter())
    if label:
        cb.set_label(label, size=mpl.rcParams["axes.labelsize"])
    return cb


# ---- legend / direct labels --------------------------------------------------

def place_legend(ax=None, labels=None, handles=None, *, side: str = "auto",
                 ncol: int | None = None, in_layout: bool | None = None,
                 long_labels: bool | None = None, **kwargs):
    """Place the legend off-plot, BELOW the panel by default.

    Below costs height; the right-hand column costs width, and under
    constrained_layout a right-side legend can squeeze the panel to about half
    the figure width. Pass ``side="right"`` when labels are too long to lay out
    horizontally.
    """
    ax = _resolve_ax(ax)
    auto_handles, auto_labels = ax.get_legend_handles_labels()
    handles = handles if handles is not None else auto_handles
    labels = labels if labels is not None else auto_labels
    if not labels:
        return None

    if side == "auto":
        # `long_labels` is the pre-2.0 spelling; honour it, but below still wins
        # unless the labels genuinely cannot sit side by side.
        crowded = sum(len(str(x)) for x in labels) > 60 or len(labels) > 6
        if long_labels is True:
            crowded = crowded or max(len(str(x)) for x in labels) > 24
        side = "right" if crowded else "below"

    if ncol is None:
        ncol = 1 if side == "right" else min(len(labels), 3 if len(labels) > 2 else 2)

    if side == "right":
        leg = ax.legend(handles, labels, loc="center left",
                        bbox_to_anchor=(1.02, 0.5), ncol=1, frameon=False, **kwargs)
    else:
        leg = ax.legend(handles, labels, loc="upper center",
                        bbox_to_anchor=(0.5, -0.16), ncol=ncol, frameon=False, **kwargs)

    if in_layout is None:
        # Always True. set_in_layout(False) looks tempting -- it stops
        # constrained_layout from shrinking the axes -- but savefig's
        # bbox_inches="tight" measures with get_tightbbox(), which SKIPS artists
        # that are out of layout. The legend then renders into the SVG markup
        # outside the viewBox and silently vanishes from the saved file.
        in_layout = True
    leg.set_in_layout(bool(in_layout))
    return leg


def label_lines_directly(ax=None, x_positions: dict | None = None,
                         color_by_label: bool = True, dx: float = 0.0):
    """Label lines at a chosen x instead of spending a legend.

    This is a relocation of ink the figure already spends, not an addition --
    the one labelling that does not count as an unrequested overlay.
    """
    ax = _resolve_ax(ax)
    lines = {l.get_label(): l for l in ax.get_lines()}
    for label, x in (x_positions or {}).items():
        line = lines.get(label)
        if line is None:
            continue
        xs, ys = list(line.get_xdata()), list(line.get_ydata())
        if not xs:
            continue
        idx = min(range(len(xs)), key=lambda i: abs(xs[i] - x))
        color = line.get_color() if color_by_label else PRIMARY_INK
        ax.annotate(label, xy=(xs[idx], ys[idx]), xytext=(xs[idx] + dx, ys[idx]),
                    color=color, va="center", ha="left")


# ---- opt-in overlays ---------------------------------------------------------
# Never volunteer these. They put ink on top of the data, which is the user's
# call to make, not yours.

def reference_line(ax=None, value: float = 0.0, axis: str = "y",
                   label: str | None = None):
    """OPT-IN ONLY. A light reference line, for when the user asked for one.

    Do not add a baseline, threshold, or mean line the user did not request.
    """
    ax = _resolve_ax(ax)
    if axis == "y":
        ax.axhline(value, color=SECONDARY_INK, linewidth=0.6, zorder=0)
        if label:
            ax.text(ax.get_xlim()[1], value, f" {label}", color=SECONDARY_INK,
                    va="center", ha="left", fontsize=mpl.rcParams["xtick.labelsize"])
    else:
        ax.axvline(value, color=SECONDARY_INK, linewidth=0.6, zorder=0)
        if label:
            ax.text(value, ax.get_ylim()[1], label, color=SECONDARY_INK,
                    va="bottom", ha="center", fontsize=mpl.rcParams["xtick.labelsize"])


def rug(ax=None, x=None, y=None, color=None, height: float = 0.015,
        alpha: float = 1.0, linewidth: float = 0.5):
    """OPT-IN ONLY. Tick marks in the axis margin showing where the data sit.

    `height` is a fraction of the axis length, drawn with a blended transform so
    it stays put when the limits change.
    """
    import matplotlib.transforms as mtransforms
    ax = _resolve_ax(ax)
    color = color or PRIMARY_INK
    if x is not None:
        tr = mtransforms.blended_transform_factory(ax.transData, ax.transAxes)
        for xi in x:
            ax.plot([xi, xi], [0, height], transform=tr, color=color,
                    linewidth=linewidth, alpha=alpha, clip_on=False, zorder=1)
    if y is not None:
        tr = mtransforms.blended_transform_factory(ax.transAxes, ax.transData)
        for yi in y:
            ax.plot([0, height], [yi, yi], transform=tr, color=color,
                    linewidth=linewidth, alpha=alpha, clip_on=False, zorder=1)


def panel_label(ax, letter, *, x=-0.02, y=1.07, fontsize=None, color=None):
    """Draw a bold panel letter (a, b, c, ...) at axes-fraction (x, y).

    Panel letters are the one place the house style uses bold: they index
    the figure, they do not label a data dimension. Weight is requested via
    ``fontweight="bold"`` first; if the active family exposes no bold face
    (matplotlib silently falls back to weight 400 and warns), a proportional
    synthetic-bold stroke is added so the letter reads as bold regardless of
    the font's available faces.
    """
    import matplotlib as mpl
    import matplotlib.patheffects as pe
    from matplotlib import font_manager as fm

    color = color or PRIMARY_INK
    fs = fontsize if fontsize is not None else mpl.rcParams["font.size"]
    t = ax.text(x, y, letter, transform=ax.transAxes, fontweight="bold",
                fontsize=fs, color=color, va="top", ha="right")

    # Does the resolved family actually have a heavier face than regular?
    fam = mpl.rcParams["font.sans-serif"][0] if mpl.rcParams["font.family"] == ["sans-serif"] \
          or mpl.rcParams["font.family"] == "sans-serif" else None
    has_bold = False
    if fam:
        try:
            reg = fm.findfont(fm.FontProperties(family=fam, weight="normal"))
            bold = fm.findfont(fm.FontProperties(family=fam, weight="bold"))
            has_bold = reg != bold
        except Exception:
            has_bold = False
    if not has_bold:
        # synthetic bold: stroke ~8% of the cap height in the fill colour
        t.set_path_effects([pe.withStroke(linewidth=max(0.4, fs * 0.08),
                                          foreground=color)])
    return t


if __name__ == "__main__":
    import json
    print(json.dumps(apply_tufte(), indent=2))
