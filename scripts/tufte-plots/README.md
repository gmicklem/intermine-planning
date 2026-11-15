# tufte-plots

Minimal-ink matplotlib style: no chart junk over the data, sparse concise ticks, rank-ordered colour
for ordered levels, no titles, legends off the data area. `SKILL.md` has the rules; `style.py` the helpers.

## Use in plain Python (matplotlib ≥ 3.7)
```python
import sys; sys.path.insert(0, "path/to/tufte-plots")
from style import *
apply_tufte()          # sets rcParams; uses Adwaita Sans if installed, else Helvetica/Arial/Nimbus Sans
fig, ax = plt.subplots()
ax.plot([0, 1, 2], [1, 3, 2])
finish_axes(ax)        # despine + concise ticks
fig.savefig("plot.pdf")
```
The font is not bundled. Install Adwaita Sans (GNOME fonts) to match exactly; otherwise the
first available fallback in the stack is used.

## Use in Claude Science
Unzip into `<data dir>/orgs/<org>/skills/tufte-plots/` or ask Claude Science to add it as a skill.
