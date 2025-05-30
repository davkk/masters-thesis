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

TH1* project_hist(TH2* hist, const std::string& projection) {
  return hist->ProjectionX(projection.c_str());
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

auto chisq(const int dim, const fs::path& file_path) -> void {
  auto* file {TFile::Open(file_path.c_str())};
  assert(file != nullptr && !file->IsZombie());

  auto pair {file_path.parent_path().stem().string()};

  auto truth_path {std::format("femto-universe-pair-task-track-track-mc-truth")};
  auto* truth_same {get_hist(file, std::format("{}/SameEvent/DeltaEtaDeltaPhi", truth_path))};
  auto* truth_mixed {get_hist(file, std::format("{}/MixedEvent/DeltaEtaDeltaPhi", truth_path))};
  assert(truth_same != nullptr && truth_mixed != nullptr);

  auto recon_path {std::format("femto-universe-pair-task-track-track-extended_{}_{}d", pair, dim)};
  auto* recon_same {get_hist(file, std::format("{}/SameEvent_MC/DeltaEtaDeltaPhi", recon_path))};
  auto* recon_mixed {get_hist(file, std::format("{}/MixedEvent_MC/DeltaEtaDeltaPhi", recon_path))};
  assert(recon_same != nullptr && recon_mixed != nullptr);

  auto* truth_corr = get_corr_func(truth_same, truth_mixed);
  assert(truth_corr != nullptr);

  auto* recon_corr = get_corr_func(recon_same, truth_same);
  assert(recon_corr != nullptr);

  auto chi2 {truth_corr->Chi2Test(recon_corr, "UW CHI2/NDF")};
  std::println("chi2: {}", chi2);
}

auto main(int argc, char** argv) -> int {
  std::string pair;
  std::string dim;
  std::string file;
  auto flag {0};

  while ((flag = getopt(argc, argv, "p:d:f:")) != -1) {
    switch (flag) {
    case 'p':
      pair = optarg;
      break;
    case 'd':
      dim = optarg;
      break;
    case 'f':
      file = optarg;
      break;
    default:
      return 1;
    }
  }

  chisq(std::stoi(dim), file);
  return 0;
}
