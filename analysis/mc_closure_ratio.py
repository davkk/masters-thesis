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

def project(hist: TH.Model_TH2F_v4) -> tuple[npt.NDArray, npt.NDArray, Any, Any]:
    hist_np = hist.to_numpy()
    assert len(hist_np) == 3

    signal, phi, eta = hist_np
    vars = hist.variances()

    proj = signal.sum(axis=1)
    proj_err = np.sqrt(vars.sum(axis=1))

    norm = proj.sum()
    proj /= norm
    proj_err /= norm

    return proj, proj_err, phi, eta


def corr_func(
    file: uproot.ReadOnlyDirectory,
    path_same: str,
    path_mixed: str,
) -> tuple[npt.NDArray, npt.NDArray, npt.NDArray, npt.NDArray]:
    same_event = file[path_same]
    mixed_event = file[path_mixed]

    assert isinstance(same_event, TH.Model_TH2F_v4)
    assert isinstance(mixed_event, TH.Model_TH2F_v4)

    num, num_err, same_phi, same_eta = project(same_event)
    den, den_err, mixed_phi, mixed_eta = project(mixed_event)

    assert same_phi.shape == mixed_phi.shape
    assert np.isclose(same_phi[0], mixed_phi[0])
    assert np.isclose(same_phi[-1], mixed_phi[-1])

    assert same_eta.shape == mixed_eta.shape
    assert np.isclose(same_eta[0], mixed_eta[0])
    assert np.isclose(same_eta[-1], mixed_eta[-1])

    scale = den.sum() / num.sum()

    corr = (num / den) * scale
    corr_err = corr * np.sqrt((num_err / num) ** 2 + (den_err / den) ** 2)

    return corr, corr_err, same_phi, same_eta


args = common.parse_args()
colors, markers = common.setup_pyplot()
pair = "-".join(args.pair)

TRUTH_TASK_NAME = "femto-universe-pair-task-track-track-mc-truth"
TASK_NAME_BASE = f"femto-universe-pair-task-track-track-extended_{pair}"
DATA_DIR /= args.dataset
DATA_DIR /= pair

data_nocor = uproot.open(DATA_DIR / f"{args.nocor}.root")
data_cor = uproot.open(DATA_DIR / f"{args.cor}.root")
data_truth = uproot.open(DATA_DIR / f"{args.truth}.root")

assert isinstance(data_nocor, uproot.ReadOnlyDirectory)
assert isinstance(data_cor, uproot.ReadOnlyDirectory)
assert isinstance(data_truth, uproot.ReadOnlyDirectory)

try:
    cf_truth, cf_truth_err, phi, eta = corr_func(
        data_truth,
        f"{TRUTH_TASK_NAME}/SameEvent/DeltaEtaDeltaPhi",
        f"{TRUTH_TASK_NAME}/MixedEvent/DeltaEtaDeltaPhi",
    )
except uproot.exceptions.KeyInFileError:
    cf_truth, cf_truth_err, phi, eta = corr_func(
        data_truth,
        f"{TRUTH_TASK_NAME}_{pair}/SameEvent/DeltaEtaDeltaPhi",
        f"{TRUTH_TASK_NAME}_{pair}/MixedEvent/DeltaEtaDeltaPhi",
    )

phi = phi[:-1]

cf_nocor, cf_nocor_err, *_ = corr_func(
    data_nocor,
    f"{TASK_NAME_BASE}_nocor/SameEvent_MC/DeltaEtaDeltaPhi",
    f"{TASK_NAME_BASE}_nocor/MixedEvent_MC/DeltaEtaDeltaPhi",
)

TASK_NAME_COR = TASK_NAME_BASE + (f"_{args.dim}d" if int(args.dim) > 0 else "")
cf_cor, cf_cor_err, *_ = corr_func(
    data_cor,
    f"{TASK_NAME_COR}/SameEvent_MC/DeltaEtaDeltaPhi",
    f"{TASK_NAME_COR}/MixedEvent_MC/DeltaEtaDeltaPhi",
)

if __name__ == "__main__":
    fig = plt.figure(figsize=(5, 5), tight_layout=True)
    gs = fig.add_gridspec(2, 1, height_ratios=[3, 2])

    top = fig.add_subplot(gs[0])

    top.errorbar(
        phi,
        cf_truth,
        yerr=cf_truth_err,
        fmt="o",
        color=colors[0],
        label="Truth",
    )
    top.errorbar(
        phi,
        cf_nocor,
        yerr=cf_nocor_err,
        fmt="s",
        color=colors[3],
        markerfacecolor="none",
        label="Recon. w/o corrections",
    )
    top.errorbar(
        phi,
        cf_cor,
        yerr=cf_cor_err,
        fmt="o",
        color=colors[1],
        markerfacecolor="none",
        label="Recon. w/ corrections",
    )
    top.set_ylabel(r"$C(\Delta\varphi)$")
    top.legend(title=f"Correlation function - ${''.join(args.pair_tex)}$")

    bot = fig.add_subplot(gs[1], sharex=top)
    plt.setp(top.get_xticklabels(), visible=False)

    ratio = cf_cor / cf_truth

    rel_err_cor = cf_cor_err / np.maximum(cf_cor, 1e-10)
    rel_err_truth = cf_truth_err / np.maximum(cf_truth, 1e-10)
    ratio_err = ratio * np.sqrt(rel_err_cor**2 + rel_err_truth**2)
    bot.errorbar(
        phi,
        ratio,
        fmt=".",
        yerr=ratio_err,
        color=colors[0],
    )

    bot.axhline(1, color=colors[0], linestyle="-", linewidth=0.3)
    bot.set_xlabel(r"$\Delta\varphi$")
    bot.set_ylabel("Ratio (recon. w/ corr. over truth)")

    fig.savefig(DATA_DIR / f"{Path(__file__).stem}_{args.dim}d.svg")
