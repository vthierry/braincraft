
# The doc files to build

build : api/challenge_callback.html  tex/index.html logs

clean :
	rm -f api/challenge_callback.html  tex/index.html

# The challenge callback api documentation

api/challenge_callback.html: ../braincraft/challenge_callback.py
	rm -rf api/* ; ~/.local/bin/pdoc --logo ../../data/braincraft0.png --logo-link 'https://github.com/rougier/braincraft' --favicon ../../data/braincraft-favicon.png   --footer-text "`date +'%Y-%m-%d %H:%M:%S'` version"  $^ -o api
	mv $@ $@~ ; sed < $@~ > $@ 's/....custom.css.../.attribution { display: none!important; }/'

# The programmatic-solution latex document

tex/index.html: $(patsubst %.odg,%.png,$(wildcard tex/*.odg)) $(patsubst %.mpl,%.mpl.out.txt,$(wildcard tex/*.mpl)) $(patsubst %.tex,%.pdf,$(wildcard tex/*.tex)) 
	cd tex ; (echo '<ul>' ; for f in `ls *.pdf *.mpl.out.txt` ; do echo "<li><a href='$$f'>$$f</a></li>" ; done ; echo '</ul>') > ../$@

tex/%.pdf: tex/%.tex $(wildcard tex/*.odg) $(wildcard tex/*.mpl) $(wildcard *.bib) 
	cd tex; pdflatex -halt-on-error  -draftmode  $* ;  bibtex $* ; pdflatex -halt-on-error  -draftmode $* ; pdflatex -halt-on-error  $* ; grep -i undefined $*.log ; ok=

tex/%.mpl.out.txt: tex/%.mpl
	cd tex ; maple ../$^ > ../$@

tex/%.png : tex/%.odg
	@libreoffice --headless --convert-to png --outdir $(@D) $^

# The python codes output log

what = env1_player_programmatoid

logs: $(patsubst %,log/%.py.out.txt,$(what))

log/%.py.out.txt: ../braincraft/%.py 
	cd ../braincraft ; python3 $*.py 2>&1 | tee ../doc/log/$*.py.out.txt


