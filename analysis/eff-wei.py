import os
import sys
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import uproot
import uproot.exceptions
from common import DATA_DIR
from uproot.models import TH

colors, markers = common.setup_pyplot()

dataset = sys.argv[1]
DATA_DIR /= dataset

pair_data = {
    pair: sorted(
        [file for file in os.listdir(DATA_DIR / pair) if "-effcor-x.root" in file]
    )[:2]
    for pair in os.listdir(DATA_DIR)
    if os.path.isdir(DATA_DIR / pair)
}

fig = plt.figure(figsize=(6, 3), tight_layout=True)
gs = fig.add_gridspec(1, 2)


def parse_hist(hist: TH.Model_TH1F_v3 | TH.Model_TH1D_v3):
    counts, pt = hist.to_numpy()
    assert isinstance(pt, np.ndarray)

    vars = hist.variances()
    pt = pt[:-1]

    pt_cut = (0 < pt) & (pt < 4.2)
    pt = pt[pt_cut]
    counts = counts[pt_cut]
    vars = vars[pt_cut]

    return counts, np.sqrt(vars), pt


ax_eff = fig.add_subplot(gs[0])
ax_cor = fig.add_subplot(gs[1])

for pair, files in pair_data.items():
    for idx, file in enumerate(files):
        data = uproot.open(DATA_DIR / pair / file)
        assert isinstance(data, uproot.ReadOnlyDirectory)

        # -- efficiency
        hist_eff = data["hEfficiency"]
        assert isinstance(hist_eff, TH.Model_TH1D_v3)

        counts, errors, pts = parse_hist(hist_eff)

        ax_eff.errorbar(
            pts,
            counts,
            yerr=errors,
            fmt=".",
            markersize=6,
            label=f"${common.to_latex[pair.split('-')[idx]]}$",
        )

        ax_eff.set_title("(a)")
        ax_eff.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
        ax_eff.legend(title="Recon. efficiency")

        # -- weights
        hist_wei = data["hWeights"]
        assert isinstance(hist_wei, TH.Model_TH1D_v3)

        weights, weight_errors, pts = parse_hist(hist_wei)

        ax_cor.errorbar(
            pts,
            weights,
            yerr=weight_errors,
            fmt=".",
            markersize=6,
            label=f"${common.to_latex[pair.split('-')[idx]]}$",
        )

        ax_cor.set_title("(b)")
        ax_cor.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
        ax_cor.legend(title="Weights")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
