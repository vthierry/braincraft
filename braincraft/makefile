all : doc/index.html test

what=env1_player_programmatoid

test:
	python3 $(what).py 2>&1 | tee ../data/log/$(what).py.out.txt
	git add ../data/log/$(what).py.out.txt

doc/index.html: challenge_callback.py
	rm -rf doc/* ; ~/.local/bin/pdoc $^ -o doc

