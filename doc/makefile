.PHONY: build build_text build_api

build : build_tex build_api

# The challenge callback api documentation

build_api: api/programmatoid_challenge.html

api/programmatoid_challenge.html: ../braincraft/programmatoid_challenge.py
	rm -rf api/* ; ~/.local/bin/pdoc --logo ../../data/braincraft0.png --logo-link 'https://github.com/rougier/braincraft' --favicon ../../data/braincraft-favicon.png   --footer-text "`date +'%Y-%m-%d %H:%M:%S'` version"  $^ -o api
	rm -f api/index.html
	mv $@ $@~ ; sed < $@~ > $@ 's/....custom.css.../.attribution { display: none!important; }/'

# The programmatoid latex document

build_tex: $(patsubst %.odg,%.png,$(wildcard tex/*.odg)) $(patsubst %.mpl,%.mpl.out.txt,$(wildcard tex/*.mpl)) $(patsubst %.tex,%.pdf,$(wildcard tex/*.tex)) tex/programmatoid.png

tex/%.pdf: tex/%.tex $(wildcard tex/*.odg) $(wildcard tex/*.mpl) $(wildcard tex/*.bib) 
	cd tex; pdflatex -halt-on-error  -draftmode  $* ;  bibtex $* ; pdflatex -halt-on-error  -draftmode $* ; pdflatex -halt-on-error  $* ; grep -i undefined $*.log ; rm -f $*.aux $*.bbl $*.blg $*.toc ; ok=

tex/%.mpl.out.txt: tex/%.mpl
	cd tex ; maple ../$^ > ../$@

tex/%.png : tex/%.odg
	@libreoffice --headless --convert-to png --outdir $(@D) $^

tex/programmatoid.png: tex/programmatoid.pdf
	pdftk $^ cat 1 output programmatoid-0.pdf
	convert programmatoid-0.pdf $@
	rm programmatoid-0.pdf

