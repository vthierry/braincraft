
dft : demo

# Git synchronisation command

sync:
	cd doc/tex ; rm -f *.aux *.bbl *.blg *.out *.log *.toc
	rm -f `find -name 'nohup.out' -o -name '*~'`
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

# Opening some  web pages

git:
	$(BROWSER) https://github.com/vthierry/braincraft

home:
	$(BROWSER) https://html-preview.github.io/?url=https://github.com/vthierry/braincraft/blob/master/doc/index.html

# This is still in development, do not use

demo: show

# This is only to be used by vthierry

vthierry-install:
#	sudo apt install python3-tqdm
#	git remote add master git@github.com:rougier/braincraft.git
	git fetch master
	git commit -a -m 'sync from makefile to fetch'
	git merge master/master
	cd ../braincraft ; sedgrep -name '*.py' -in atan2 -out arctan2

