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

auto chisq(const fs::path& recon_nocor_path, const fs::path& recon_cor_path, const fs::path& truth_path) -> void {
  auto* recon_nocor_file {TFile::Open(recon_nocor_path.c_str())};
  assert(recon_nocor_file != nullptr && !recon_nocor_file->IsZombie());

  auto* recon_cor_file {TFile::Open(recon_cor_path.c_str())};
  assert(recon_cor_file != nullptr && !recon_cor_file->IsZombie());

  auto* truth_file {TFile::Open(truth_path.c_str())};
  assert(truth_file != nullptr && !truth_file->IsZombie());

  auto pair {recon_cor_path.parent_path().stem().string()};

  auto truth_task {std::format("femto-universe-pair-task-track-track-mc-truth")};
  auto* truth_same {get_hist(truth_file, std::format("{}/SameEvent/DeltaEtaDeltaPhi", truth_task))};
  auto* truth_mixed {get_hist(truth_file, std::format("{}/MixedEvent/DeltaEtaDeltaPhi", truth_task))};
  assert(truth_same != nullptr && truth_mixed != nullptr && truth_file->IsOpen());

  auto* truth_corr = get_corr_func(truth_same, truth_mixed);
  assert(truth_corr != nullptr);

  auto recon_task_nocor {std::format("femto-universe-pair-task-track-track-extended_{}_nocor", pair)};
  auto* recon_same_nocor {get_hist(recon_nocor_file, std::format("{}/SameEvent_MC/DeltaEtaDeltaPhi", recon_task_nocor))
  };
  auto* recon_mixed_nocor {
      get_hist(recon_nocor_file, std::format("{}/MixedEvent_MC/DeltaEtaDeltaPhi", recon_task_nocor))
  };
  assert(recon_same_nocor != nullptr && recon_mixed_nocor != nullptr);

  auto* recon_corr_nocor = get_corr_func(recon_same_nocor, recon_mixed_nocor);
  assert(recon_corr_nocor != nullptr);

  auto chi2 {truth_corr->Chi2Test(recon_corr_nocor, "UW CHI2/NDF")};
  std::print("{} ", chi2);

  for (auto dim : {1, 2}) {
    auto recon_cor_task {std::format("femto-universe-pair-task-track-track-extended_{}_{}d", pair, dim)};
    auto* recon_same_cor {get_hist(recon_cor_file, std::format("{}/SameEvent_MC/DeltaEtaDeltaPhi", recon_cor_task))};
    auto* recon_mixed_cor {get_hist(recon_cor_file, std::format("{}/MixedEvent_MC/DeltaEtaDeltaPhi", recon_cor_task))};
    assert(recon_same_cor != nullptr && recon_mixed_cor != nullptr);

    auto* recon_corr_cor = get_corr_func(recon_same_cor, recon_mixed_cor);
    assert(recon_corr_cor != nullptr);

    auto chi2 {truth_corr->Chi2Test(recon_corr_cor, "UW CHI2/NDF")};
    std::print("{} ", chi2);
  }
}

auto main(int argc, char** argv) -> int {
  std::string recon_cor_file;
  std::string recon_nocor_file;
  std::string truth_file;
  auto flag {0};

  while ((flag = getopt(argc, argv, "n:c:t:")) != -1) {
    switch (flag) {
    case 'n':
      recon_nocor_file = optarg;
      break;
    case 'c':
      recon_cor_file = optarg;
      break;
    case 't':
      truth_file = optarg;
      break;
    default:
      return 1;
    }
  }

  chisq(recon_nocor_file, recon_cor_file, truth_file);
  return 0;
}
