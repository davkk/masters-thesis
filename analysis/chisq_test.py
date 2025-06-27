from collections import defaultdict
from pathlib import Path

import common
import matplotlib.pyplot as plt
import numpy as np
from common import DATA_DIR

colors, _ = common.setup_pyplot()

chisq_data = defaultdict(dict)

with open(DATA_DIR / "chisq-test.tsv") as f:
    for line in f.readlines():
        line = line.strip()
        name, *values = line.split()
        for dim, value in enumerate(values):
            chisq_data[name][dim + 1] = float(value)

data = [(name, dim[1], dim[2]) for name, dim in chisq_data.items()]
data.sort(key=lambda x: x[2], reverse=True)

labels = []
for pair, _, _ in data:
    p1, p2 = pair.split("-")
    labels.append(f"${common.to_latex[p1]}{common.to_latex[p2]}$")

chisq_1d = [dim1 for _, dim1, _ in data]
chisq_2d = [dim2 for _, _, dim2 in data]

x = np.arange(len(labels))
width = 0.20

fig, ax = plt.subplots(figsize=(6, 4))
bars1 = ax.bar(x - width / 2, chisq_1d, width, label="1D corrections", color=colors[2])
bars2 = ax.bar(x + width / 2, chisq_2d, width, label="2D corrections", color=colors[3])

for bars in [bars1, bars2]:
    for bar in bars:
        height = bar.get_height()
        ax.annotate(
            f"{height:.2f}",
            xy=(bar.get_x() + bar.get_width() / 2, height),
            xytext=(0, 3),
            textcoords="offset points",
            ha="center",
            va="bottom",
            rotation=90,
            fontsize=8,
        )

ax.set_xlabel("Particle pair")
ax.set_xticks(x)
ax.set_xticklabels(labels, ha="center")
ax.tick_params(axis="x", which="both", length=0)

ax.set_ylabel("Chi-squared value")
ax.set_yscale("log")
ax.margins(y=0.3)

ax.legend()
ax.grid(True, axis="y", linestyle="--", alpha=0.5)

fig.tight_layout()
fig.savefig(DATA_DIR / f"{Path(__file__).stem}.pdf")
