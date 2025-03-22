import os
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import uproot
import uproot.exceptions
from common import DATA_DIR
from uproot.models import TH

args = common.parse_args()
colors, markers = common.setup_pyplot()

DATA_DIR /= args.dataset
DATA_DIR /= "-".join(args.pair)

files = [
    file
    for file in os.listdir(DATA_DIR)
    if file.startswith("EfficiencyCorrection") and file.endswith(".root")
]

fig = plt.figure(figsize=(4, 3), tight_layout=True)
# gs = fig.add_gridspec(1, 2)
ax = fig.add_subplot()

for idx, file in enumerate(files):
    data = uproot.open(DATA_DIR / file)
    assert isinstance(data, uproot.ReadOnlyDirectory)

    hist_eff = data["hEfficiency"]
    assert isinstance(hist_eff, TH.Model_TH1F_v3)

    counts, pt = hist_eff.to_numpy()
    assert isinstance(pt, np.ndarray)

    pt = pt[:-1]

    pt_cut = (0 < pt) & (pt < 4.2)
    pt = pt[pt_cut]
    counts = counts[pt_cut]

    ax.plot(
        pt,
        counts * 100,
        ".",
        markersize=6,
        markerfacecolor="none" if idx == 1 else None,
        label=f"${args.pair_tex[idx]}$",
    )

    ax.set_xlabel(r"$p_T [\text{GeV/c}]$")
    ax.set_ylabel(r"[\%]")
    ax.legend(title="Recon. efficiency")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
