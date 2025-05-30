import numpy as np
from scipy.stats import chi2


def chi2_test_uw(h1_counts, h2_sumw, h2_sumw2):
    """
    Perform a chi-square test for comparing an unweighted histogram (h1_counts)
    with a weighted histogram (h2_sumw, h2_sumw2), similar to ROOT's "UW" option.

    Parameters:
    - h1_counts: List or array of unweighted counts for each bin (integers).
    - h2_sumw: List or array of sum of weights for each bin in the weighted histogram.
    - h2_sumw2: List or array of sum of weight^2 for each bin in the weighted histogram.

    Returns:
    - chi2_stat: The chi-square statistic.
    - ndf: The number of degrees of freedom.
    - p_value: The p-value of the test.
    """
    # Convert inputs to NumPy arrays for easier computation
    h1_counts = np.array(h1_counts)
    h2_sumw = np.array(h2_sumw)
    h2_sumw2 = np.array(h2_sumw2)

    # Check if arrays have the same length
    if not (len(h1_counts) == len(h2_sumw) == len(h2_sumw2)):
        raise ValueError("All input arrays must have the same length")

    # Compute total sums
    sum1 = np.sum(h1_counts)  # Total counts in unweighted histogram
    sum2 = np.sum(h2_sumw)  # Total sum of weights in weighted histogram

    # Check if either histogram is empty
    if sum1 == 0 or sum2 == 0:
        raise ValueError("One of the histograms is empty")

    # Initialize chi-square statistic and degrees of freedom
    nbins = len(h1_counts)
    chi2_stat = 0.0
    ndf = nbins - 1  # Degrees of freedom for 1D histograms

    # Iterate over each bin
    for i in range(nbins):
        cnt1 = h1_counts[i]  # Unweighted count in bin i
        cnt2 = h2_sumw[i]  # Sum of weights in bin i for weighted histogram
        e2sq = h2_sumw2[i]  # Sum of weight^2 in bin i (error squared)

        # If both histograms have zero content in this bin, reduce ndf
        if cnt1 == 0 and cnt2 == 0:
            ndf -= 1
            continue

        # Handle case where weighted histogram has zero content and error
        if cnt2 == 0 and e2sq == 0:
            # Estimate error from total sum of weights and sum of weight^2
            sumw2_total = np.sum(h2_sumw2)
            if sumw2_total > 0:
                e2sq = sumw2_total / sum2
            else:
                raise ValueError(
                    f"Bin {i} in weighted histogram has zero content and error"
                )

        # Compute intermediate variables
        var1 = sum2 * cnt2 - sum1 * e2sq
        var2 = var1**2 + 4 * sum2**2 * cnt1 * e2sq

        # Handle potential numerical issues (var2 should be non-negative)
        if var2 < 0:
            var2 = 0
        var2 = np.sqrt(var2)

        # Compute probability estimator
        probb = (var1 + var2) / (2 * sum2**2)

        # Ensure probb is within valid range
        probb = np.clip(probb, 0, 1)

        # Compute expected values
        nexp1 = probb * sum1
        nexp2 = probb * sum2

        # Compute differences (residuals)
        delta1 = cnt1 - nexp1
        delta2 = cnt2 - nexp2

        # Add to chi-square statistic
        if nexp1 > 0:
            chi2_stat += (delta1**2) / nexp1
        if e2sq > 0:
            chi2_stat += (delta2**2) / e2sq

    # Compute p-value
    if ndf > 0:
        p_value = 1 - chi2.cdf(chi2_stat, df=ndf)
    else:
        p_value = np.nan  # Handle case where ndf <= 0

    return chi2_stat, ndf, p_value


# Example usage
if __name__ == "__main__":
    # Example data: Unweighted histogram (h1_counts)
    h1_counts = [10, 20, 15, 5, 0]

    # Example data: Weighted histogram (h2_sumw and h2_sumw2)
    h2_sumw = [12.5, 18.0, 16.2, 6.3, 0.0]
    h2_sumw2 = [15.0, 20.0, 18.0, 7.0, 0.0]

    # Run the test
    chi2_stat, ndf, p_value = chi2_test_uw(h1_counts, h2_sumw, h2_sumw2)

    # Print results
    print(f"Chi-square statistic: {chi2_stat:.4f}")
    print(f"Degrees of freedom: {ndf}")
    print(f"P-value: {p_value:.4f}")
