import os
import re
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

eff_corr_pattern = r"\d+-effcor-\d+\.root"
pair_data = {
    pair: sorted(
        [
            file
            for file in os.listdir(DATA_DIR / pair)
            if re.match(eff_corr_pattern, file)
        ]
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
        assert isinstance(hist_eff, TH.Model_TH1F_v3)

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

        # -- correction factor
        hist_sec = data["hDaughter"]
        hist_mat = data["hMaterial"]
        assert isinstance(hist_sec, TH.Model_TH1D_v3)
        assert isinstance(hist_mat, TH.Model_TH1D_v3)

        sec_counts, sec_errs, pts = parse_hist(hist_sec)
        mat_counts, mat_errs, _ = parse_hist(hist_mat)

        total_counts = sec_counts + mat_counts
        total_errors = np.sqrt(sec_errs**2 + mat_errs**2)

        ax_cor.errorbar(
            pts,
            total_counts,
            yerr=total_errors,
            fmt=".",
            markersize=6,
            label=f"${common.to_latex[pair.split('-')[idx]]}$",
        )

        ax_cor.set_title("(b)")
        ax_cor.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
        ax_cor.legend(title="Secondary cont.")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
