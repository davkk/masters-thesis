#include <TFile.h>
#include <TFolder.h>
#include <TGrid.h>
#include <TGridResult.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TSystem.h>
#include <cassert>
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

void eff_calc(const std::string& results_path) {
  const auto task_name {"femto-universe-pair-task-track-track-extended"s};

  if (results_path.starts_with("alien://")) {
    TGrid::Connect("alien://");
  }

  auto* result_file = TFile::Open(results_path.c_str());
  assert(result_file != nullptr && !result_file->IsZombie());

  auto* output_file {TFile::Open("EfficiencyCorrection.root", "RECREATE")};
  assert(output_file != nullptr && !output_file->IsZombie());

  auto part_names {std::vector {"one", "two"}};

  // Process Each Particle
  for (size_t idx = 0; idx < 2; ++idx) {
    const auto* reco_dir {result_file->Get(std::format("{}/Tracks_{}_MC", task_name, part_names[idx]).c_str())};
    if (reco_dir == nullptr) {
      continue;
    }

    std::cout << "Processing " << part_names[idx] << '\n';

    // Retrieve reco and truth histograms
    auto* hist_reco {get_histogram<TH1F>(result_file, std::format("{}/Tracks_{}_MC/hPt", task_name, part_names[idx]))};
    assert(hist_reco);

    auto* hist_truth {
        get_histogram<TH1F>(result_file, std::format("{}/MCTruthTracks_{}/hPt", task_name, part_names[idx]))
    };
    assert(hist_truth);

    assert(hist_reco->GetXaxis()->GetXmin() == hist_truth->GetXaxis()->GetXmin());
    assert(hist_reco->GetXaxis()->GetBinWidth(1) == hist_truth->GetXaxis()->GetBinWidth(1));

    // Calculate Efficiency
    auto* hist_eff {clone_histogram(hist_reco, std::format("hEfficiency_part{}", idx + 1))};
    for (auto bin_idx {1}; bin_idx <= hist_eff->GetNbinsX(); ++bin_idx) {
      auto reco_value {hist_reco->GetBinContent(bin_idx)};
      auto truth_value {hist_truth->GetBinContent(bin_idx)};

      auto eff {(truth_value > 0) ? reco_value / truth_value : 0};
      hist_eff->SetBinContent(bin_idx, eff);
    }
    output_file->WriteTObject(hist_eff);

    // Calculate Contamination
    auto* hist_primaries {
        get_histogram<TH2F>(result_file, std::format("{}/Tracks_{}_MC/hDCAxy_Primary", task_name, part_names[idx]))
    };
    assert(hist_primaries);

    assert(hist_primaries->GetXaxis()->GetBinWidth(1) == hist_reco->GetXaxis()->GetBinWidth(1));
    assert(hist_primaries->GetXaxis()->GetBinLowEdge(1) == hist_reco->GetXaxis()->GetBinLowEdge(1));

    auto* hist_cont {hist_primaries->ProjectionX(std::format("hSecondaryContamination_part{}", idx + 1).c_str())};
    for (int bin_idx = 1; bin_idx <= hist_cont->GetNbinsX(); ++bin_idx) {
      auto cont_value {hist_cont->GetBinContent(bin_idx)};
      auto pt_value {hist_reco->GetBinContent(bin_idx)};
      hist_cont->SetBinContent(bin_idx, pt_value > 0 ? cont_value / pt_value : 0);
    }
    output_file->WriteTObject(hist_cont);

    assert(hist_cont->GetXaxis()->GetBinWidth(1) == hist_eff->GetXaxis()->GetBinWidth(1));
    assert(hist_cont->GetXaxis()->GetBinLowEdge(1) == hist_eff->GetXaxis()->GetBinLowEdge(1));

    // Calculate Weights
    auto* weights {clone_histogram(hist_cont, std::format("hWeights_part{}", idx + 1))};
    for (int bin_idx = 1; bin_idx <= weights->GetNbinsX(); ++bin_idx) {
      auto cont_value {hist_cont->GetBinContent(bin_idx)};
      auto eff_value {hist_eff->GetBinContent(bin_idx)};

      auto weight {(eff_value > 0) ? (1 - cont_value) / eff_value : 0};
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
  assert(argc == 2);
  const std::string results_path {std::string(argv[1])};

  eff_calc(results_path);

  return 0;
}
