import sys
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


def get_particles(data):
    particles = dict()

    for pair in data:
        args = common.parse_args(pair.split(","))

        path = Path(DATA_DIR)
        path /= args.dataset
        path /= "effcor"

        part1, part2 = args.pair
        parts = 1 + (part1 != part2)

        for part in args.pair[:parts]:
            if part in particles:
                continue

            try:
                data = uproot.open(path / part / f"{args.nocor}-1d.root")
            except FileNotFoundError:
                continue

            assert isinstance(data, uproot.ReadOnlyDirectory)

            particles[part] = data

    return particles


if __name__ == "__main__":
    colors, markers = common.setup_pyplot()

    fig = plt.figure(figsize=(6, 3), tight_layout=True)
    gs = fig.add_gridspec(1, 2)

    ax_eff = fig.add_subplot(gs[0])
    ax_cor = fig.add_subplot(gs[1])

    particles = get_particles(sys.argv[1:])

    for idx, (part, data) in enumerate(particles.items()):
        # -- efficiency
        hist_eff = data["hEfficiency"]
        assert isinstance(hist_eff, TH.Model_TH1D_v3)

        counts, errors, pts = parse_hist(hist_eff)

        marker = list(markers.keys())[idx % len(markers)]
        ax_eff.errorbar(
            pts,
            counts,
            yerr=errors,
            markersize=markers[marker],
            marker=marker,
            linestyle="none",
            label=f"${common.to_latex[part]}$",
        )

        # -- secondary contamination
        hist_sec = data["hSecondaryCont"]
        assert isinstance(hist_sec, TH.Model_TH1D_v3)

        sec_counts, sec_errs, pts = parse_hist(hist_sec)

        ax_cor.errorbar(
            pts,
            sec_counts,
            yerr=sec_errs,
            markersize=markers[marker],
            marker=marker,
            linestyle="none",
            label=f"${common.to_latex[part]}$",
        )

    ax_eff.set_title("(a)")
    ax_eff.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
    ax_cor.set_xticks(np.arange(0, 4.2, 1))
    ax_eff.set_ylabel(r"Recon. efficiency $\varepsilon$")
    ax_eff.legend()

    ax_cor.set_title("(b)")
    ax_cor.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
    ax_cor.set_ylabel(r"Secondary cont. $C$")
    ax_cor.legend()

    fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
