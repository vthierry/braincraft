#
# This files gather all commands regarding using the braincraft challenge as a programmatoid benchmark
# 

## Configures properly the makefile in silent mode, with bash, with automatic usage

.SILENT: $(shell sed -n 's/^\([a-z]*\):.*/\1/p' < makefile)

export SHELL := /bin/bash

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
	echo $(BUILD)

BUILD = \
	../public/api/programmatoid_utils.html \
	$(BUILD_TEX) \
	$(BUILD_DEMO)

## build_api

../public/api/programmatoid_utils.html: ../braincraft/programmatoid_utils.py
	rm -rf $(@D)/* ; pdoc --logo ../data/braincraft0.png --logo-link 'https://github.com/rougier/braincraft' --favicon ../../data/braincraft-favicon.png   --footer-text "`date +'%Y-%m-%d %H:%M:%S'` version"  $^ -o api
	mv $@ $@~ ; sed < $@~ > $@ 's/....custom.css.../.attribution { display: none!important; }/'

## build_tex

BUILD_TEX := $(patsubst %.odg,%.png,$(wildcard doc/*.odg)) $(patsubst %.mpl,%.mpl.out.txt,$(wildcard doc/*.mpl)) $(patsubst %.tex,%.pdf,$(wildcard tex/*.tex)) ../public/programmatoid.png

../public/%.pdf: doc/%.tex $(wildcard doc/*.odg) $(wildcard doc/*.mpl) $(wildcard doc/*.bib) 
	cd tex; pdflatex -halt-on-error  -draftmode  $* ;  bibtex $* ; pdflatex -halt-on-error  -draftmode $* ; pdflatex -halt-on-error  $* ; grep -i undefined $*.log ; rm -f $*.aux $*.bbl $*.blg $*.toc $*.nav $*.snm $*.out ; ok=
	mv doc/%.tex ../public

doc/%.mpl.out.txt: doc/%.mpl
	cd tex ; maple ../$^ > ../$@

doc/%.png : doc/%.odg
	libreoffice --headless --convert-to png --outdir $(@D) $^

../public/programmatoid.png: doc/programmatoid.pdf
	pdftk $^ cat 1 output programmatoid-0.pdf
	convert programmatoid-0.pdf $@
	rm programmatoid-0.pdf

## build_demo

BUILD_DEMO := \
  ../public/programmatic_task1 \
  ../public/programmatic_task2 \
  ../public/programmatic_task3 \
  ../public/programmatic_quarter_turn_task1 \
  ../public/programmaticoid_task1 \
  ../public/programmaticoid_task2 \
  ../public/programmaticoid_task3 \
  ../public/programmatoid_task1 \
  ../public/programmatoid_task2 \
  ../public/programmatoid_task3

../public/%: %.py
	echo ./programmatoid_challenge.sh -c $* $^

../public/programmatic_task%: programmatic_task@.py
	echo ./programmatoid_challenge.sh -c $* $^

../public/programmaticoid_task%: programmaticoid_task@.py
	echo ./programmatoid_challenge.sh -c $* $^

../public/programmatoid_task%: programmatoid_task@.mpl
	echo ./programmatoid_challenge.sh -c $* $^

define TODO

makefile unique à la racine aamev make qui remonte pour le trouver

ajouter tout de suite la mise en forme du HTML en retour d expérience mettre à jour les liens dans les slides et dans le document latex

ajouter slide sur l expérience reproductible avec l'idée d'un mec five unique make five

Changer de variable pour les omega * f(…) apres 1ers teste programmatoid

Ajouter les pages de résultat à index.html

Ajouter les liens vers video et sources dans le prgm.html sous forme de champ avec url

Faire manip avec 10 runs et sans timeout


# Opening some  web pages

git:
	$(BROWSER) https://github.com/vthierry/braincraft

home:
	$(BROWSER) https://html-preview.github.io/?url=https://github.com/vthierry/braincraft/blob/master/doc/index.html

endef


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
