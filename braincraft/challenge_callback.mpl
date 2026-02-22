# Implements the translation of equations to python code

if type(filename, name) then printf("%s", "\n\tDo not run this maple script directly but use challenge_callback.sh.\n\n"): `quit`(1) fi:

printf("Reading \"%s\" …\n", filename):
input := FileTools[Text][ReadFile](cat(filename, ".mpl")):
input := StringTools[RegSubs]("#[^\n]*\n" = "", input):
printf("Parsing \"%s\" …\n", filename):
prgmd := parse(input):

lprint(prgmd):

print(indets(prgmd, name));



## Reads the input file if not given as input
## Creates the indets list
## Susbtitute derivable functions, including programmatoid if required
## Flatten the equations and adds variables
## Detects unkown functions


printf("\n… done\n"):
