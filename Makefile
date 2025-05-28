.PHONY: install report dev hist hist-all clean

SCRIPTS := analysis/mc_closure_ratio.py \
		   analysis/corr_func.py \
		   analysis/contamination.py

# TEX_FLAGS := -f -bibtex -pdf --silent --shell-escape

install: pyproject.toml
	uv venv
	uv sync

report: typst/main.typ
	# cd tex && latexmk ${TEX_FLAGS} main.tex
	typst compile typst/main.typ --root .
	make clean

dev: typst/main.typ
	fd .py | entr make hist-all &
	# cd tex && latexmk -pvc ${TEX_FLAGS} main.tex
	typst watch typst/main.typ --root . --input INDEX=$(INDEX) --input EVIDENCE=$(EVIDENCE)
	make clean

hist: datafiles.csv
	parallel --progress ./run.sh {1} {2} \
		::: ${SCRIPTS} \
		::: `cat datafiles.csv | fzf --layout=reverse -m`

hist-all: datafiles.csv
	parallel --progress python analysis/eff_cont.py {/.} ::: data/*
	parallel --progress ./run.sh {1} {2} \
		::: ${SCRIPTS} \
		::: `tail -n +2 datafiles.csv | grep -e "^1,"`

push:
	git add .
	git commit -m "update `date +%s`"
	git push origin main

clean:
	cd tex && latexmk -c main.tex
