import matplotlib.pyplot as plt
import uproot
from uproot.models import TH

import common
from common import DATA_DIR

args = common.parse_args()
colors, markers = common.setup_pyplot()

TASK_NAME = "femto-universe-pair-task-track-track-extended"
DATA_DIR /= args.dataset
DATA_DIR /= args.pair

eff = uproot.open(DATA_DIR / f"{args.eff}_eff.root")["ccdb_object"]
assert isinstance(eff, TH.Model_TH1F_v3)

counts, pt = eff.to_numpy()
pt = pt[:-1]

fig = plt.figure(figsize=(4, 3), tight_layout=True)
ax = fig.add_subplot()

ax.plot(
    pt,
    counts,
    ".-",
    color=colors[2],
    label=f"Efficiency - {args.pair_tex}",
)

ax.set_xlabel(r"$p_T [\text{GeV/c}]$")
ax.set_xlim(0, 4.2)
ax.legend()

fig.savefig(DATA_DIR / f"efficiency-{args.eff}.pdf")
