.PHONY: install report dev hist hist-all push

SCRIPTS_DATASET := analysis/eff_cont_1d.py analysis/weights.py
SCRIPTS_RUN := analysis/mc_closure_ratio.py \
			   analysis/corr_func.py \
			   analysis/contamination.py \
			   analysis/eff_cont_2d.py

install: pyproject.toml
	uv venv
	uv sync

report: typst/main.typ
	typst compile typst/main.typ --root . --font-path fonts/ --input INDEX=$(INDEX) --input EVIDENCE=$(EVIDENCE)

dev: typst/main.typ
	fd .py | entr make hist-all &
	typst watch typst/main.typ --root . --font-path fonts/ --input INDEX=$(INDEX) --input EVIDENCE=$(EVIDENCE)

hist: datafiles.csv
	parallel --progress ./run.sh {1} {2} \
		::: ${SCRIPTS_RUN} \
		::: `cat datafiles.csv | fzf --layout=reverse -m`

hist-all: datafiles.csv
	python analysis/chisq_test.py
	parallel --progress python {} `grep ^1, datafiles.csv` ::: ${SCRIPTS_DATASET}
	parallel --progress ./run.sh {1} {2} \
		::: ${SCRIPTS_RUN} \
		::: `tail -n +2 datafiles.csv | grep -e "^1,"`

push:
	git add .
	git commit -m "update `date +%s`"
	git push origin main
