.PHONY: install report dev hist hist-all clean

SCRIPTS := analysis/mc-closure-ratio.py analysis/corr-func.py
TEX_FLAGS := -bibtex -pdf --silent --shell-escape

install: pyproject.toml
	uv pip install pyproject.toml --system
	uv pip install -e . --system

report: main.tex
	latexmk ${TEX_FLAGS} main.tex
	make clean

dev: main.tex
	fd .py | entr make hist-all &
	latexmk -pvc ${TEX_FLAGS} main.tex
	make clean

hist: datafiles.csv
	parallel --progress ./run {1} {2} \
		::: ${SCRIPTS} \
		::: `cat datafiles.csv | fzf --layout=reverse -m`

hist-all: datafiles.csv
	parallel --progress ./run {1} {2} \
		::: ${SCRIPTS} \
		::: `tail -n +2 datafiles.csv`

push: main.tex
	git add .
	git commit -m `date +%s`
	git push origin main

clean:
	latexmk -c main.tex
