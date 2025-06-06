#!/usr/bin/env bash

cat datafiles.csv \
| awk -F',' '$1 == 1 {print "data/"$3"/"$2"/"$6".root", $4, $2}' \
| parallel -k --colsep ' ' echo {3} {2} \`./chisq.out -f {1} -d {2}\` \
2>/dev/null
