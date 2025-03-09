.PHONY: report dev hist hist-all clean

all: hist-all report clean

report: main.tex
	latexmk -bibtex -pdf --silent --shell-escape main.tex
	make clean

dev: main.tex
	latexmk -pvc -bibtex -pdf --silent --shell-escape main.tex
	make clean

hist: datafiles.csv
	parallel --progress ./run {1} {2} \
		::: analysis/mc-closure-ratio.py analysis/corr-func.py \
		::: `cat datafiles.csv | fzf --layout=reverse -m`

hist-all: datafiles.csv
	parallel --progress ./run {1} {2} \
		::: analysis/mc-closure-ratio.py analysis/corr-func.py \
		::: `tail -n +2 datafiles.csv`

clean:
	latexmk -c main.tex
