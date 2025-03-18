from pathlib import Path
from typing import Any

import common
import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import uproot
from common import DATA_DIR
from uproot.models import TH

args = common.parse_args()
colors, markers = common.setup_pyplot()

TRUTH_TASK_NAME = "femto-universe-pair-task-track-track-mc-truth"
TASK_NAME = "femto-universe-pair-task-track-track-extended"
DATA_DIR /= args.dataset
DATA_DIR /= "-".join(args.pair)


def project(hist: TH.Model_TH2F_v4) -> tuple[npt.NDArray, Any, Any]:
    hist_np = hist.to_numpy()
    assert len(hist_np) == 3

    signal, phi, eta = hist_np

    # TODO: errorbars
    # print(same_event.variances())

    proj = signal.sum(axis=1)
    proj /= proj.sum()

    return proj, phi, eta


def corr_func(
    file: uproot.ReadOnlyDirectory,
    path_same: str,
    path_mixed: str,
) -> tuple[npt.NDArray, npt.NDArray, npt.NDArray]:
    same_event = file[path_same]
    mixed_event = file[path_mixed]

    assert isinstance(same_event, TH.Model_TH2F_v4)
    assert isinstance(mixed_event, TH.Model_TH2F_v4)

    proj_num, same_phi, same_eta = project(same_event)
    proj_den, mixed_phi, mixed_eta = project(mixed_event)

    assert same_phi.shape == mixed_phi.shape
    assert np.isclose(same_phi[0], mixed_phi[0])
    assert np.isclose(same_phi[-1], mixed_phi[-1])

    assert same_eta.shape == mixed_eta.shape
    assert np.isclose(same_eta[0], mixed_eta[0])
    assert np.isclose(same_eta[-1], mixed_eta[-1])

    scale = proj_den.sum() / proj_num.sum()
    corr = proj_num / proj_den
    corr *= scale

    return corr, same_phi, same_eta


data_nocor = uproot.open(DATA_DIR / f"{args.nocor}.root")
data_cor = uproot.open(DATA_DIR / f"{args.cor}.root")
data_truth = uproot.open(DATA_DIR / f"{args.truth}.root")

assert isinstance(data_nocor, uproot.ReadOnlyDirectory)
assert isinstance(data_cor, uproot.ReadOnlyDirectory)
assert isinstance(data_truth, uproot.ReadOnlyDirectory)

cf_truth, phi, eta = corr_func(
    data_truth,
    TRUTH_TASK_NAME + "/SameEvent/DeltaEtaDeltaPhi",
    TRUTH_TASK_NAME + "/MixedEvent/DeltaEtaDeltaPhi",
)
phi = phi[:-1]

cf_nocor, *_ = corr_func(
    data_nocor,
    TASK_NAME + "/SameEvent_MC/DeltaEtaDeltaPhi",
    TASK_NAME + "/MixedEvent_MC/DeltaEtaDeltaPhi",
)
cf_cor, *_ = corr_func(
    data_cor,
    TASK_NAME + "/SameEvent_MC/DeltaEtaDeltaPhi",
    TASK_NAME + "/MixedEvent_MC/DeltaEtaDeltaPhi",
)

fig = plt.figure(figsize=(5, 5), tight_layout=True)
gs = fig.add_gridspec(2, 1, height_ratios=[3, 2])

top = fig.add_subplot(gs[0])

top.plot(
    phi,
    cf_truth,
    "o",
    color=colors[0],
    label="Truth",
)
top.plot(
    phi,
    cf_nocor,
    "s",
    color=colors[3],
    markerfacecolor="none",
    label="Recon. w/o corrections",
)
top.plot(
    phi,
    cf_cor,
    "o",
    color=colors[1],
    markerfacecolor="none",
    label="Recon. w/ corrections",
)
top.set_ylabel(r"$C(\Delta\varphi)$")
top.legend(title=f"Correlation function - ${''.join(args.pair_tex)}$")

bot = fig.add_subplot(gs[1], sharex=top)
plt.setp(top.get_xticklabels(), visible=False)

ratio = cf_cor / cf_truth
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
bot.set_ylabel("Ratio (recon. w/ corr. over truth)")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
