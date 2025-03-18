from pathlib import Path
from typing import Any

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

TASK_NAME = "femto-universe-pair-task-track-track-extended"
DATA_DIR /= args.dataset
DATA_DIR /= "-".join(args.pair)

particles = ["one", "two"]

data = uproot.open(DATA_DIR / f"{args.nocor}.root")
assert isinstance(data, uproot.ReadOnlyDirectory)

fig = plt.figure(figsize=(4, 3), tight_layout=True)
# gs = fig.add_gridspec(1, 2)
ax = fig.add_subplot()


def parse_hist(hist: TH.Model_TH1F_v3) -> tuple[npt.NDArray[Any], npt.NDArray[Any]]:
    counts, pt = hist.to_numpy()
    assert isinstance(pt, np.ndarray)

    pt = pt[:-1]

    pt_cut = (0 < pt) & (pt < 4.2)
    pt = pt[pt_cut]
    counts = counts[pt_cut]

    assert pt.size == counts.size
    return counts, pt


for idx in range(2):
    path = DATA_DIR / f"{args.eff}.root"

    try:
        hist_reco = data[TASK_NAME + f"/Tracks_{particles[idx]}_MC/hPt"]
        hist_truth = data[TASK_NAME + f"/MCTruthTracks_{particles[idx]}/hPt"]
    except uproot.exceptions.KeyInFileError:
        continue

    assert isinstance(hist_reco, TH.Model_TH1F_v3)
    assert isinstance(hist_truth, TH.Model_TH1F_v3)

    reco, pt_reco = parse_hist(hist_reco)
    truth, pt_truth = parse_hist(hist_truth)

    # ensure that bins match
    assert pt_reco.size == pt_truth.size
    assert np.isclose(pt_reco[0], pt_truth[0])
    assert np.isclose(pt_reco[pt_reco.size // 2], pt_truth[pt_truth.size // 2])
    assert np.isclose(pt_reco[-1], pt_truth[-1])

    eff = reco / truth
    eff[np.isinf(eff)] = 0

    ax.plot(
        pt_reco,
        eff * 100,
        ".",
        markersize=6,
        markerfacecolor="none" if idx == 1 else None,
        label=f"${args.pair_tex[idx]}$",
    )

    ax.set_xlabel(r"$p_T [\text{GeV/c}]$")
    ax.set_ylabel(r"[\%]")
    ax.legend(title="Recon. efficiency")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
