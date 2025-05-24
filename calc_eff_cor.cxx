#include <TFile.h>
#include <TFolder.h>
#include <TGrid.h>
#include <TGridResult.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TH3F.h>
#include <TSystem.h>
#include <unistd.h>

#include <cassert>
#include <cmath>
#include <filesystem>
#include <format>
#include <iostream>
#include <string>

namespace fs = std::filesystem;

auto* get_hist(TFile* file, const std::string& name) {
  return dynamic_cast<TH3*>(file->Get(name.c_str()));
}

auto* project_hist(TH3* hist, const std::string& projection) {
  return hist->Project3D(projection.c_str());
}

template <typename H>
H* clone_hist(H* hist, const std::string& name) {
  return dynamic_cast<H*>(hist->Clone(name.c_str()));
}

auto for_each_bin(TH1* hist, auto func) -> void {
  if (hist->GetDimension() == 1) {
    for (auto pt {1}; pt <= hist->GetNbinsX(); ++pt) {
      func(pt, 0, 0);
    }
  } else if (hist->GetDimension() == 2) {
    for (auto pt {1}; pt <= hist->GetNbinsX(); ++pt) {
      for (auto eta {1}; eta <= hist->GetNbinsY(); ++eta) {
        func(pt, eta, 0);
      }
    }
  } else if (hist->GetDimension() == 3) {
    for (auto pt {1}; pt <= hist->GetNbinsX(); ++pt) {
      for (auto eta {1}; eta <= hist->GetNbinsY(); ++eta) {
        for (auto mult {1}; mult <= hist->GetNbinsZ(); ++mult) {
          func(pt, eta, mult);
        }
      }
    }
  } else {
    assert(false && "should not happen");
  }
}

auto set_titles(TH1* hist, const std::string& projection) -> void {
  auto* X {hist->GetXaxis()};
  auto* Y {hist->GetYaxis()};
  auto* Z {hist->GetZaxis()};

  X->SetTitle("#it{p}_{T} (GeV/#it{c})");

  if (hist->GetDimension() == 2) {
    if (projection == "yx") {
      Y->SetTitle("#it{#eta}");
    } else if (projection == "zx") {
      Y->SetTitle("mult");
    }
  } else if (hist->GetDimension() == 3) {
    Y->SetTitle("#it{#eta}");
    Z->SetTitle("mult");
  }
}

