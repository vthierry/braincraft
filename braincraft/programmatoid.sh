#!/bin/bash

if [ -z "$1" ] ; then echo "Usage $0 \$prgm_name" ; exit -1 ; fi
if [ \! -f "$1.mpl" ] ; then echo "The file '$1.mpl' is not found" ; exit -2 ; fi

cat <<EOF  | maple -q
# Interface with the prgm_compile() proc.
read "./programmatoid.mw":
prgm_name:= "$1": 
printf("Reading     \"%s\" …\n", prgm_name):
input := FileTools[Text][ReadFile](cat(prgm_name, ".mpl")):
input := StringTools[RegSubs]("#[^\n]*\n" = "", input): ## … skips comments
printf("Parsing      \"%s\" …\n", prgm_name):
prgm_input := parse(input):
printf("Compiling \"%s\" …\n", prgm_name):
prgm_output := prgm_compile(prgm_input):
printf("Ouputing  \"%s\" …\n", prgm_name):
print(prgm_output):
printf("\n… done\n"):
EOF
