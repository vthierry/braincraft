
what=env1_player_manual

test:
	python3 braincraft/$(what).py  2>&1 | tee data/$(what).py.out.txt
	git add data/$(what).py.out.txt

install:
	sudo apt install python3.12-venv python3-tqdm
	chmod a+rx ./braincraft/bin/activate

venv:
	python3 -m venv braincraft
	./braincraft/bin/activate

sync:
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q

programmatic-solution:
	cd data ; pdflatex programmatic-solution ; rm -f *.aux *.toc *.log

