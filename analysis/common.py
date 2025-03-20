import sys
from dataclasses import dataclass
from pathlib import Path

import scienceplots
from matplotlib import pyplot as plt

DATA_DIR = Path(__file__).parent.parent / "data"
FIG_DIR = Path(__file__).parent.parent / "figures"

to_latex = {
    "p": r"p",
    "pi": r"\pi",
    "ap": r"\overline{p}",
    "api": r"\overline{\pi}",
}


@dataclass
class Args:
    pair: tuple[str, str]
    pair_tex: tuple[str, str]
    dataset: str
    cor: str
    nocor: str
    truth: str


# pair,dataset,eff,cor,nocor,truth
def parse_args():
    assert len(sys.argv) > 1
    pair = tuple(sys.argv[1].split("-"))
    assert len(pair) == 2
    pair_tex = (to_latex[pair[0]], to_latex[pair[1]])
    return Args(pair, pair_tex, *sys.argv[2:])


def setup_pyplot():
    plt.style.use(["science", "ieee"])

    # custom font
    plt.rcParams["text.latex.preamble"] += r"""\usepackage[T1]{fontenc}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
%\usepackage[sfdefault,scale=0.95]{FiraSans}
\usepackage[lf]{Baskervaldx} % lining figures
\usepackage[bigdelims,vvarbb]{newtxmath} % math italic letters from nimbus Roman
\usepackage[cal=boondoxo]{mathalfa} % mathcal from STIX, unslanted a bit
\renewcommand*\oldstylenums[1]{\textosf{#1}}"""

    plt.rcParams["path.simplify"] = True

    plt.rcParams["xtick.direction"] = "in"
    plt.rcParams["ytick.direction"] = "in"

    plt.rcParams["axes.formatter.limits"] = -4, 4
    plt.rcParams["axes.formatter.use_mathtext"] = True

    plt.rcParams["lines.markersize"] = 5

    plt.rcParams["axes.labelpad"] = 2
    plt.rcParams["xtick.major.pad"] = 2
    plt.rcParams["ytick.major.pad"] = 2

    colors = plt.rcParams["axes.prop_cycle"].by_key()["color"]
    markers = [".", "D", "*"]
    return colors, markers