auto calc_eff_cor(const fs::path& results_path, const fs::path& hist_path, const std::string& projection) -> void {
  assert(!results_path.empty() && !hist_path.empty());
  if (projection != "" && projection != "x" && projection != "yx" && projection != "zx") {
    std::cerr << "Error: projection must be one of: x, yx, zx\n";
    std::exit(1);
    return;
  }

  auto is_alien {false};
  if (results_path.string().starts_with("alien://")) {
    TGrid::Connect("alien://");
    is_alien = true;
  }

  auto* results_file {TFile::Open(results_path.c_str())};
  assert(results_file != nullptr && !results_file->IsZombie());

  using clock = std::chrono::system_clock;
  using ms = std::chrono::milliseconds;
  auto now {duration_cast<ms>(clock::now().time_since_epoch()).count()};
  auto output_path {is_alien ? std::filesystem::current_path() : results_path.parent_path()};
  output_path /= std::format("{}-effcor-{}.root", results_path.stem().string(), now);

  auto* output_file {TFile::Open(output_path.c_str(), "RECREATE")};
  assert(output_file != nullptr && !output_file->IsZombie());

  auto* hist_truth_3d {get_hist(results_file, hist_path / "hMCTruth")};
  auto* hist_primary_3d {get_hist(results_file, hist_path / "hPrimary")};
  auto* hist_secondary_3d {get_hist(results_file, hist_path / "hSecondary")};
  auto* hist_material_3d {get_hist(results_file, hist_path / "hMaterial")};

  assert(hist_truth_3d);
  assert(hist_primary_3d);
  assert(hist_secondary_3d);
  assert(hist_material_3d);

  hist_secondary_3d->Add(hist_material_3d);

  TH1* hist_truth {hist_truth_3d};
  TH1* hist_primary {hist_primary_3d};
  TH1* hist_secondary {hist_secondary_3d};

  if (!projection.empty()) {
    hist_primary = project_hist(hist_primary_3d, projection);
    hist_secondary = project_hist(hist_secondary_3d, projection);
    hist_truth = project_hist(hist_truth_3d, projection);
  }

  auto* hist_total {clone_hist(hist_primary, "hTotal")};
  hist_total->Add(hist_secondary);

  auto* hist_eff {clone_hist(hist_primary, "hEfficiency")};
  hist_eff->Reset();
  set_titles(hist_eff, projection);

  auto* hist_cont {clone_hist(hist_primary, "hSecondaryCont")};
  hist_cont->Reset();
  set_titles(hist_cont, projection);

  auto* hist_wei {clone_hist(hist_primary, "hWeights")};
  hist_wei->Reset();
  set_titles(hist_wei, projection);

  for_each_bin(hist_primary, [&](int x, int y, int z) {
    auto prim_val {hist_primary->GetBinContent(x, y, z)};
    auto prim_err {hist_primary->GetBinError(x, y, z)};

    auto sec_val {hist_secondary->GetBinContent(x, y, z)};
    auto sec_err {hist_secondary->GetBinError(x, y, z)};

    auto truth_val {hist_truth->GetBinContent(x, y, z)};
    auto truth_err {hist_truth->GetBinError(x, y, z)};

    auto eff_val {0.};
    auto eff_err {0.};
    if (truth_val > 0) {
      eff_val = prim_val / truth_val;
      eff_err
          = std::sqrt(std::pow(prim_err / truth_val, 2) + std::pow((prim_val * truth_err / std::pow(truth_val, 2)), 2));
    }

    hist_eff->SetBinContent(x, y, z, eff_val);
    hist_eff->SetBinError(x, y, z, eff_err);

    auto total_val {prim_val + sec_val};
    auto total_err {std::hypot(prim_err, sec_err)};

    auto cont_val {0.};
    auto cont_err {0.};
    if (total_val > 0) {
      cont_val = sec_val / total_val;
      cont_err
          = std::sqrt(std::pow(sec_err / total_val, 2) + std::pow((sec_val * total_err / std::pow(total_val, 2)), 2));
    }

    hist_cont->SetBinContent(x, y, z, cont_val);
    hist_cont->SetBinError(x, y, z, cont_err);

    auto wei_val {0.};
    auto wei_err {0.};
    if (eff_val > 0) {
      wei_val = (1 - cont_val) / eff_val;
      wei_err
          = std::sqrt(std::pow(cont_err / eff_val, 2) + std::pow((1 - cont_val) * eff_err / std::pow(eff_val, 2), 2));
    }

    hist_wei->SetBinContent(x, y, z, wei_val);
    hist_wei->SetBinError(x, y, z, wei_err);
  });

  output_file->WriteTObject(hist_eff);
  output_file->WriteTObject(hist_cont);
  output_file->WriteTObject(hist_wei);

  output_file->Close();
  results_file->Close();
}

auto print_usage(const char* name) -> void {
  std::cerr << "Usage: " << name << "\n"
            << "  -f <path to results ROOT file>\n"
            << "  -d <path to directory within file>\n"
            << "  -p <projection> [optional, default: no projection, 3D histogram]\n"
            << "    Available projections:\n"
            << "      x - projection onto pT axis (1D histogram)\n"
            << "      yx - projection onto pT, eta (2D histogram)\n"
            << "      zx - projection onto pT, mult (2D histogram)\n";
}

int main(int argc, char** argv) {
  std::string results;
  std::string hist;
  std::string proj;
  auto flag {0};

  while ((flag = getopt(argc, argv, "f:d:p:")) != -1) {
    switch (flag) {
    case 'f':
      results = optarg;
      break;
    case 'd':
      hist = optarg;
      break;
    case 'p':
      proj = optarg;
      break;
    default:
      print_usage(argv[0]);
      return 1;
    }
  }

  if (results.empty() || hist.empty()) {
    print_usage(argv[0]);
    return 1;
  }

  calc_eff_cor(results, hist, proj);
  return 0;
}
