
# The doc files to build

build : api/programmatoid_challenge.html  tex/index.html logs

clean :
	rm -f api/programmatoid_challenge.html  tex/index.html

# The challenge callback api documentation

api/programmatoid_challenge.html: ../braincraft/programmatoid_challenge.py
	rm -rf api/* ; ~/.local/bin/pdoc --logo ../../data/braincraft0.png --logo-link 'https://github.com/rougier/braincraft' --favicon ../../data/braincraft-favicon.png   --footer-text "`date +'%Y-%m-%d %H:%M:%S'` version"  $^ -o api
	mv $@ $@~ ; sed < $@~ > $@ 's/....custom.css.../.attribution { display: none!important; }/'

# The programmatoid latex document

tex/index.html: $(patsubst %.odg,%.png,$(wildcard tex/*.odg)) $(patsubst %.mpl,%.mpl.out.txt,$(wildcard tex/*.mpl)) $(patsubst %.tex,%.pdf,$(wildcard tex/*.tex)) tex/programmatoid.png
	cd tex ; (echo '<ul>' ; for f in `ls *.pdf *.mpl.out.txt` ; do echo "<li><a href='$$f'>$$f</a></li>" ; done ; echo '</ul>') > ../$@

tex/programmatoid.png: tex/programmatoid.pdf
	pdftk $^ cat 1 output programmatoid-0.pdf
	convert programmatoid-0.pdf $@
	rm programmatoid-0.pdf

tex/%.pdf: tex/%.tex $(wildcard tex/*.odg) $(wildcard tex/*.mpl) $(wildcard *.bib) 
	cd tex; pdflatex -halt-on-error  -draftmode  $* ;  bibtex $* ; pdflatex -halt-on-error  -draftmode $* ; pdflatex -halt-on-error  $* ; grep -i undefined $*.log ; ok=

tex/%.mpl.out.txt: tex/%.mpl
	cd tex ; maple ../$^ > ../$@

tex/%.png : tex/%.odg
	@libreoffice --headless --convert-to png --outdir $(@D) $^

