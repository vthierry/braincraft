#
# Gathers all commands regarding using the braincraft challenge as a programmatoid benchmark
#
# Here: https://github.com/vthierry/braincraft/programmatoid
# Doc:  https://makefiletutorial.com
#
define TODO

Faire manip avec 10 runs et sans timeout

Changer de variable pour les omega * f(…) apres 1ers teste programmatoid

endef

default: build

## Configures properly the makefile in silent mode, with bash, avoiding spurious paralleism, with automatic usage

.SILENT: $(shell sed -n 's/^\([^:]*\):.*/\1/p' < makefile)

export SHELL := /bin/bash

.NOTPARALLEL:

usage: # Shows the makefile usage.
	echo -e 'Usage: make $$command\nCommands:'
	sed -n 's/^\([a-z]*: *\)[^#]*#\(.*\)/  \1\2/p' < makefile

## git_sync

sync: # Synchronizes files with the github repository.
	cd doc ; rm -f *.aux *.bbl *.blg *.out *.log *.toc *.nav *.snm
	rm -f `find -name 'nohup.out' -o -name '*~'`
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

## build_all

build: # Builds all test, demo and documentation files.
	$(MAKE) -s $(BUILD)

BUILD = \
	../public/api/programmatoid_utils.html \
	$(BUILD_TEX) \
	$(BUILD_DEMO)

## build_api

../public/api/programmatoid_utils.html: ./src/programmatoid_utils.py
	rm -rf $(@D)/* ; pdoc --logo ../data/braincraft0.png --logo-link 'https://github.com/rougier/braincraft' --favicon ../data/braincraft-favicon.png  --footer-text "`date +'%Y-%m-%d %H:%M:%S'` version"  $^ -o ../public/api
	mv $@ $@~ ; sed < $@~ > $@ 's/....custom.css.../.attribution { display: none!important; }/'
	git add $(@D)

## build_tex

BUILD_TEX := \
  $(patsubst %.odg,%.png,$(wildcard doc/*.odg)) \
  $(patsubst %.mpl,%.mpl.out.txt,$(wildcard doc/*.mpl)) \
  ../public/programmatoid.png \
  ../public/programmatoid-slides.png

../public/%.pdf: doc/%.tex $(wildcard doc/*.odg) $(wildcard doc/*.mpl) $(wildcard doc/*.bib) 
	cd tex; pdflatex -halt-on-error  -draftmode  $* ;  bibtex $* ; pdflatex -halt-on-error  -draftmode $* ; pdflatex -halt-on-error  $* ; grep -i undefined $*.log ; rm -f $*.aux $*.bbl $*.blg $*.toc $*.nav $*.snm $*.out ; ok=
	mv doc/%.tex ../public

doc/%.mpl.out.txt: doc/%.mpl
	cd tex ; maple ../$^ > ../$@

doc/%.png : doc/%.odg
	libreoffice --headless --convert-to png --outdir $(@D) $^

../public/%.png: public/%.pdf
	pdftk $^ cat 1 output /tmp/%-0.pdf ; convert /tmp/%-0.pdf $@ ; rm /tmp/%-0.pdf
	git add $@

## build_demo

DEMOS := \
  programmatic_task1 \
  programmatic_task2 \
  programmatic_task3 \
  programmatic_quarter_turn_task1 \
  programmaticoid_task1 \
  programmaticoid_task2 \
  programmaticoid_task3 \
  programmatoid_task1 \
  programmatoid_task2 \
  programmatoid_task3 \
 
BUILD_DEMO := \
  $(patsubst %,../public/%, $(DEMOS)) \
  ../public/index.html

../public/%: ./src/%.py
	echo ./src/programmatoid_challenge.sh -c $* $^

../public/programmatic_task%: ./src/programmatic_task@.py
	echo ./src/programmatoid_challenge.sh -c $* $^

../public/programmaticoid_task%: ./src/programmaticoid_task@.py
	echo ./src/programmatoid_challenge.sh -c $* $^

../public/programmatoid_task%: ./src/programmatoid_task@.mpl
	echo ./src/programmatoid_challenge.sh -c $* $^

../public/index.html: $(patsubst %,../public/%, $(DEMOS))
	cp $@ $@~ ; sed 's/const  *demos *= *\[[^]]*\]/const  demos = [ $(patsubst %,"%,",$(DEMOS))]/' < $@~ | sed 's/,]/ ]/' > $@

## show

### Detects a browser if not yet defined
ifeq (,$(BROWSER))
BROWSERS = chromium firefox google-chrome
export BROWSER = $(shell l=($(foreach b,$(BROWSERS),$(shell if which -s $(b) ; then echo $(b) ; fi))) ; echo $${l[0]})
endif

show: build # Shows the public home page.
	$(BROWSER) https://html-preview.github.io/?url=https://github.com/vthierry/braincraft/blob/master/public/index.html

clean: # Cleans all built files to check the reproducibility
	/bin/rm -f src/programmatoid_make.mw ../public/*.png ../public/*/*.*

## These two targets are only to be used by vthierry

vthierry-python-install:
#	sudo apt install python3-tqdm 
#	sudo apt install simplescreenrecorder
#	git remote add master git@github.com:rougier/braincraft.git
	git fetch master
	git commit -a -m 'sync from makefile to fetch'
	git merge master/master
	cd ../braincraft ; sedgrep -name '*.py' -in atan2 -out arctan2

vthierry-wjson-install:
	mkdir -p ../etc
	/bin/rm -rf ../etc/wjson-master ../etc/*.zip
	cd ../etc ; wget -q https://gitlab.inria.fr/line/aide-group/wjson/-/archive/master/wjson-master.zip ; unzip -q wjson-master.zip
	/bin/bash -c '/bin/rm -rf ../etc/{*.zip,wjson-master/{.git*,public,src/{makefile,.make*,*.md,*.*pp,*.C,*.tex,*.odg,*.bib,run_protege*,test.*,ttl2n3.js}}}'
	git add ../etc/wjson-master
