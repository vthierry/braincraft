
define TODO

Changer de variable pour les omega * f(…)

endef

export SHELL = /bin/bash

all: rebuild \
  out/programmatic_task1 \
  out/programmatic_task2 \
  out/programmatic_task3 \
  out/programmaticoid_task1 \
  out/programmaticoid_task2 \
  out/programmaticoid_task3 \
  out/programmatoid_task1 \
  out/programmatoid_task2 \
  out/programmatoid_task3

out/programmatic_task%: programmatic_task@.py
	echo ./programmatoid_challenge.sh -c $* $^

out/programmaticoid_task%: programmaticoid_task@.py
	echo ./programmatoid_challenge.sh -c $* $^

out/programmatoid_task%: programmatoid_task@.mpl
	echo ./programmatoid_challenge.sh -c $* $^

rebuild:
	rm -rf programmatoid.mw out/*

