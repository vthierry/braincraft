usage:
	echo 'make (sync|git|home) # see makefile'

# Git synchronisation command

sync:
	cd doc/tex ; rm -f *.aux *.bbl *.blg *.out *.log *.toc *.nav *.snm
	rm -f `find -name 'nohup.out' -o -name '*~'`
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q ; git status -s

# Opening some  web pages

git:
	$(BROWSER) https://github.com/vthierry/braincraft

home:
	$(BROWSER) https://html-preview.github.io/?url=https://github.com/vthierry/braincraft/blob/master/doc/index.html

# These are only to be used by vthierry

vthierry-install:
#	sudo apt install python3-tqdm
#	git remote add master git@github.com:rougier/braincraft.git
	git fetch master
	git commit -a -m 'sync from makefile to fetch'
	git merge master/master
	cd ../braincraft ; sedgrep -name '*.py' -in atan2 -out arctan2

wjson-install:
	mkdir -p etc
	/bin/rm -rf etc/wjson-master etc/*.zip
	cd etc ; wget -q https://gitlab.inria.fr/line/aide-group/wjson/-/archive/master/wjson-master.zip ; unzip -q wjson-master.zip
	/bin/bash -c '/bin/rm -rf etc/{*.zip,wjson-master/{.git*,public,src/{makefile,.make*,*.md,*.*pp,*.C,*.tex,*.odg,*.bib,run_protege*,test.*,ttl2n3.js}}}'
	git add etc/wjson-master





