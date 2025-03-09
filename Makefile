.PHONY: install report dev hist hist-all clean

install: pyproject.toml
	uv pip install pyproject.toml --system
	uv pip install -e . --system

report: main.tex
	latexmk -bibtex -pdf --silent --shell-escape main.tex
	make clean

dev: main.tex
	fd .py | entr make hist-all &
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

push: main.tex
	git add .
	git commit -m `date +%s`
	git push origin main

clean:
	latexmk -c main.tex
