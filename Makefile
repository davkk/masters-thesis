.PHONY: install report dev hist hist-all clean

SCRIPTS := analysis/mc-closure-ratio.py analysis/corr-func.py analysis/efficiency-pt.py
TEX_FLAGS := -bibtex -pdf --silent --shell-escape

install: pyproject.toml
	uv venv
	uv pip install -r pyproject.toml
	uv pip install -e .

report: tex/main.tex
	cd tex && latexmk ${TEX_FLAGS} main.tex
	make clean

dev: tex/main.tex
	fd .py | entr make hist-all &
	cd tex && latexmk -pvc ${TEX_FLAGS} main.tex
	make clean

hist: datafiles.csv
	parallel --progress ./run.sh {1} {2} \
		::: ${SCRIPTS} \
		::: `cat datafiles.csv | fzf --layout=reverse -m`

hist-all: datafiles.csv
	parallel --progress ./run.sh {1} {2} \
		::: ${SCRIPTS} \
		::: `tail -n +2 datafiles.csv`

push:
	git add .
	git commit -m "update `date +%s`"
	git push origin main

clean:
	cd tex && latexmk -c main.tex
