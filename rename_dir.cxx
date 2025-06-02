#include <TDirectory.h>
#include <TFile.h>
#include <TKey.h>
#include <TList.h>
#include <unistd.h>
#include <iostream>

// Recursive helper: copy everything under 'src' into 'dest'
static void CopyDirectoryRecursive(TDirectory* src, TDirectory* dest) {
  // Loop over all keys in 'src'
  TList* keyList = src->GetListOfKeys();
  TIter next(keyList);
  TKey* key;
  while ((key = (TKey*)next())) {
    // Ensure we're reading from the correct source directory
    src->cd();
    TObject* obj = key->ReadObj();  // this may change gDirectory internally

    if (!obj) {
      continue;
    }

    // If this object is itself a directory, create a subdirectory in 'dest' and recurse
    if (obj->InheritsFrom(TDirectory::Class())) {
      // Create matching subdirectory under 'dest'
      dest->cd();
      TDirectory* newSub = dest->mkdir(obj->GetName());  // same name as in 'src'
      // Recurse into it
      CopyDirectoryRecursive(static_cast<TDirectory*>(obj), newSub);
      delete obj;
    } else {
      // It's a “leaf” object (histogram, TTree, etc.)
      dest->cd();
      obj->Write(key->GetName());
      delete obj;
    }
  }
}

void rename_directory(const char* filename, const char* oldname, const char* newname) {
  // 1) Open the ROOT file in update mode
  TFile* file = TFile::Open(filename, "UPDATE");
  if (!file || file->IsZombie()) {
    std::cout << "Error: cannot open file \"" << filename << "\"\n";
    return;
  }

  // 2) Locate the “old” directory
  TDirectory* oldDir = file->GetDirectory(oldname);
  if (!oldDir) {
    std::cout << "Error: directory \"" << oldname << "\" not found in " << filename << "\n";
    file->Close();
    delete file;
    return;
  }

  // 3) Make sure “new” does not yet exist
  if (file->GetDirectory(newname)) {
    std::cout << "Error: directory \"" << newname << "\" already exists in " << filename << "!\n";
    file->Close();
    delete file;
    return;
  }

  // 4) Create the new, empty directory at top‐level
  file->cd();
  TDirectory* newDir = file->mkdir(newname);
  if (!newDir) {
    std::cout << "Error: failed to create directory \"" << newname << "\" in " << filename << "\n";
    file->Close();
    delete file;
    return;
  }

  // 5) Recursively copy everything from oldDir → newDir
  CopyDirectoryRecursive(oldDir, newDir);

  // 6) Remove all keys under oldDir, then delete the directory node itself
  file->cd();
  // Delete every key inside “oldname” (use wildcard “;*”)
  // This removes all objects (including subdirectories) under oldDir
  file->Delete(Form("%s;*", oldname));
  // Now oldDir is empty, so remove the directory tag
  file->rmdir(oldname);

  // 7) Write out and close
  file->Write();
  file->Close();
  delete file;

  std::cout << "Successfully renamed directory from \"" << oldname << "\" to \"" << newname << "\" in \"" << filename
            << "\"\n";
}

int main(int argc, char* argv[]) {
  const char* filename = "data.root";
  const char* oldname = "femto-universe_id01";
  const char* newname = "femto-universe";
  int opt;

  // Command‐line parsing
  while ((opt = getopt(argc, argv, "f:o:n:h")) != -1) {
    switch (opt) {
    case 'f':
      filename = optarg;
      break;
    case 'o':
      oldname = optarg;
      break;
    case 'n':
      newname = optarg;
      break;
    case 'h':
      std::cout << "Usage: " << argv[0] << " [OPTIONS]\n"
                << "  -f <file>     ROOT file to modify (default: data.root)\n"
                << "  -o <oldname>  Old directory name (default: femto-universe_id01)\n"
                << "  -n <newname>  New directory name (default: femto-universe)\n"
                << "  -h            Show this help message\n";
      return 0;
    default:
      std::cout << "Usage: " << argv[0] << " [-f file] [-o oldname] [-n newname] [-h]\n";
      return 1;
    }
  }

  std::cout << "Renaming directory \"" << oldname << "\" → \"" << newname << "\" in file \"" << filename << "\"\n";

  rename_directory(filename, oldname, newname);
  return 0;
}
