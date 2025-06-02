#include <TDirectory.h>
#include <TFile.h>
#include <TKey.h>
#include <unistd.h>
#include <iostream>

void remove_dir(const char* filename, const char* dirname) {
  // Open the file in update mode
  TFile* file = TFile::Open(filename, "UPDATE");
  if (!file || file->IsZombie()) {
    std::cout << "Error: Cannot open file \"" << filename << "\"\n";
    return;
  }

  // Check if the directory exists
  if (!file->GetDirectory(dirname)) {
    std::cout << "Error: Directory \"" << dirname << "\" not found in " << filename << "\n";
    file->Close();
    delete file;
    return;
  }

  // Delete all contents of the directory
  file->cd();
  file->Delete(Form("%s;*", dirname));  // remove all keys in the directory

  // Save changes and close the file
  file->Write();
  file->Close();
  delete file;
}

int main(int argc, char* argv[]) {
  const char* filename = "data.root";
  const char* dirname = "femto-universe_id01";
  int opt;

  while ((opt = getopt(argc, argv, "f:d:h")) != -1) {
    switch (opt) {
    case 'f':
      filename = optarg;
      break;
    case 'd':
      dirname = optarg;
      break;
    case 'h':
      std::cout << "Usage: " << argv[0] << " [OPTIONS]\n"
                << "  -f <file>     ROOT file to modify (default: data.root)\n"
                << "  -d <dirname>  Directory name to remove (default: femto-universe_id01)\n"
                << "  -h            Show this help message\n";
      return 0;
    default:
      std::cout << "Usage: " << argv[0] << " [-f file] [-d dirname] [-h]\n";
      return 1;
    }
  }

  std::cout << "Removing directory \"" << dirname << "\" from file \"" << filename << "\"\n";
  remove_dir(filename, dirname);
  return 0;
}
