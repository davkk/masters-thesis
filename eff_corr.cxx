#include <TFile.h>
#include <TFolder.h>
#include <TGrid.h>
#include <TGridResult.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TSystem.h>
#include <cassert>
#include <cmath>
#include <filesystem>
#include <format>
#include <string>

namespace fs = std::filesystem;

template <typename H>
H* get_histogram(TFile* file, const std::string& name) {
  return dynamic_cast<H*>(file->Get(name.c_str()));
}

template <typename H>
H* clone_histogram(H* hist, const std::string& name) {
  return dynamic_cast<H*>(hist->Clone(name.c_str()));
}

void eff_calc(const fs::path& results_path, const fs::path& reco_path, const fs::path& truth_path) {
  auto is_alien {false};
  if (results_path.string().starts_with("alien://")) {
    TGrid::Connect("alien://");
    is_alien = true;
  }

  auto* result_file {TFile::Open(results_path.c_str())};
  assert(result_file != nullptr && !result_file->IsZombie());

  auto now {
      std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count()
  };
  auto const output_path {
      (is_alien ? std::filesystem::current_path() : results_path.parent_path())
      / std::format("{}-effcor-{}.root", results_path.stem().string(), now)
  };
  auto* output_file {TFile::Open(output_path.c_str(), "RECREATE")};
  assert(output_file != nullptr && !output_file->IsZombie());

  // Retrieve reco and truth histograms
  const auto reco_true_path {fs::path(std::format("{}_MC", reco_path.c_str()))};
  auto* hist_reco_true {get_histogram<TH1F>(result_file, reco_true_path / "hPt_Primary")};
  assert(hist_reco_true);

  auto* hist_truth {get_histogram<TH1F>(result_file, truth_path / "hPt")};
  assert(hist_truth);

  assert(hist_reco_true->GetXaxis()->GetXmin() == hist_truth->GetXaxis()->GetXmin());
  assert(hist_reco_true->GetXaxis()->GetBinWidth(1) == hist_truth->GetXaxis()->GetBinWidth(1));

  // Calculate Efficiency
  auto* hist_eff {clone_histogram(hist_reco_true, "hEfficiency")};
  for (auto bin_idx {1}; bin_idx <= hist_eff->GetNbinsX(); ++bin_idx) {
    auto reco_value {hist_reco_true->GetBinContent(bin_idx)};
    auto truth_value {hist_truth->GetBinContent(bin_idx)};
    auto err_reco {hist_reco_true->GetBinError(bin_idx)};
    auto err_truth {hist_truth->GetBinError(bin_idx)};

    auto eff {(truth_value > 0) ? reco_value / truth_value : 0};
    // propagate: σ_eff^2 = (σ_reco/truth)^2 + (reco_value*σ_truth/truth^2)^2
    auto eff_err {
        (truth_value > 0) ? std::sqrt(
                                ((err_reco / truth_value) * (err_reco / truth_value))
                                + ((reco_value * err_truth / (truth_value * truth_value))
                                   * (reco_value * err_truth / (truth_value * truth_value)))
                            )
                          : 0
    };

    hist_eff->SetBinContent(bin_idx, eff);
    hist_eff->SetBinError(bin_idx, eff_err);
  }
  output_file->WriteTObject(hist_eff);

  // Calculate Contamination
  auto* hist_reco {get_histogram<TH1F>(result_file, reco_path / "hPt")};

  const auto to_project {std::vector<std::vector<std::string>> {
      {"hDCAxy_Primary"},
      {"hDCAxy_Daughter", "hDCAxy_DaughterLambda", "hDCAxy_DaughterSigmaplus"},
      {"hDCAxy_Material"},
      {"hDCAxy_Fake"},
  }};

  for (const auto& hist_names : to_project) {
    TH1D* result_x {nullptr};
    for (const auto& hist_name : hist_names) {
      auto* hist {get_histogram<TH2F>(result_file, reco_true_path / hist_name)};
      assert(hist);
      assert(hist->GetXaxis()->GetBinWidth(1) == hist_reco->GetXaxis()->GetBinWidth(1));
      assert(hist->GetXaxis()->GetBinLowEdge(1) == hist_reco->GetXaxis()->GetBinLowEdge(1));

      const auto split {hist_name.find_first_of('_')};
      assert(split != std::string::npos);

      const auto name {hist_name.substr(split + 1)};
      auto* hist_x {hist->ProjectionX(("h" + name).c_str())};

      for (auto bin_idx {1}; bin_idx <= hist_x->GetNbinsX(); ++bin_idx) {
        auto cont_value {hist_x->GetBinContent(bin_idx)};
        auto reco_value {hist_reco->GetBinContent(bin_idx)};
        auto sigma_value {hist_x->GetBinError(bin_idx)};
        auto sigma_reco {hist_reco->GetBinError(bin_idx)};

        auto cont {(reco_value > 0) ? cont_value / reco_value : 0};
        // propagate: σ_cont^2 = (σ_count/reco)^2 + (cont_count*σ_reco/reco^2)^2
        auto cont_err {
            (reco_value > 0) ? std::sqrt(
                                   ((sigma_value / reco_value) * (sigma_value / reco_value))
                                   + ((cont_value * sigma_reco / (reco_value * reco_value))
                                      * (cont_value * sigma_reco / (reco_value * reco_value)))
                               )
                             : 0
        };

        hist_x->SetBinContent(bin_idx, cont);
        hist_x->SetBinError(bin_idx, cont_err);
      }

      if (result_x == nullptr) {
        result_x = hist_x;
      } else {
        result_x->Add(hist_x);
      }
    }
    output_file->WriteTObject(result_x);
  }

  auto* hist_secondary_x {get_histogram<TH1D>(output_file, "hDaughter")};
  auto* hist_material_x {get_histogram<TH1D>(output_file, "hMaterial")};
  assert(hist_secondary_x);
  assert(hist_material_x);

  hist_secondary_x->Add(hist_material_x);

  // Calculate Weights
  auto* weights {clone_histogram(hist_secondary_x, "hWeights")};
  for (auto bin_idx {1}; bin_idx <= weights->GetNbinsX(); ++bin_idx) {
    auto cont_value {hist_secondary_x->GetBinContent(bin_idx)};
    auto eff_value {hist_eff->GetBinContent(bin_idx)};
    auto sigma_cont {hist_secondary_x->GetBinError(bin_idx)};
    auto sigma_eff {hist_eff->GetBinError(bin_idx)};

    auto weight {(eff_value > 0) ? (1 - cont_value) / eff_value : 1};
    // propagate: σ_w^2 = (σ_cont/eff)^2 + ((1-cont)*σ_eff/eff^2)^2
    auto weight_err {
        (eff_value > 0) ? std::sqrt(
                              ((sigma_cont / eff_value) * (sigma_cont / eff_value))
                              + (((1 - cont_value) * sigma_eff / (eff_value * eff_value))
                                 * ((1 - cont_value) * sigma_eff / (eff_value * eff_value)))
                          )
                        : 0
    };

    weights->SetBinContent(bin_idx, weight);
    weights->SetBinError(bin_idx, weight_err);
  }
  output_file->WriteTObject(weights);

  output_file->Close();
  result_file->Close();
}

int main(int argc, char** argv) {
  assert(argc == 4);
  eff_calc(argv[1], argv[2], argv[3]);
  return 0;
}
