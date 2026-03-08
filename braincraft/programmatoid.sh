#!/bin/bash

if [ -z "$1" ] ; then echo "Usage $0 \$prgm_name" ; exit -1 ; fi

cat <<EOF  | maple -q
read "./programmatoid.mw":
prgm_compile("$1"):
EOF
