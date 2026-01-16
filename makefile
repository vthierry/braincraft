# https://github.com/vthierry/braincraft

#what=env1_player_manual
what=env1_player_simple

test:
	python3 braincraft/$(what).py 2>&1 | tee data/log/$(what).py.out.txt
	git add data/log/$(what).py.out.txt

install:
#	sudo apt install python3.12-venv python3-tqdm
#	git remote add master git@github.com:rougier/braincraft.git
	git fetch master
	git commit -a -m 'sync from makefile to fetech'
	git merge master/master
	sedgrep -name '*.py' -in atan2 -out arctan2

venv:
	python3 -m venv braincraft
	chmod a+rx ./braincraft/bin/activate
	./braincraft/bin/activate

sync:
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

git:
	$(BROWSER) https://github.com/vthierry/braincraft

programmatic-solution: data/programmatic-solution.pdf data/programmatic-solution.mpl.out.txt

data/programmatic-solution.pdf: data/programmatic-solution.tex
	cd data ; pdflatex programmatic-solution ; rm -f *.aux *.toc *.log

data/programmatic-solution.mpl.out.txt: data/programmatic-solution.mpl
	maple $^ > $@


