from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import uproot
import uproot.exceptions
from common import DATA_DIR
from uproot.models import TH

args = common.parse_args()
colors, markers = common.setup_pyplot()

pair = "-".join(args.pair)

DATA_DIR /= args.dataset
DATA_DIR /= pair
TASK_NAME = f"femto-universe-pair-task-track-track-extended_{pair}_nocor"

data = uproot.open(DATA_DIR / f"{args.nocor}.root")
assert isinstance(data, uproot.ReadOnlyDirectory)

particle_types = [
    "primary",
    "secondary",
    "material",
    "not primary",
    "fake",
    "wrong collision",
    "other",
]

fig = plt.figure(figsize=(6, 3), tight_layout=True)
gs = fig.add_gridspec(1, 2)

for idx, part in enumerate(["one", "two"]):
    try:
        hist_origin = data[f"{TASK_NAME}/Tracks_{part}_MC/hOrigin_MC"]
    except uproot.exceptions.KeyInFileError:
        continue

    assert isinstance(hist_origin, TH.Model_TH1I_v3)

    counts, pt = hist_origin.to_numpy()
    assert isinstance(pt, np.ndarray)

    counts = counts[:-6]
    pt = pt[:-7]

    counts[-6] += counts[-7:].sum()

    ax = fig.add_subplot(gs[idx])

    ax.bar(pt, counts)
    ax.bar(pt[0], counts[0])
    ax.set_xlim(-0.5, 6.5)

    ax.set_xticks(range(len(particle_types)), particle_types)
    ax.set_xticklabels(
        ax.get_xticklabels(),
        rotation=45,
        ha="right",
        rotation_mode="anchor",
    )
    ax.minorticks_off()

    ax.set_xlabel("Particle origin")
    ax.set_ylabel("Entries")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
