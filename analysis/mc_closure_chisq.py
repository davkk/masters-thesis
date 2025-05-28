import numpy as np
from mc_closure_ratio import cf_cor, cf_cor_err, cf_truth
from scipy.stats import chi2


def chi2_unweighted(
    n: np.ndarray, m: np.ndarray, normalize: bool = True
) -> tuple[float, int, float]:
    """
    Standard Pearson chi2 between two unweighted histograms:
      - n, m: arrays of bin counts (same length)
      - normalize: if True, scale m to have same total as n
    Returns: (chi2, ndf, chi2/ndf, p_value)
    """
    if normalize:
        scale = n.sum() / m.sum()
        m = m * scale

    var = n + m

    chi2_val = ((n - m) ** 2 / var).sum()
    ndf = len(n) - 1
    chi2_red = chi2_val / ndf

    return chi2_val, ndf, chi2_red


chi2_val, ndf, chi2_red = chi2_unweighted(cf_truth, cf_cor, normalize=True)
print(f"χ² = {chi2_val}, NDF = {ndf}, χ²/NDF = {chi2_red}")
