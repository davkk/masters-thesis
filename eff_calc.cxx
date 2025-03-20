#include <TFile.h>
#include <TFolder.h>
#include <TGrid.h>
#include <TGridResult.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TSystem.h>
#include <cassert>
#include <filesystem>
#include <format>
#include <iostream>
#include <string>

using namespace std::string_literals;

template <typename H>
H* get_histogram(TFile* file, const std::string& name) {
  return dynamic_cast<H*>(file->Get(name.c_str()));
}

template <typename H>
H* clone_histogram(H* hist, const std::string& name) {
  return dynamic_cast<H*>(hist->Clone(name.c_str()));
}

void eff_calc(const std::string& results_path_str, const std::string& task_name) {
  auto is_alien {false};
  if (results_path_str.starts_with("alien://")) {
    TGrid::Connect("alien://");
    is_alien = true;
  }

  const auto results_path {std::filesystem::path(results_path_str)};

  auto* result_file = TFile::Open(results_path.c_str());
  assert(result_file != nullptr && !result_file->IsZombie());

  auto const output_path {
      (is_alien ? std::filesystem::current_path() : results_path.parent_path())  //
      / "EfficiencyCorrection.root"
  };
  auto* output_file {TFile::Open(output_path.c_str(), "RECREATE")};
  assert(output_file != nullptr && !output_file->IsZombie());

  auto part_names {std::vector {"one", "two"}};

  // Process Each Particle
  for (size_t idx = 0; idx < 2; ++idx) {
    std::cout << "Processing " << part_names[idx] << '\n';

    // Retrieve reco and truth histograms
    auto* hist_reco_mc {get_histogram<TH1F>(result_file, std::format("{}/Tracks_{}_MC/hPt", task_name, part_names[idx]))
    };
    auto* hist_truth {
        get_histogram<TH1F>(result_file, std::format("{}/MCTruthTracks_{}/hPt", task_name, part_names[idx]))
    };

    if (hist_reco_mc == nullptr || hist_truth == nullptr) {
      std::cout << "Skipping " << part_names[idx] << '\n';
      continue;
    }

    assert(hist_reco_mc);
    assert(hist_truth);

    assert(hist_reco_mc->GetXaxis()->GetXmin() == hist_truth->GetXaxis()->GetXmin());
    assert(hist_reco_mc->GetXaxis()->GetBinWidth(1) == hist_truth->GetXaxis()->GetBinWidth(1));

    // Calculate Efficiency
    auto* hist_eff {clone_histogram(hist_reco_mc, std::format("hEfficiency_part{}", idx + 1))};
    for (auto bin_idx {1}; bin_idx <= hist_eff->GetNbinsX(); ++bin_idx) {
      auto reco_value {hist_reco_mc->GetBinContent(bin_idx)};
      auto truth_value {hist_truth->GetBinContent(bin_idx)};

      auto eff {(truth_value > 0) ? reco_value / truth_value : 0};
      hist_eff->SetBinContent(bin_idx, eff);
    }
    output_file->WriteTObject(hist_eff);

    // Calculate Contamination
    // daughters + material
    auto* hist_reco {get_histogram<TH1F>(result_file, std::format("{}/Tracks_{}/hPt", task_name, part_names[idx]))};
    auto* hist_secondary {
        get_histogram<TH2F>(result_file, std::format("{}/Tracks_{}_MC/hDCAxy_Daughter", task_name, part_names[idx]))
    };
    auto* hist_material {
        get_histogram<TH2F>(result_file, std::format("{}/Tracks_{}_MC/hDCAxy_Material", task_name, part_names[idx]))
    };

    assert(hist_reco);
    assert(hist_secondary);

    assert(hist_secondary->GetXaxis()->GetBinWidth(1) == hist_reco->GetXaxis()->GetBinWidth(1));
    assert(hist_secondary->GetXaxis()->GetBinLowEdge(1) == hist_reco->GetXaxis()->GetBinLowEdge(1));

    auto* hist_secondary_x {hist_secondary->ProjectionX(std::format("hSecondaryContamination_part{}", idx + 1).c_str())
    };
    hist_secondary_x->Add(hist_material->ProjectionX());

    for (int bin_idx = 1; bin_idx <= hist_secondary_x->GetNbinsX(); ++bin_idx) {
      auto cont_value {hist_secondary_x->GetBinContent(bin_idx)};
      auto reco_value {hist_reco->GetBinContent(bin_idx)};
      hist_secondary_x->SetBinContent(bin_idx, reco_value > 0 ? cont_value / reco_value : 0);
    }

    output_file->WriteTObject(hist_secondary_x);

    auto* hist_fake {
        get_histogram<TH2F>(result_file, std::format("{}/Tracks_{}_MC/hDCAxy_Fake", task_name, part_names[idx]))
    };

    assert(hist_fake);

    assert(hist_fake->GetXaxis()->GetBinWidth(1) == hist_reco->GetXaxis()->GetBinWidth(1));
    assert(hist_fake->GetXaxis()->GetBinLowEdge(1) == hist_reco->GetXaxis()->GetBinLowEdge(1));

    auto* hist_fake_x {hist_secondary->ProjectionX(std::format("hFake_part{}", idx + 1).c_str())};

    for (int bin_idx = 1; bin_idx <= hist_fake_x->GetNbinsX(); ++bin_idx) {
      auto cont_value {hist_secondary_x->GetBinContent(bin_idx)};
      auto reco_value {hist_reco->GetBinContent(bin_idx)};
      hist_fake_x->SetBinContent(bin_idx, reco_value > 0 ? cont_value / reco_value : 0);
    }

    output_file->WriteTObject(hist_fake_x);

    assert(hist_secondary_x->GetXaxis()->GetBinWidth(1) == hist_eff->GetXaxis()->GetBinWidth(1));
    assert(hist_secondary_x->GetXaxis()->GetBinLowEdge(1) == hist_eff->GetXaxis()->GetBinLowEdge(1));

    // Calculate Weights
    auto* weights {clone_histogram(hist_secondary_x, std::format("hWeights_part{}", idx + 1))};
    for (int bin_idx = 1; bin_idx <= weights->GetNbinsX(); ++bin_idx) {
      auto cont_value {hist_secondary_x->GetBinContent(bin_idx)};
      auto eff_value {hist_eff->GetBinContent(bin_idx)};

      auto weight {(eff_value > 0) ? (1 - cont_value) / eff_value : 1};
      weights->SetBinContent(bin_idx, weight);
    }
    output_file->WriteTObject(weights);
  }

  output_file->Close();
  result_file->Close();

  delete output_file;
  delete result_file;
}

int main(int argc, char** argv) {
  assert(argc == 3);
  eff_calc(std::string(argv[1]), std::string(argv[2]));
  return 0;
}
