from pathlib import Path
from typing import cast

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import uproot
from mpl_toolkits.mplot3d import Axes3D
from uproot.models import TH

import common
from common import DATA_DIR

args = common.parse_args()
colors, markers = common.setup_pyplot()

TASK_NAME = "femto-universe-pair-task-track-track-extended"
DATA_DIR /= args.dataset
DATA_DIR /= args.pair

data_cor = uproot.open(DATA_DIR / f"{args.cor}_cor.root")

assert isinstance(data_cor, uproot.ReadOnlyDirectory)

same_event = data_cor[TASK_NAME + "/SameEvent_MC/DeltaEtaDeltaPhi"]
mixed_event = data_cor[TASK_NAME + "/MixedEvent_MC/DeltaEtaDeltaPhi"]

assert isinstance(same_event, TH.Model_TH2F_v4)
assert isinstance(mixed_event, TH.Model_TH2F_v4)

fig = plt.figure(figsize=(10, 3), constrained_layout=True)
gs = fig.add_gridspec(1, 4, width_ratios=[5, 5, 5, 1])


def plot_3d_bar(x, y, z, ax: Axes3D):
    x, y = np.meshgrid(x, y, indexing="ij")
    cmap = plt.get_cmap("viridis")
    ax.plot_surface(x, y, z, cmap=cmap)


def clamp(same_event, phi, eta) -> tuple[npt.NDArray, npt.NDArray, npt.NDArray]:
    eta1 = eta[:-1]
    eta_cut = np.argwhere((eta1 <= 1) & (eta1 >= -1)).flatten()
    return same_event[:, eta_cut], phi[:-1], eta1[eta_cut]


ax_same = cast(Axes3D, fig.add_subplot(gs[0], projection="3d"))
same_event, phi, eta = clamp(*same_event.to_numpy())
same_event /= same_event.sum()
plot_3d_bar(phi, eta, same_event, ax=ax_same)
ax_same.set_title("Same event")
ax_same.set_xlabel(r"$\Delta\varphi$")
ax_same.set_ylabel(r"$\Delta\eta$")

ax_mixed = cast(Axes3D, fig.add_subplot(gs[1], projection="3d"))
mixed_event, phi, eta = clamp(*mixed_event.to_numpy())
mixed_event /= mixed_event.sum()
plot_3d_bar(phi, eta, mixed_event, ax=ax_mixed)
ax_mixed.set_title("Mixed event")
ax_mixed.set_xlabel(r"$\Delta\varphi$")
ax_mixed.set_ylabel(r"$\Delta\eta$")

ax_corr_func = cast(Axes3D, fig.add_subplot(gs[2], projection="3d"))
corr_func = same_event / mixed_event
plot_3d_bar(phi, eta, corr_func, ax=ax_corr_func)
ax_corr_func.set_title(f"Correlation function - {args.pair_tex}")
ax_corr_func.set_zlim(0.8)
ax_corr_func.set_xlabel(r"$\Delta\varphi$")
ax_corr_func.set_ylabel(r"$\Delta\eta$")
ax_corr_func.set_zlabel(r"$C(\Delta\varphi,\Delta\eta)$")

fig.add_subplot(gs[3]).axis("off")

fig.savefig(DATA_DIR / f"{Path(__file__).stem}-{args.cor}.pdf")
