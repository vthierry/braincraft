# Implements the translation of equations to python code

printf("Reading \"%s\" …\n", filename):
input := FileTools[Text][ReadFile](cat(filename, ".prgmd")):
input := StringTools[RegSubs]("#[^\n]*\n" = "", input):
printf("Parsing \"%s\" …\n", filename):
prgmd := parse(input):

lprint(prgmd):


challenge_callback := proc(name:: String, prgmd :: list(`=`)):: list(`=`);
## Reads the input file if not given as input
## Creates the indets list
## Susbtitute derivable functions, including programmatoid if required
## Flatten the equations and adds variables
## Detects unkown functions
end:

printf("\n… done\n"):
