from pathlib import Path
from typing import Any, cast

import matplotlib.pyplot as plt
import numpy.typing as npt
import uproot
from uproot.models import TH

import common
from common import DATA_DIR

args = common.parse_args()
colors, markers = common.setup_pyplot()

TASK_NAME = "femto-universe-pair-task-track-track-extended"
DATA_DIR /= args.dataset
DATA_DIR /= args.pair


def projection(
    file: uproot.ReadOnlyDirectory,
) -> tuple[npt.NDArray, npt.NDArray, npt.NDArray]:
    same_event = file[TASK_NAME + "/SameEvent_MC/DeltaEtaDeltaPhi"]
    mixed_event = file[TASK_NAME + "/MixedEvent_MC/DeltaEtaDeltaPhi"]

    assert isinstance(same_event, TH.Model_TH2F_v4)
    assert isinstance(mixed_event, TH.Model_TH2F_v4)

    same_event, phi, eta = cast(
        tuple[npt.NDArray[Any], Any, Any], same_event.to_numpy()
    )
    mixed_event, *_ = mixed_event.to_numpy()

    # TODO: errorbars
    # print(same_event.variances())

    proj_num = same_event.sum(axis=1)
    proj_den = mixed_event.sum(axis=1)

    proj_num /= proj_num.sum()
    proj_den /= proj_den.sum()

    scale = proj_den.sum() / proj_num.sum()
    ratio = proj_num / proj_den
    ratio *= scale

    return ratio, phi, eta


data_nocor = uproot.open(DATA_DIR / f"{args.nocor}_nocor.root")
data_cor = uproot.open(DATA_DIR / f"{args.cor}_cor.root")

assert isinstance(data_nocor, uproot.ReadOnlyDirectory)
assert isinstance(data_cor, uproot.ReadOnlyDirectory)

proj_nocor, phi, eta = projection(data_nocor)
phi = phi[:-1]
proj_cor, *_ = projection(data_cor)

fig = plt.figure(figsize=(5, 5), tight_layout=True)
gs = fig.add_gridspec(2, 1, height_ratios=[3, 2])

top = fig.add_subplot(gs[0])

top.plot(
    phi,
    proj_nocor,
    "o",
    label="Recon. w/o corrections",
)
top.plot(
    phi,
    proj_cor,
    "o",
    markerfacecolor="none",
    label="Recon. w/ corrections",
)
top.set_ylabel(r"$C(\Delta\varphi)$")
top.legend(title=f"Correlation function - {args.pair_tex}")

bot = fig.add_subplot(gs[1], sharex=top)
plt.setp(top.get_xticklabels(), visible=False)

ratio = proj_cor / proj_nocor
bot.plot(
    phi,
    ratio,
    "_",
    color=colors[0],
)
for xi, yi in zip(phi, ratio):
    bot.plot(
        [xi, xi],
        [1, yi],
        color=colors[2] if yi > 1 else colors[0],
        linestyle="-",
    )

bot.axhline(1, color=colors[0], linestyle="-", linewidth=0.3)
bot.set_xlabel(r"$\Delta\varphi$")
bot.set_ylabel("Ratio (w/ over w/o)")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}-{args.cor}-{args.nocor}.pdf")
