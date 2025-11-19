vthierry:
	cd data ; pdflatex programmatic-solution

sync:
	git pull -q ; git commit -q -a -m 'sync from makefile' ; git push -q
