import sys
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import uproot
import uproot.exceptions
from common import DATA_DIR
from eff_cont_1d import get_particles, parse_hist
from uproot.models import TH

if __name__ == "__main__":
    colors, markers = common.setup_pyplot()

    fig = plt.figure(figsize=(4, 3), tight_layout=True)
    gs = fig.add_gridspec(1, 1)
    ax = fig.add_subplot(gs[0])

    particles = get_particles(sys.argv[1:])

    for idx, (part, data) in enumerate(particles.items()):
        hist_eff = data["hWeights"]
        assert isinstance(hist_eff, TH.Model_TH1D_v3)

        counts, errors, pts = parse_hist(hist_eff)

        marker = list(markers.keys())[idx % len(markers)]

        ax.errorbar(
            pts,
            counts,
            yerr=errors,
            markersize=markers[marker],
            marker=marker,
            linestyle="none",
            label=f"${common.to_latex[part]}$",
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
