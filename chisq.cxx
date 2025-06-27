#include <TFile.h>
#include <TH1.h>
#include <TH2.h>
#include <unistd.h>
#include <filesystem>
#include <format>
#include <print>
#include <string>

namespace fs = std::filesystem;

TH2* get_hist(TFile* file, const std::string& name) {
  return dynamic_cast<TH2*>(file->Get(name.c_str()));
}

template <typename H>
H* clone_hist(H* hist, const std::string& name) {
  return dynamic_cast<H*>(hist->Clone(name.c_str()));
}

template <typename H>
H* get_corr_func(H* same, H* mixed) {
  auto* corr {clone_hist(same, "hCorrelationFunction")};
  auto scale {mixed->Integral() / same->Integral()};

  for (auto bin_idx {1}; bin_idx <= same->GetNbinsX(); ++bin_idx) {
    corr->SetBinContent(bin_idx, same->GetBinContent(bin_idx) / mixed->GetBinContent(bin_idx) * scale);
    corr->SetBinError(
        bin_idx,
        scale / mixed->GetBinContent(bin_idx)
            * std::sqrt(
                std::pow(same->GetBinError(bin_idx), 2)
                + (std::pow(
                    same->GetBinContent(bin_idx) * mixed->GetBinError(bin_idx) / mixed->GetBinContent(bin_idx),
                    2
                ))
            )
    );
  }

  return corr;
}

auto chisq(const fs::path& recon_path, const fs::path& truth_path) -> void {
  auto* recon_file {TFile::Open(recon_path.c_str())};
  assert(recon_file != nullptr && !recon_file->IsZombie());

  auto* truth_file {TFile::Open(truth_path.c_str())};
  assert(truth_file != nullptr && !truth_file->IsZombie());

  auto pair {recon_path.parent_path().stem().string()};

  auto truth_task {std::format("femto-universe-pair-task-track-track-mc-truth")};
  auto* truth_same {get_hist(truth_file, std::format("{}/SameEvent/DeltaEtaDeltaPhi", truth_task))};
  auto* truth_mixed {get_hist(truth_file, std::format("{}/MixedEvent/DeltaEtaDeltaPhi", truth_task))};
  assert(truth_same != nullptr && truth_mixed != nullptr && truth_file->IsOpen());

  auto* truth_corr = get_corr_func(truth_same, truth_mixed);
  assert(truth_corr != nullptr);

  for (auto dim : {1, 2}) {
    auto recon_task {std::format("femto-universe-pair-task-track-track-extended_{}_{}d", pair, dim)};
    auto* recon_same {get_hist(recon_file, std::format("{}/SameEvent_MC/DeltaEtaDeltaPhi", recon_task))};
    auto* recon_mixed {get_hist(recon_file, std::format("{}/MixedEvent_MC/DeltaEtaDeltaPhi", recon_task))};
    assert(recon_same != nullptr && recon_mixed != nullptr);

    auto* recon_corr = get_corr_func(recon_same, recon_mixed);
    assert(recon_corr != nullptr);

    auto chi2 {truth_corr->Chi2Test(recon_corr, "UW CHI2/NDF")};
    std::print("{} ", chi2);
  }
}

auto main(int argc, char** argv) -> int {
  std::string recon_file;
  std::string truth_file;
  auto flag {0};

  while ((flag = getopt(argc, argv, "r:t:")) != -1) {
    switch (flag) {
    case 'r':
      recon_file = optarg;
      break;
    case 't':
      truth_file = optarg;
      break;
    default:
      return 1;
    }
  }

  chisq(recon_file, truth_file);
  return 0;
}
