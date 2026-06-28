#
# Gathers all commands regarding using the braincraft challenge as a programmatoid benchmark
#
# Here: https://github.com/vthierry/braincraft/programmatoid
# Doc:  https://makefiletutorial.com
#
define TODO
Commencer à tester la translation
Changer de variable pour les omega * f(…) apres 1er test programmatoid
endef

default: 
#	/bin/rm -rf ../public/programmatic_quarter_turn_task1
#	$(MAKE) build
	$(MAKE) show

## Configures properly the makefile in silent mode, with bash, avoiding spurious paralleism, with automatic usage

.SILENT: $(shell sed -n 's/^\([^:]*\):.*/\1/p' < makefile)

export SHELL := /bin/bash

.NOTPARALLEL:

usage: # Shows the makefile usage.
	echo -e 'Usage: make $$command\nCommands:'
	sed -n 's/^\([a-z]*: *\)[^#]*#\(.*\)/  \1\2/p' < makefile

## git_sync

sync: # Synchronizes files with the github repository.
	cd tex ; rm -f *.aux *.bbl *.blg *.out *.log *.toc *.nav *.snm
	find .. \( -name 'nohup.out' -o -name '*~' \) -delete
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

## build_all

build: # Builds all test, demo and documentation files.
	$(MAKE) $(BUILD)

BUILD = \
	../public/api/programmatoid_utils.html \
	$(BUILD_TEX) \
	$(BUILD_DEMO)

## build_api

../public/api/programmatoid_utils.html: ./src/programmatoid_utils.py
	rm -rf $(@D) ; pdoc --logo ./braincraft-benchmark.png --favicon ./braincraft-favicon.png  --footer-text "`date +'%Y-%m-%d %H:%M:%S'` version"  $^ -o ../public/api
	cp ./src/{braincraft-benchmark,braincraft-favicon}.png $(@D)
	mv $@ $@~ ; sed < $@~ > $@ 's/....custom.css.../.attribution { display: none!important; }/'
	git add $(@D)

## build_tex

BUILD_PDF := \
  programmatoid \
  programmatoid-slides \

BUILD_TEX := \
  $(patsubst %.odg,%.png,$(wildcard tex/*.odg)) \
  $(patsubst %.mpl,%.mpl.out.txt,$(wildcard tex/*.mpl)) \
  $(patsubst %,../public/%.pdf,$(BUILD_PDF)) \
  $(patsubst %,../public/%.png,$(BUILD_PDF))

../public/%.pdf: tex/%.tex $(wildcard tex/*.odg) $(wildcard tex/*.mpl) $(wildcard tex/*.bib) 
	cd tex; pdflatex -halt-on-error  -draftmode  $* ;  bibtex $* ; pdflatex -halt-on-error  -draftmode $* ; pdflatex -halt-on-error  $* ; grep -i undefined $*.log ; rm -f $*.aux $*.bbl $*.blg $*.toc $*.nav $*.snm $*.out ; ok=
	mv tex/$*.pdf $@ 

tex/%.mpl.out.txt: tex/%.mpl
	cd tex ; maple ../$^ > ../$@

tex/%.png : tex/%.odg
	libreoffice --headless --convert-to png --outdir $(@D) $^

../public/%.png: ../public/%.pdf
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
  programmatoneuronoid_task1 \
  programmatoneuronoid_task2 \
  programmatoneuronoid_task3
 
BUILD_DEMO := \
  $(patsubst %,../public/%, $(DEMOS)) \
  ../public/index.html

../public/programmatic_task%: ./src/programmatic_task@.py
	./src/programmatoid_make.sh -p ../public -c $* $^

../public/programmatic_quarter_turn_task1: ./src/programmatic_quarter_turn_task1.py
	./src/programmatoid_make.sh -p ../public -c 1 $^

../public/programmaticoid_task%: ./src/programmaticoid_task@.py
	echo ./src/programmatoid_make.sh -p ../public -c $* $^

../public/programmatoid_task%: ./src/programmatoid_task@.mpl
	echo ./src/programmatoid_make.sh -p ../public -c $* $^

../public/programmatoneuronoid_task%: ./src/programmatoid_task@.mpl
	echo ./src/programmatoid_make.sh -p ../public -c $* -n $^

../public/index.html: ./src/index.html
	sed 's/@@/$(DEMOS)/' < $^ > $@

../public/up.png:  ./src/up.png
	cp $^ $@

## show

### Detects a browser if not yet defined
ifeq (,$(BROWSER))
BROWSERS = chromium firefox google-chrome
export BROWSER = $(shell l=($(foreach b,$(BROWSERS),$(shell if which -s $(b) ; then echo $(b) ; fi))) ; echo $${l[0]})
endif

show: build # Shows the documentation home page.
## If npm is installed uses a minimal server
### Installs locally the npm http-server if not yet done
### If no server active
#### Starts the server in a detached child process
#### Creates a script to stop the server
### Opens the page
## Else, opens the page as a file
	if which -s npm ; then \
	  cd ../public ;\
	  if ! which -s http-server ; then npm --silent install http-server ; fi ;\
	  if [ "`curl -s -w '%{http_code}' -L '127.0.0.1:8080/' -o /dev/null`" -ne 200 ] ; then \
	    (nohup ./node_modules/http-server/bin/http-server -a 127.0.0.1-p 8080 --silent &>/dev/null 0</dev/null &) ;\
	    echo -e "#!/bin/bash\nkill -9 $$$$ &>/dev/null" > http-server-stop ; chmod a+x http-server-stop ; echo "Run '.../public/http-server-stop' to stop the server" ;\
	  fi ;\
	  ($(BROWSER) http://127.0.0.1:8080/index.html &) ;\
	else \
	  ($(BROWSER) `pwd`/../public/index.html &) ;\
	fi

stop: # Stops running the documentation server.
	if [ -f ../public/http-server-stop ] ; then ../public/http-server-stop ; fi

clean: # Cleans all built files.
	/bin/rm -rf ./src/programmatoid_make.mw ../public/*

rebuild: clean build # Rebuilds all built files to check the reproducibility.

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
