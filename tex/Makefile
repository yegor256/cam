# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

.SHELLFLAGS = -e -x -c
.ONESHELL:
SHELL=bash

TLROOT=$$(kpsewhich -var-value TEXMFDIST)
PACKAGES=ffcode to-be-determined href-ul bibcop iexec
REPO=yegor256/cam

zip: *.tex
	rm -rf package
	mkdir package
	cd package
	cp ../paper.tex .
	cp ../main.bib .
	for p in $(PACKAGES); do cp $(TLROOT)/tex/latex/$${p}/$${p}.sty .; done
	version=$$(curl --silent -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$(REPO)/releases/latest | jq -r '.tag_name')
	echo "Version is: $${version}"
	gsed -i "s|0\.0\.0|$${version}|g" paper.tex
	gsed -i "s|REPOSITORY|$(REPO)|g" paper.tex
	pdflatex -shell-escape -halt-on-error paper.tex > /dev/null
	bibtex paper
	pdflatex -halt-on-error paper.tex > /dev/null
	pdflatex -halt-on-error paper.tex > /dev/null
	rm -rf *.aux *.bcf *.blg *.fdb_latexmk *.fls *.log *.run.xml *.out *.exc
	zip -x paper.pdf -r paper-$${version}.zip *
	mv paper-$${version}.zip ..
	cd ..

clean:
	git clean -dfX
