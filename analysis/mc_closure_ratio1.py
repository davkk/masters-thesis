from dataclasses import dataclass
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


def project(
    hist: TH.Model_TH2F_v4,
    axis: int,
) -> tuple[npt.NDArray, npt.NDArray, Any, Any]:
    hist_np = hist.to_numpy()
    assert len(hist_np) == 3

    signal, phi, eta = hist_np
    vars = hist.variances()

    eta = 0.5 * (eta[:-1] + eta[1:])
    phi = 0.5 * (phi[:-1] + phi[1:])

    global phi_mask
    global eta_mask
    phi_mask = (phi > -0.5) & (phi < 4)
    eta_mask = (eta > -1.5) & (eta < 1.5)

    signal[~phi_mask][:, ~eta_mask] = 0

    proj = signal.sum(axis=axis)
    proj_var = vars.sum(axis=axis)

    return proj, proj_var, phi, eta


@dataclass
class CorrFunc:
    val: npt.NDArray
    err: npt.NDArray
    phi: npt.NDArray
    eta: npt.NDArray


def corr_func(
    file: uproot.ReadOnlyDirectory,
    path_same: str,
    path_mixed: str,
) -> list[CorrFunc]:
    same_event = file[path_same]
    mixed_event = file[path_mixed]

    assert isinstance(same_event, TH.Model_TH2F_v4)
    assert isinstance(mixed_event, TH.Model_TH2F_v4)

    outputs = []

    for axis in reversed(range(2)):
        num, num_var, same_phi, same_eta = project(same_event, axis)
        den, den_var, mixed_phi, mixed_eta = project(mixed_event, axis)

        assert same_phi.shape == mixed_phi.shape
        assert np.isclose(same_phi[0], mixed_phi[0])
        assert np.isclose(same_phi[-1], mixed_phi[-1])

        assert same_eta.shape == mixed_eta.shape
        assert np.isclose(same_eta[0], mixed_eta[0])
        assert np.isclose(same_eta[-1], mixed_eta[-1])

        scale = den.sum() / num.sum()

        corr = (num / den) * scale
        corr_err = (scale / den) * np.sqrt((num_var + (num / den) ** 2 * den_var))

        outputs.append(
            CorrFunc(
                val=corr,
                err=corr_err,
                phi=same_phi,
                eta=same_eta,
            )
        )

    return outputs


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
    cf_truths = corr_func(
        data_truth,
        f"{TRUTH_TASK_NAME}/SameEvent/DeltaEtaDeltaPhi",
        f"{TRUTH_TASK_NAME}/MixedEvent/DeltaEtaDeltaPhi",
    )
except uproot.exceptions.KeyInFileError:
    cf_truths = corr_func(
        data_truth,
        f"{TRUTH_TASK_NAME}_{pair}/SameEvent/DeltaEtaDeltaPhi",
        f"{TRUTH_TASK_NAME}_{pair}/MixedEvent/DeltaEtaDeltaPhi",
    )

cf_nocors = corr_func(
    data_nocor,
    f"{TASK_NAME_BASE}_nocor/SameEvent_MC/DeltaEtaDeltaPhi",
    f"{TASK_NAME_BASE}_nocor/MixedEvent_MC/DeltaEtaDeltaPhi",
)

TASK_NAME_COR = TASK_NAME_BASE + (f"_{args.dim}d" if int(args.dim) > 0 else "")
cf_cors = corr_func(
    data_cor,
    f"{TASK_NAME_COR}/SameEvent_MC/DeltaEtaDeltaPhi",
    f"{TASK_NAME_COR}/MixedEvent_MC/DeltaEtaDeltaPhi",
)

if __name__ == "__main__":
    fig = plt.figure(figsize=(10, 5), tight_layout=True)
    gs = fig.add_gridspec(2, 2, height_ratios=[3, 2])

    X_labels = [r"\Delta\varphi", r"\Delta\eta"]

    for idx, (cf_truth, cf_nocor, cf_cor) in enumerate(
        zip(cf_truths, cf_nocors, cf_cors)
    ):
        mask = [phi_mask, eta_mask][idx]
        X = [cf_truth.phi[mask], cf_truth.eta[mask]]

        top = fig.add_subplot(gs[0, idx])

        top.errorbar(
            X[idx],
            cf_truth.val[mask],
            yerr=cf_truth.err[mask],
            fmt="o",
            color=colors[0],
            label="Truth",
        )
        top.errorbar(
            X[idx],
            cf_nocor.val[mask],
            yerr=cf_nocor.err[mask],
            fmt="s",
            color=colors[3],
            markerfacecolor="none",
            label="Recon. w/o corrections",
        )
        top.errorbar(
            X[idx],
            cf_cor.val[mask],
            yerr=cf_cor.err[mask],
            fmt="o",
            color=colors[1],
            markerfacecolor="none",
            label="Recon. w/ corrections",
        )
        top.set_ylabel(f"$C({X_labels[idx]})$")
        top.legend(title=f"Correlation function - ${''.join(args.pair_tex)}$")

        bot = fig.add_subplot(gs[1, idx], sharex=top)
        plt.setp(top.get_xticklabels(), visible=False)

        ratio = cf_cor.val[mask] / cf_truth.val[mask]

        rel_err_cor = cf_cor.err[mask] / np.maximum(cf_cor.val[mask], 1e-10)
        rel_err_truth = cf_truth.err[mask] / np.maximum(cf_truth.val[mask], 1e-10)
        ratio_err = ratio * np.sqrt(rel_err_cor**2 + rel_err_truth**2)
        bot.errorbar(
            X[idx],
            ratio,
            yerr=ratio_err,
            fmt=".",
            color=colors[0],
        )

        bot.axhline(1, color=colors[0], linestyle="-", linewidth=0.3)
        bot.set_xlabel(f"${X_labels[idx]}$")
        bot.set_ylabel("Ratio (recon. w/ corr. over truth)")

    fig.savefig(DATA_DIR / f"{Path(__file__).stem}_{args.dim}d.pdf")
