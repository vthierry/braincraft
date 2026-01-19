programmatic-solution: programmatic-solution.pdf programmatic-solution.mpl.out.txt

programmatic-solution.pdf: programmatic-solution.tex
	cd data ; pdflatex programmatic-solution ; rm -f *.aux *.toc *.log

programmatic-solution.mpl.out.txt: programmatic-solution.mpl
	maple $^ > $@

