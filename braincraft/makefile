
define TODO

Voir comment naviguer proprement !

Changer de variable pour les omega * f(…)

endef

export SHELL = /bin/bash

once: rebuild out/programmatic_navigation/test.out.html

test: \
  rebuild \
  out/programmatic_navigation/test.out.html \
  out/programmatoid_task1/test.out.html \
  out/programmatoid_task2/test.out.html \
  out/programmatoid_task3/test.out.html

out/%/test.out.html: %.py
	./programmatoid_challenge.sh $*

out/%/test.out.html: %.mpl
	./programmatoid_challenge.sh $*

rebuild:
	rm -rf programmatoid.mw out/*

clean:
	rm -f ssr-last-programmatic-run*.mkv

