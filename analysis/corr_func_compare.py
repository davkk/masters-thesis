from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import uproot
from common import DATA_DIR
from matplotlib.colors import LinearSegmentedColormap
from mpl_toolkits.mplot3d import Axes3D
from uproot.models import TH


def plot_3d_bar(x, y, z, ax: Axes3D, cmap):
    x, y = np.meshgrid(x, y, indexing="ij")
    ax.plot_surface(x, y, z, cmap=cmap)


def get_corr_func(
    file: uproot.ReadOnlyDirectory, task_name: str, mc: bool
) -> tuple[npt.NDArray, npt.NDArray, npt.NDArray]:
    MC = "_MC" if mc else ""
    same_event_hist = file[f"{task_name}/SameEvent{MC}/DeltaEtaDeltaPhi"]
    mixed_event_hist = file[f"{task_name}/MixedEvent{MC}/DeltaEtaDeltaPhi"]

    assert isinstance(same_event_hist, TH.Model_TH2F_v4)
    same_event_hist = same_event_hist.to_numpy()
    assert len(same_event_hist) == 3

    assert isinstance(mixed_event_hist, TH.Model_TH2F_v4)
    mixed_event_hist = mixed_event_hist.to_numpy()
    assert len(mixed_event_hist) == 3

    same_event, phi_edges, eta_edges = same_event_hist
    mixed_event, _, _ = mixed_event_hist

    phi = 0.5 * (phi_edges[1:] + phi_edges[:-1])
    eta = 0.5 * (eta_edges[1:] + eta_edges[:-1])

    eta_mask = (eta > -1.5) & (eta < 1.5)
    phi_mask = (phi > -0.5) & (phi < 4.0)

    same_event = same_event[phi_mask][:, eta_mask]
    mixed_event = mixed_event[phi_mask][:, eta_mask]
    phi = phi[phi_mask]
    eta = eta[eta_mask]

    corr_func = (same_event / same_event.sum()) / (mixed_event / mixed_event.sum())
    return corr_func, phi, eta


if __name__ == "__main__":
    colors, _ = common.setup_pyplot()

    args = common.parse_args()
    pair = "-".join(args.pair)
    TASK_NAME_BASE = f"femto-universe-pair-task-track-track-extended_{pair}"
    DATA_DIR /= args.dataset
    DATA_DIR /= pair

    data_nocor = uproot.open(DATA_DIR / f"{args.nocor}.root")
    data_cor = uproot.open(DATA_DIR / f"{args.cor}.root")

    assert isinstance(data_nocor, uproot.ReadOnlyDirectory)
    assert isinstance(data_cor, uproot.ReadOnlyDirectory)

    cf_nocor, phi, eta = get_corr_func(data_nocor, f"{TASK_NAME_BASE}_nocor", args.mc)
    cf_cor1d, _, _ = get_corr_func(data_cor, f"{TASK_NAME_BASE}_1d", args.mc)
    cf_cor2d, _, _ = get_corr_func(data_cor, f"{TASK_NAME_BASE}_2d", args.mc)

    fig = plt.figure(figsize=(10, 6), constrained_layout=True)
    gs = fig.add_gridspec(2, 3, width_ratios=[1, 1.5, 1])

    cmap_viridis = LinearSegmentedColormap.from_list(
        "custom_viridis",
        [colors[3], colors[2], colors[4]],
    )
    cmap_diverging = LinearSegmentedColormap.from_list(
        "custom_diverging",
        [colors[3], "#ffffff", colors[1]],
    )

    ax_uncor = fig.add_subplot(gs[:, 0], projection="3d")
    assert isinstance(ax_uncor, Axes3D)
    plot_3d_bar(eta, phi, cf_nocor.T, ax=ax_uncor, cmap=cmap_viridis)
    ax_uncor.set_title(f"Correlation function - ${''.join(args.pair_tex)}$ w/o corr.")

    ax_cor1d = fig.add_subplot(gs[0, 1], projection="3d")
    assert isinstance(ax_cor1d, Axes3D)
    plot_3d_bar(eta, phi, cf_cor1d.T, ax=ax_cor1d, cmap=cmap_viridis)
    ax_cor1d.set_title(f"Cor. func. - ${''.join(args.pair_tex)}$ w/ 1D corr.")

    ax_cor2d = fig.add_subplot(gs[1, 1], projection="3d")
    assert isinstance(ax_cor2d, Axes3D)
    plot_3d_bar(eta, phi, cf_cor2d.T, ax=ax_cor2d, cmap=cmap_viridis)
    ax_cor2d.set_title(f"Cor. func. - ${''.join(args.pair_tex)}$ w/ 2D corr.")

    ratio1d = cf_cor1d / cf_nocor
    ratio2d = cf_cor2d / cf_nocor

    min_val = np.minimum(np.min(ratio1d), np.min(ratio2d))
    max_val = np.maximum(np.max(ratio1d), np.max(ratio2d))
    deviation = max(abs(max_val - 1), abs(1 - min_val))
    vmin, vmax = 1 - deviation, 1 + deviation

    ax_ratio1d = fig.add_subplot(gs[0, 2])
    im = ax_ratio1d.pcolormesh(
        eta, phi, ratio1d.T, cmap=cmap_diverging, vmin=vmin, vmax=vmax
    )
    fig.colorbar(im, ax=ax_ratio1d)
    ax_ratio1d.set_title("Ratio (w/ 1D corr. over w/o corr.)")

    ax_ratio2d = fig.add_subplot(gs[1, 2])
    im = ax_ratio2d.pcolormesh(
        eta, phi, ratio2d.T, cmap=cmap_diverging, vmin=vmin, vmax=vmax
    )
    fig.colorbar(im, ax=ax_ratio2d)
    ax_ratio2d.set_title("Ratio (w/ 2D corr. over w/o corr.)")

    for ax in [ax_uncor, ax_cor1d, ax_cor2d]:
        ax.view_init(elev=30, azim=-45)
        ax.set_zlabel(r"$C(\Delta\varphi,\Delta\eta)$", fontdict={"size": "small"})
        ax.set_xlabel(r"$\Delta\eta$", fontdict={"size": "small"})
        ax.set_ylabel(r"$\Delta\varphi$", fontdict={"size": "small"})

    for ax in [ax_ratio1d, ax_ratio2d]:
        ax.set_xlabel(r"$\Delta\eta$", fontdict={"size": "small"})
        ax.set_ylabel(r"$\Delta\varphi$", fontdict={"size": "small"})

    fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
