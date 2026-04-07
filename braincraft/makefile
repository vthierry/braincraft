export SHELL = /bin/bash

once: rebuild programmatic_challenge_example/test.out.html

test: \
  rebuild \
  programmatic_challenge_example/results/test.out.html \
  programmatoid_task1/results/test.out.html \
  programmatoid_task2/results/test.out.html \
  programmatoid_task3/results/test.out.html

results/%/test.out.html: %.py
	./programmatoid_challenge.sh $*

results/%/test.out.html: %.mpl
	./programmatoid_challenge.sh $*

rebuild:
	if [ -d "../../wjson/src" ] ; then mkdir -p ../etc/wjson-master/src/ ; /bin/cp -f ../../wjson/{package.json,README.md} ../etc/wjson-master/ ; /bin/cp -f ../../wjson/src/{wjson2html,wjson2json,wjson2wjson,wJSON}.js ../etc/wjson-master/src/ ; fi
	rm -f programmatoid.mw */test.out.html 

