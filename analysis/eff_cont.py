import os
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import uproot
import uproot.exceptions
from common import DATA_DIR
from uproot.models import TH


def parse_hist(hist: TH.Model_TH1D_v3):
    counts, pt = hist.to_numpy()
    assert isinstance(pt, np.ndarray)

    vars = hist.variances()
    pt = pt[:-1]

    pt_cut = (0.5 < pt) & (pt < 4)
    pt = pt[pt_cut]
    counts = counts[pt_cut]
    vars = vars[pt_cut]

    return counts, np.sqrt(vars), pt


if __name__ == "__main__":
    colors, markers = common.setup_pyplot()

    fig = plt.figure(figsize=(6, 3), tight_layout=True)
    gs = fig.add_gridspec(1, 2)

    ax_eff = fig.add_subplot(gs[0])
    ax_cor = fig.add_subplot(gs[1])

    particles = 0

    datasets = [ds for ds in os.listdir(DATA_DIR) if os.path.isdir(DATA_DIR / ds)]
    for dataset in datasets:
        path = Path(DATA_DIR)
        path /= dataset
        path /= "effcor"

        pair_data = {
            particle: sorted(
                [  #
                    file  #
                    for file in os.listdir(path / particle)  #
                    if "-1d.root" in file
                ]
            )
            for particle in os.listdir(path)
            if os.path.isdir(path / particle)
        }

        for pair, files in pair_data.items():
            for idx, file in enumerate(files):
                particles += 1

                data = uproot.open(path / pair / file)
                assert isinstance(data, uproot.ReadOnlyDirectory)

                # -- efficiency
                hist_eff = data["hEfficiency"]
                assert isinstance(hist_eff, TH.Model_TH1D_v3)

                counts, errors, pts = parse_hist(hist_eff)

                ax_eff.errorbar(
                    pts,
                    counts,
                    yerr=errors,
                    markersize=1,
                    marker=markers[(particles - 1) % len(markers)],
                    linestyle="none",
                    label=f"${common.to_latex[pair.split('-')[idx]]}$",
                )

                # -- secondary contamination
                hist_sec = data["hSecondaryCont"]
                assert isinstance(hist_sec, TH.Model_TH1D_v3)

                sec_counts, sec_errs, pts = parse_hist(hist_sec)

                ax_cor.errorbar(
                    pts,
                    sec_counts,
                    yerr=sec_errs,
                    markersize=1,
                    marker=markers[(particles - 1) % len(markers)],
                    linestyle="none",
                    label=f"${common.to_latex[pair.split('-')[idx]]}$",
                )

    ax_eff.set_xticks(np.arange(0, 4.2, 1))

    ax_eff.set_title("(a)")
    ax_eff.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
    ax_eff.legend(title="Recon. efficiency")

    ax_cor.set_xticks(np.arange(0, 4.2, 1))

    ax_cor.set_title("(b)")
    ax_cor.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
    ax_cor.legend(title="Secondary cont.")

    fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
