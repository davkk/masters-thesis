import sys
from dataclasses import dataclass
from pathlib import Path

import scienceplots
from cycler import cycler
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


def setup_pyplot(base_size=2):
    plt.style.use(["science", "ieee", "no-latex"])

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

    colors = [
        "#333333",  # black
        "#ff2c00",  # red
        "#00b945",  # green
        "#0c5da5",  # blue
        "#ff9500",  # orange
        "#845b97",  # purple
        "#9e9e9e",  # grey
        "#ff9faf",  # pink
    ]

    plt.rcParams["axes.prop_cycle"] = cycler(color=colors)

    markers = ["o", "D", "s", "h", "x", "*", "v", "^"]
    markers = {
        "o": base_size,
        "D": base_size * 0.9,
        "s": base_size * 0.85,
        "x": base_size * 1.4,
        "h": base_size * 1.1,
        "H": base_size * 1.1,
        "*": base_size * 1.5,
        "^": base_size * 1.0,
        "v": base_size * 1.0,
    }
    return colors, markers
