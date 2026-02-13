
# The doc files to build

build : api/index.html  tex/index.html logs

# The challenge callback api documentation

api/index.html: ../braincraft/challenge_callback.py
	rm -rf api/* ; ~/.local/bin/pdoc $^ -o api

# The programmatic-solution latex document

tex/index.html: $(patsubst %.tex,%.pdf,$(wildcard tex/*.tex)) $(patsubst %.mpl,%.mpl.out.txt,$(wildcard tex/*.mpl))
	cd tex ; (echo '<ul>' ; for f in `ls *.pdf *.mpl.out.txt` ; do echo "<li><a href='$$f'>$$f</a></li>" ; done ; echo '</ul>') > ../$@

tex/%.pdf: tex/%.tex
	cd tex; pdflatex $*.tex ;  pdflatex $*.tex ; rm -f *.aux *.toc *.log

tex/%.mpl.out.txt: tex/%.mpl
	maple $^ > $@

# The python codes output log

what = env1_player_programmatoid

logs: $(patsubst %,log/%.py.out.txt,$(what))

log/%.py.out.txt: ../braincraft/%.py 
	cd ../braincraft ; python3 $*.py 2>&1 | tee ../doc/log/$*.py.out.txt


