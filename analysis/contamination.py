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

fig = plt.figure(figsize=(6, 3), tight_layout=True)
gs = fig.add_gridspec(1, 2)


def parse_hist(hist: TH.Model_TH1D_v3) -> tuple[npt.NDArray, npt.NDArray]:
    counts, pt = hist.to_numpy()
    assert isinstance(pt, np.ndarray)

    pt = pt[:-1]

    pt_cut = (0 < pt) & (pt < 4.2)
    pt = pt[pt_cut]
    counts = counts[pt_cut]

    return counts, pt


for idx in range(2):
    data = uproot.open(DATA_DIR / f"EfficiencyCorrection{idx + 1}.root")
    assert isinstance(data, uproot.ReadOnlyDirectory)

    hist_sec = data["hSecondary"]
    assert isinstance(hist_sec, TH.Model_TH1D_v3)

    hist_fake = data["hFake"]
    assert isinstance(hist_fake, TH.Model_TH1D_v3)

    counts_sec, pt_sec = parse_hist(hist_sec)
    counts_fake, pt_fake = parse_hist(hist_fake)

    ax = fig.add_subplot(gs[idx])
    ax.plot(
        pt_sec,
        counts_sec * 100,
        ".",
        markersize=6,
        label="Secondary contamination",
    )
    ax.plot(
        pt_fake,
        counts_fake * 100,
        ".",
        markersize=6,
        markerfacecolor="none",
        label="Fake contamination",
    )

    ax.set_xlabel(r"$p_T [\text{GeV/c}]$")
    ax.set_ylabel(r"[\%]")
    ax.legend(title=f"Contamination - ${'-'.join(args.pair_tex)}$")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
