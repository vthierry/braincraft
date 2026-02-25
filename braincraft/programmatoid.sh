#!/bin/bash

if [ -z "$1" ] ; then echo "Usage $0 \$prgmd-name" ; exit -1 ; fi
if [ \! -f "$1.mpl" ] ; then echo "The file '$1.mpl' is not found" ; exit -2 ; fi

cat <<EOF  | maple -q 
read "./programmatoid.mw":
filename:= "$1": 
printf("Reading \"%s\" …\n", filename):
input := FileTools[Text][ReadFile](cat(filename, ".mpl")):
input := StringTools[RegSubs]("#[^\n]*\n" = "", input):
printf("Parsing \"%s\" …\n", filename):
prgm_input := parse(input):
printf("Compiling \"%s\" …\n", filename):
prgm_output := prgm_compile(prgm_input):
printf("Ouputing \"%s\" …\n", filename):
print(prgm_output):
printf("\n… done\n"):
EOF
