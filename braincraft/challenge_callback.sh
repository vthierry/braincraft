#!/bin/bash

if [ -z "$1" ] ; then echo "Usage $0 \$prgmd-name" ; exit -1 ; fi
if [ \! -f "$1.prgmd" ] ; then echo "The file '$1.prgmd' is not found" ; exit -2 ; fi
     
(echo "filename:= \"$1\":" ; cat challenge_callback.mpl) | maple -q 
