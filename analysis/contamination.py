import os
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
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
    if "-effcor-" in file and file.endswith(".root")
][:2]

if len(files) == 0:
    exit(0)

fig = plt.figure(figsize=(3 * len(files), 3), tight_layout=True)
gs = fig.add_gridspec(1, len(files))


def parse_hist(
    hist: TH.Model_TH1D_v3 | TH.Model_TH1F_v3,
) -> tuple[npt.NDArray, npt.NDArray]:
    counts, pt = hist.to_numpy()
    assert isinstance(pt, np.ndarray)

    pt = pt[:-1]

    pt_cut = (0 < pt) & (pt < 4.2)
    pt = pt[pt_cut]
    counts = counts[pt_cut]

    return counts, pt


hist_names = [
    "hPrimary",
    "hDaughter",
    "hMaterial",
    "hFake",
]

for idx, file in enumerate(files):
    data = uproot.open(DATA_DIR / file)
    assert isinstance(data, uproot.ReadOnlyDirectory)

    ax = fig.add_subplot(gs[idx])
    hists = []
    bottom = None

    for hist_name in hist_names:
        hist = data[hist_name]
        assert isinstance(hist, TH.Model_TH1D_v3)
        counts, pt = parse_hist(hist)

        if bottom is None:
            bottom = np.zeros_like(counts, dtype=counts.dtype)

        ax.bar(
            pt,
            counts * 100,
            align="edge",
            bottom=bottom * 100,
            label=hist_name[1:].lower(),
            alpha=0.6,
            width=pt[1] - pt[0],
        )

        bottom += counts

    ax.legend(
        title=f"Contamination - ${args.pair_tex[idx]}$",
        loc="lower center",
        bbox_to_anchor=(0.5, 1.02),
        ncol=len(hist_names),
        fontsize=6,
    )
    ax.set_xlabel(r"$p_T [\text{GeV/c}]$")
    ax.set_ylabel(r"[\%]")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
