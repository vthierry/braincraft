
# Git synchronisation commands

sync:
	cd doc/tex ; rm -f *.aux *.bbl *.blg *.out *.log *.toc
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

git:
	$(BROWSER) https://github.com/vthierry/braincraft

doc:
	$(BROWSER) https://html-preview.github.io/?url=https://github.com/vthierry/braincraft/blob/master/doc/index.html

# Installation/re-installation commands

install:
#	sudo apt install python3-tqdm
#	git remote add master git@github.com:rougier/braincraft.git
	git fetch master
	git commit -a -m 'sync from makefile to fetech'
	git merge master/master
	cd ../braincraft ; sedgrep -name '*.py' -in atan2 -out arctan2

