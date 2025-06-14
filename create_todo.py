#!/usr/bin/env python3

import sys
from pathlib import Path

import fitz

path = Path(sys.argv[1])
out = open(path.with_suffix(".md"), "w")
# out = sys.stdout

with fitz.open(path) as doc, out as outfile:
    for page in doc:
        for annot in page.annots():
            context = None
            comment = None

            match annot.type[0]:
                case fitz.PDF_ANNOT_HIGHLIGHT:  # type: ignore
                    context = page.get_textbox(annot.rect)
                    comment = annot.info["content"]
                case fitz.PDF_ANNOT_TEXT:  # type: ignore
                    comment = annot.info["content"]
                case _:
                    comment = "<ink annotation>"

            print(f"#### PAGE {(page.number or 0) + 1} ####\n", file=outfile)
            if context:
                for line in context.split("\r"):
                    print(f"> {line.strip()}", file=outfile)
                print(file=outfile)

            if comment:
                for line in comment.split("\r"):
                    print(f"{line.strip()}", file=outfile)
                print(file=outfile)

            print(file=outfile)
