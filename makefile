# https://github.com/vthierry/braincraft

what=env1_player_manual

test:
	python3 braincraft/$(what).py  2>&1 | tee data/$(what).py.out.txt
	git add data/$(what).py.out.txt

install:
	sudo apt install python3.12-venv python3-tqdm
	chmod a+rx ./braincraft/bin/activate
	sedgrep -name '*.py' -in atan2 -out arctan2

venv:
	python3 -m venv braincraft
	./braincraft/bin/activate

sync:
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

programmatic-solution: data/programmatic-solution.pdf data/programmatic-solution.mpl.out.txt

data/programmatic-solution.pdf: data/programmatic-solution.tex
	cd data ; pdflatex programmatic-solution ; rm -f *.aux *.toc *.log

data/programmatic-solution.mpl.out.txt: data/programmatic-solution.mpl
	maple $^ > $@


