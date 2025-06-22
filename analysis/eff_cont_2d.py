import sys
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import uproot
import uproot.exceptions
from common import DATA_DIR
from uproot.models import TH


def parse_hist(hist: TH.Model_TH2D_v4):
    vector = hist.to_numpy()
    assert len(vector) == 3

    counts, pt, eta = vector
    assert isinstance(pt, np.ndarray)
    assert isinstance(eta, np.ndarray)

    pt = pt[:-1]
    eta = eta[:-1]

    pt_cut = (0.5 < pt) & (pt < 4)
    pt = pt[pt_cut]

    counts = counts[pt_cut, :]

    return counts, pt, eta


def rebin_histogram(*, counts, pt_edges, eta_edges, pt_rebin, eta_rebin):
    pt_bins = len(pt_edges) - 1
    eta_bins = len(eta_edges) - 1

    new_pt_bins = pt_bins // pt_rebin
    new_eta_bins = eta_bins // eta_rebin

    rebinned_counts = counts[: new_pt_bins * pt_rebin, : new_eta_bins * eta_rebin]
    rebinned_counts = rebinned_counts.reshape(
        new_pt_bins, pt_rebin, new_eta_bins, eta_rebin
    )
    rebinned_counts = rebinned_counts.sum(axis=(1, 3))

    new_pt_edges = pt_edges[::pt_rebin][: new_pt_bins + 1]
    new_eta_edges = eta_edges[::eta_rebin][: new_eta_bins + 1]

    return rebinned_counts, new_pt_edges, new_eta_edges


if __name__ == "__main__":
    args = common.parse_args()

    if int(args.dim) == 1:
        sys.exit(0)

    colors, markers = common.setup_pyplot()

    DATA_DIR /= args.dataset
    DATA_DIR /= "effcor"

    colors, markers = common.setup_pyplot()

    part1, part2 = args.pair
    parts = 1 + (part1 != part2)

    for idx in range(parts):
        fig = plt.figure(figsize=(6, 3), tight_layout=True)
        gs = fig.add_gridspec(1, 2)

        ax_eff = fig.add_subplot(gs[0])
        ax_sec = fig.add_subplot(gs[1])

        path = Path(DATA_DIR)
        path /= args.pair[idx]
        path /= f"{args.nocor}-2d.root"

        try:
            data = uproot.open(path)
        except FileNotFoundError:
            continue

        assert isinstance(data, uproot.ReadOnlyDirectory)

        # -- efficiency
        hist_eff = data["hEfficiency"]
        assert isinstance(hist_eff, TH.Model_TH2D_v4)

        pt_rebin = 6
        eta_rebin = 1

        counts, pt_edges, eta_edges = parse_hist(hist_eff)
        counts_rebin, pt_edges_rebin, eta_edges_rebin = rebin_histogram(
            counts=counts,
            pt_edges=pt_edges,
            eta_edges=eta_edges,
            pt_rebin=pt_rebin,
            eta_rebin=eta_rebin,
        )
        X, Y = np.meshgrid(pt_edges_rebin, eta_edges_rebin, indexing="ij")
        pcm = ax_eff.pcolormesh(
            X,
            Y,
            counts_rebin,
            shading="auto",
            cmap="binary",
            edgecolors="none",
            linewidth=0,
            antialiased=False,
        )
        fig.colorbar(pcm, ax=ax_eff)

        # -- secondary contamination
        hist_sec = data["hSecondaryCont"]
        assert isinstance(hist_sec, TH.Model_TH2D_v4)

        sec_counts, _, _ = parse_hist(hist_sec)
        sec_counts_rebin, _, _ = rebin_histogram(
            counts=sec_counts,
            pt_edges=pt_edges,
            eta_edges=eta_edges,
            pt_rebin=pt_rebin,
            eta_rebin=eta_rebin,
        )
        sec_counts_rebin[sec_counts_rebin > 0.3] = np.nan
        X, Y = np.meshgrid(pt_edges_rebin, eta_edges_rebin, indexing="ij")
        pcm = ax_sec.pcolormesh(
            X,
            Y,
            sec_counts_rebin,
            shading="auto",
            cmap="binary",
            edgecolors="none",
            linewidth=0,
            antialiased=False,
        )
        fig.colorbar(pcm, ax=ax_sec)

        ax_eff.set_title("(a)")
        ax_eff.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
        ax_eff.set_ylabel(r"$\eta$")
        ax_eff.set_ylim(-1, 1)

        ax_sec.set_title("(b)")
        ax_sec.set_xlabel(r"$p_T\ [\text{GeV}/c]$")
        ax_sec.set_ylabel(r"$\eta$")
        ax_sec.set_ylim(-1, 1)

        fig.savefig(path.parent / f"{Path(__file__).stem}.pdf")
