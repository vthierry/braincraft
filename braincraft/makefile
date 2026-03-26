
test : test0 test1 test2 test3

test0:
	echo programmatic_challenge_example
	python3 programmatic_challenge_example.py

test1 : programmatoid_task1_test.out.html

%.py %.mw %_test.py %_test.out.wjson %_test.out.html : %.mpl
	echo programmatoid_challenge.sh $*
	./programmatoid_challenge.sh $*

