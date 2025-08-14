import math
import sys
from dataclasses import dataclass
from pathlib import Path

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
) -> tuple[npt.NDArray, npt.NDArray, npt.NDArray, npt.NDArray, bool, bool]:
    hist_np = hist.to_numpy()
    assert len(hist_np) == 3

    signal, phi, eta = hist_np
    vars = hist.variances()

    eta = 0.5 * (eta[:-1] + eta[1:])
    phi = 0.5 * (phi[:-1] + phi[1:])

    phi_mask = (phi > -math.pi) & (phi < 3 * math.pi / 2)
    eta_mask = (eta > -1.5) & (eta < 1.5)

    signal[~phi_mask][:, ~eta_mask] = 0

    proj = signal.sum(axis=axis)
    proj_var = vars.sum(axis=axis)

    return proj, proj_var, phi, eta, phi_mask, eta_mask


@dataclass
class CorrFunc:
    val: npt.NDArray
    err: npt.NDArray
    phi: npt.NDArray
    phi_mask: bool
    eta: npt.NDArray
    eta_mask: bool


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
        num, num_var, same_phi, same_eta, phi_mask, eta_mask = project(same_event, axis)
        den, den_var, mixed_phi, mixed_eta, *_ = project(mixed_event, axis)

        assert same_phi.shape == mixed_phi.shape
        assert np.isclose(same_phi[0], mixed_phi[0])
        assert np.isclose(same_phi[-1], mixed_phi[-1])

        assert same_eta.shape == mixed_eta.shape
        assert np.isclose(same_eta[0], mixed_eta[0])
        assert np.isclose(same_eta[-1], mixed_eta[-1])

        scale = den.sum() / num.sum()

        corr = np.full_like(num, np.nan)
        corr_err = np.full_like(num, np.nan)

        den[den == 0] = sys.float_info.epsilon

        corr = (num / den) * scale
        corr_err = (scale / den) * np.sqrt((num_var + (num / den) ** 2 * den_var))

        outputs.append(
            CorrFunc(
                val=corr,
                err=corr_err,
                phi=same_phi,
                phi_mask=phi_mask,
                eta=same_eta,
                eta_mask=eta_mask,
            )
        )

    return outputs


if __name__ == "__main__":
    args = common.parse_args()

    colors, markers = common.setup_pyplot(base_size=5)
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

    MC = "_MC" if args.mc else ""

    cf_truths = corr_func(
        data_truth,
        f"{TRUTH_TASK_NAME}/SameEvent/DeltaEtaDeltaPhi",
        f"{TRUTH_TASK_NAME}/MixedEvent/DeltaEtaDeltaPhi",
    )

    cf_nocors = corr_func(
        data_nocor,
        f"{TASK_NAME_BASE}_nocor/SameEvent{MC}/DeltaEtaDeltaPhi",
        f"{TASK_NAME_BASE}_nocor/MixedEvent{MC}/DeltaEtaDeltaPhi",
    )

    cf_cors_1d = corr_func(
        data_cor,
        f"{TASK_NAME_BASE}_1d/SameEvent{MC}/DeltaEtaDeltaPhi",
        f"{TASK_NAME_BASE}_1d/MixedEvent{MC}/DeltaEtaDeltaPhi",
    )

    cf_cors_2d = corr_func(
        data_cor,
        f"{TASK_NAME_BASE}_2d/SameEvent{MC}/DeltaEtaDeltaPhi",
        f"{TASK_NAME_BASE}_2d/MixedEvent{MC}/DeltaEtaDeltaPhi",
    )

    fig = plt.figure(figsize=(8, 4))
    fig.subplots_adjust(top=1, hspace=0.05, wspace=0.2)

    gs = fig.add_gridspec(2, 2, height_ratios=[3, 2])

    X_labels = [r"\Delta\varphi", r"\Delta\eta"]

    for idx, (cf_truth, cf_nocor, cf_cor_1d, cf_cor_2d) in enumerate(
        zip(cf_truths, cf_nocors, cf_cors_1d, cf_cors_2d)
    ):
        mask = [cf_truth.phi_mask, cf_truth.eta_mask][idx]
        X = [cf_truth.phi[mask], cf_truth.eta[mask]]

        top = fig.add_subplot(gs[0, idx])

        top.plot(
            X[idx],
            cf_truth.val[mask],
            label="Truth",
        )
        top.errorbar(
            X[idx],
            cf_nocor.val[mask],
            yerr=cf_nocor.err[mask],
            fmt="s",
            markersize=markers["s"],
            markerfacecolor="none",
            label="Recon. w/o corrections",
        )
        top.errorbar(
            X[idx],
            cf_cor_1d.val[mask],
            yerr=cf_cor_1d.err[mask],
            fmt="o",
            markersize=markers["o"],
            markerfacecolor="none",
            label="Recon. w/ 1D corrections",
        )
        top.errorbar(
            X[idx],
            cf_cor_2d.val[mask],
            yerr=cf_cor_2d.err[mask],
            fmt="h",
            markersize=markers["h"],
            markerfacecolor="none",
            label="Recon. w/ 2D corrections",
        )
        top.set_ylabel(f"$C({X_labels[idx]})$")
        if idx == 0:
            top.legend(
                loc="lower center",
                bbox_to_anchor=(0.5, 1.02),
                bbox_transform=fig.transFigure,
                ncols=4,
                title=f"Correlation function - ${''.join(args.pair_tex)}$",
            )

        bot = fig.add_subplot(gs[1, idx], sharex=top)
        plt.setp(top.get_xticklabels(), visible=False)

        ratio_1d = cf_cor_1d.val[mask] / cf_truth.val[mask]

        rel_err_cor_1d = cf_cor_1d.err[mask] / np.maximum(cf_cor_1d.val[mask], 1e-10)
        rel_err_truth_1d = cf_truth.err[mask] / np.maximum(cf_truth.val[mask], 1e-10)
        ratio_err_1d = ratio_1d * np.sqrt(rel_err_cor_1d**2 + rel_err_truth_1d**2)
        bot.errorbar(
            X[idx],
            ratio_1d,
            yerr=ratio_err_1d,
            fmt="o",
            markersize=markers["o"] * 2 / 3,
            color=colors[2],
            label="1D",
        )
        ratio_2d = cf_cor_2d.val[mask] / cf_truth.val[mask]

        rel_err_cor_2d = cf_cor_2d.err[mask] / np.maximum(cf_cor_2d.val[mask], 1e-10)
        rel_err_truth_2d = cf_truth.err[mask] / np.maximum(cf_truth.val[mask], 1e-10)
        ratio_err_2d = ratio_2d * np.sqrt(rel_err_cor_2d**2 + rel_err_truth_2d**2)
        bot.errorbar(
            X[idx],
            ratio_2d,
            yerr=ratio_err_2d,
            fmt="H",
            markersize=markers["H"] * 2 / 3,
            color=colors[3],
            label="2D",
        )

        bot.legend()
        bot.axhline(1, color=colors[0], linestyle="-", linewidth=0.3)
        bot.set_xlabel(f"${X_labels[idx]}$")
        bot.set_ylabel("Ratio (recon. w/ corr. over truth)")

    fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
