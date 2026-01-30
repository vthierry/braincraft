
# The doc files to build

build : api/index.html programmatic-solution logs

# The challenge callback api documentation

api/index.html: ../braincraft/challenge_callback.py
	rm -rf api/* ; ~/.local/bin/pdoc $^ -o api

# The programmatic-solution latex document

programmatic-solution: programmatic-solution/programmatic-solution.pdf programmatic-solution/programmatic-solution.mpl.out.txt

programmatic-solution.pdf: programmatic-solution.tex
	cd programmatic-solution ; pdflatex programmatic-solution ; rm -f *.aux *.toc *.log

programmatic-solution/programmatic-solution.mpl.out.txt: programmatic-solution/programmatic-solution.mpl
	maple $^ > $@

# The python codes output log

what = env1_player_programmatoid

logs: $(patsubst %,log/%.py.out.txt,$(what))

log/%.py.out.txt: ../braincraft/%.py 
	cd ../braincraft ; python3 $*.py 2>&1 | tee ../doc/log/$*.py.out.txt

# Installation/re-installation commands

install:
#	sudo apt install python3-tqdm
#	git remote add master git@github.com:rougier/braincraft.git
	git fetch master
	git commit -a -m 'sync from makefile to fetech'
	git merge master/master
	cd ../braincraft ; sedgrep -name '*.py' -in atan2 -out arctan2

# Git synchronisation commands

sync: build
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

git:
	$(BROWSER) https://github.com/vthierry/braincraft




