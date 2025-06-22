import os
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import uproot
import uproot.exceptions
from common import DATA_DIR
from eff_cont_1d import parse_hist
from uproot.models import TH

if __name__ == "__main__":
    colors, markers = common.setup_pyplot()

    fig = plt.figure(figsize=(4, 3), tight_layout=True)
    gs = fig.add_gridspec(1, 1)
    ax = fig.add_subplot(gs[0])

    particles = 0
    datasets = [
        dataset
        for dataset in os.listdir(DATA_DIR)
        if os.path.isdir(DATA_DIR / dataset) and dataset.startswith("LHC")
    ]
    for dataset in datasets:
        path = DATA_DIR
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

        for part, files in pair_data.items():
            for idx, file in enumerate(files):
                particles += 1

                data = uproot.open(path / part / file)
                assert isinstance(data, uproot.ReadOnlyDirectory)

                hist_eff = data["hWeights"]
                assert isinstance(hist_eff, TH.Model_TH1D_v3)

                counts, errors, pts = parse_hist(hist_eff)

                marker = list(markers.keys())[(particles - 1) % len(markers)]

                ax.errorbar(
                    pts,
                    counts,
                    yerr=errors,
                    markersize=markers[marker],
                    marker=marker,
                    linestyle="none",
                    label=f"${common.to_latex[part.split('-')[idx]]}$",
                )

    ax.set_xticks(np.arange(0, 4.2, 1))
    ax.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
    ax.set_ylabel("Weight $w$")

    ax.legend(
        loc="center left",
        bbox_to_anchor=(1.0, 0.5),
        ncols=1,
    )

    fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
