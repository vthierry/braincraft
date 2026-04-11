export SHELL = /bin/bash

once: rebuild out/programmatic_challenge_example/test.out.html

test: \
  rebuild \
  out/programmatic_challenge_example/test.out.html \
  out/programmatoid_task1/test.out.html \
  out/programmatoid_task2/test.out.html \
  out/programmatoid_task3/test.out.html

out/%/test.out.html: %.py
	./programmatoid_challenge.sh $*

out/%/test.out.html: %.mpl
	./programmatoid_challenge.sh $*

rebuild:
	if [ -d "../../wjson/src" ] ; then mkdir -p ../etc/wjson-master/src/ ; /bin/cp -f ../../wjson/{package.json,README.md} ../etc/wjson-master/ ; /bin/cp -f ../../wjson/src/{wjson2html,wjson2json,wjson2wjson,wJSON}.js ../etc/wjson-master/src/ ; fi
	rm -rf programmatoid.mw out/*

