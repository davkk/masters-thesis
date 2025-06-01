import os
import sys
from dataclasses import dataclass
from pathlib import Path

import scienceplots
from matplotlib import font_manager as fm
from matplotlib import pyplot as plt

DATA_DIR = Path(__file__).parent.parent / "data"
FIG_DIR = Path(__file__).parent.parent / "figures"

to_latex = {
    "p": r"p",
    "pi": r"\pi^+",
    "ap": r"\overline{p}",
    "api": r"\pi^-",
    "k": r"K^+",
    "ak": r"K^-",
}


@dataclass
class Args:
    pair: tuple[str, str]
    pair_tex: tuple[str, str]
    dataset: str
    dim: str
    nocor: str
    cor: str
    truth: str


# pair,dataset,cor,nocor,truth
def parse_args():
    assert len(sys.argv) > 1
    pair = tuple(sys.argv[1].split("-"))
    assert len(pair) == 2
    pair_tex = (to_latex[pair[0]], to_latex[pair[1]])
    return Args(pair, pair_tex, *sys.argv[2:])


def setup_pyplot():
    plt.style.use(["science", "ieee"])

    plt.rcParams["text.usetex"] = False

    font_path = "fonts/BaskervaldADFStd.otf"
    fm.fontManager.addfont(font_path)
    font_prop = fm.FontProperties(fname=font_path)
    font_name = font_prop.get_name()
    plt.rcParams["font.family"] = font_name

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
    markers = ["o", "D", "s"]
    return colors, markers
