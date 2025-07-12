#!/usr/bin/env bash

cat datafiles.csv \
| awk -F',' '$1 == 1 && $2 == 1 {print "data/"$4"/"$3"/"$5".root", "data/"$4"/"$3"/"$6".root", "data/"$4"/"$3"/"$7".root", $3}' \
| parallel -k --colsep ' ' echo {4} \`./chisq.out -n {1} -c {2} -t {3}\` \
2>/dev/null
