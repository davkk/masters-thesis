#!/usr/bin/env bash

cat datafiles.csv \
| awk -F',' '$1 == 1 {print "data/"$3"/"$2"/"$5".root", "data/"$3"/"$2"/"$6".root", $2}' \
| parallel -k --colsep ' ' echo {3} \`./chisq.out -r {1} -t {2}\` \
2>/dev/null
