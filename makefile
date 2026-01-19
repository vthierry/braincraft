# https://github.com/vthierry/braincraft

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
	make -C data/programmatic-solution 
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

git:
	$(BROWSER) https://github.com/vthierry/braincraft


