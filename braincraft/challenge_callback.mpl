# Implements the translation of equations to python code

read "../programmatoid.mw":

if type(filename, name) then printf("%s", "\n\tDo not run this maple script directly but use challenge_callback.sh.\n\n"): `quit`(1) fi:

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
