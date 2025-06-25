import sys
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import uproot
import uproot.exceptions
from common import DATA_DIR
from uproot.models import TH


def parse_hist(hist: TH.Model_TH3D_v4) -> tuple[npt.NDArray, npt.NDArray]:
    counts, pt, *_ = hist.to_numpy()
    assert isinstance(pt, np.ndarray) and isinstance(counts, np.ndarray)
    pt = pt[:-1]

    pt_cut = (0 < pt) & (pt < 4.2)
    pt = pt[pt_cut]
    counts = counts.sum(axis=(1, 2))
    counts = counts[pt_cut]

    return counts, pt


if __name__ == "__main__":
    args = common.parse_args()

    colors, markers = common.setup_pyplot()

    pair = "-".join(args.pair)

    TASK_NAME = f"femto-universe-pair-task-track-track-extended_{pair}_nocor"
    DATA_DIR /= args.dataset
    DATA_DIR /= pair

    part1, part2 = args.pair
    parts = 1 + (part1 != part2)

    hist_names = [
        "hPrimary",
        "hSecondary",
        "hMaterial",
    ]

    part_name = ["one", "two"]

    data = uproot.open(DATA_DIR / f"{args.nocor}.root")
    assert isinstance(data, uproot.ReadOnlyDirectory)

    for idx in range(parts):
        fig = plt.figure(figsize=(3, 3), tight_layout=True)
        gs = fig.add_gridspec(1, 1)
        ax = fig.add_subplot(gs[0])

        hists = []
        bottom = None
        total_counts = None

        for hist_name in hist_names:
            try:
                hist = data[
                    f"{TASK_NAME}/EfficiencyCorrection/{part_name[idx]}/{hist_name}"
                ]
                assert isinstance(hist, TH.Model_TH3F_v4)
                counts, pt = parse_hist(hist)

                if total_counts is None:
                    total_counts = counts
                else:
                    total_counts += counts
            except uproot.exceptions.KeyInFileError:
                exit(0)

        assert total_counts is not None

        for hist_name in hist_names:
            hist = data[
                f"{TASK_NAME}/EfficiencyCorrection/{part_name[idx]}/{hist_name}"
            ]
            assert isinstance(hist, TH.Model_TH3F_v4)
            counts, pt = parse_hist(hist)

            if bottom is None:
                bottom = np.zeros_like(counts, dtype=counts.dtype)

            ratio = np.divide(
                counts,
                total_counts,
                out=np.zeros_like(counts, dtype=float),
                where=total_counts != 0,
            )
            ax.bar(
                pt,
                ratio * 100,
                align="edge",
                bottom=bottom * 100,
                label=hist_name[1:].lower(),
                alpha=0.6,
                width=pt[1] - pt[0],
            )

            bottom += ratio

        ax.legend(
            title=f"${args.pair_tex[idx]}$",
            loc="lower center",
            bbox_to_anchor=(0.5, 1.02),
            ncol=len(hist_names),
            fontsize=6,
        )
        ax.set_xlabel(r"$p_T [\text{GeV/c}]$")
        ax.set_ylabel(r"Contamination [%]")

        fig.savefig(DATA_DIR / f"{Path(__file__).stem}_{args.pair[idx]}.pdf")
