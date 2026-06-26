
define TODO

Changer de variable pour les omega * f(…)

Ajouter les pages de résultat à index.html

Ajouter les liens vers video et sources dans le prgm.html sous forme de champ avec url

Faire manip avec 10 runs et sans timeout

endef

export SHELL = /bin/bash

all: rebuild \
  out/programmatic_task1 \
  out/programmatic_task2 \
  out/programmatic_task3 \
  out/programmatic_quarter_turn_task1 \
  out/programmaticoid_task1 \
  out/programmaticoid_task2 \
  out/programmaticoid_task3 \
  out/programmatoid_task1 \
  out/programmatoid_task2 \
  out/programmatoid_task3

out/%: %.py
	echo ./programmatoid_challenge.sh -c $* $^

out/programmatic_task%: programmatic_task@.py
	echo ./programmatoid_challenge.sh -c $* $^

out/programmaticoid_task%: programmaticoid_task@.py
	echo ./programmatoid_challenge.sh -c $* $^

out/programmatoid_task%: programmatoid_task@.mpl
	echo ./programmatoid_challenge.sh -c $* $^

rebuild:
	rm -rf programmatoid.mw out/*

