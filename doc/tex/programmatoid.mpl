# Implementation of the programmatoid mechanisms

## Defines the option list with their default values

prgm_default_options := table([
    omega = 1000,
    mollification = false,
    networking = false,
    python = true,
    licence = "CeCILL-C"
]):

## Defines expandable functions

prgm_functions := {
   h = (v ->
       if type(v, constant) then evalf(1.0/(1.0+exp(-4.0*x)))
       else  h(v)
       fi),
   H = (v ->
       if type(v, `<=`) then H(H(op(1,v) - op(2,v)))
      #elif type(v, `>=`) then H(op(2,v) <= op(1,v))
      elif type(v, `<`) then Not(H(op(2,v) <= op(1,v)))
      #elif type(v, `>`) then Not(H(op(1,v) <= op(2,v)))
      elif type(v, `=`) then And(H(op(1,v) <= op(2,v)), H(op(2,v) <= op(1,v)))
      elif type(v, `<>`) then Not(H(op(1, v) = op(2, v)))
      elif mollification then h(omega * v - 0.5)
      elif type(v, constant) then Heaviside(v)
      else H(v)
      fi),
   H_ = (v -> if type(v, {`<=`, `<`, `=`, `<>`}) then H(v) else v fi),
   Id = (v ->
      if mollification then h(omega * h(v/omega))
     else Id(v)
     fi),
  And = (() -> H(sum(H_(args[k]), k = 1..nargs) - nargs +0.5)),
  Or   = (() -> H(sum(H_(args[k]), k = 1..nargs) + 0.5)),
  Not = ((v) -> H(1 - H_(v))),
  If_b = ((c, b1, b0) ->
    if nargs = 3 then H(H_(b0) - H_(c) - 0.5) + H(H_(b1) + H_(c) - 1.5)
    else If_b(c, b1, If_b(args[3..nargs]))
    fi),
  If_v = ((c, v1, v0) ->
    if nargs = 3 then Bprod(H_(c), v1, (1 - H_(c)), v0)
    else If_v(c, v1, If_v(args[3..nargs]))
    fi),
 Exp_v = ((v) -> .1821429756+2.339035264*h(v-1)+1.551573291*h(0.5*v)),
 Log_v = ((v) -> -5.103555789+2.597614937*h(0.5*v)+4.702926636*h(0.1*v)),
 Prod_v = ((v1, v2) -> evalf(subs({b=4/(exp(1)-1)^2, c = coth(0.5), l = (v -> Log_v(((exp(1)-1) * v + (exp(1)+1))/2))}, b * Exp_v(l(v1)+l(v2)) - c * (v1 + v2 + c)))),
 Prod_b = (() ->
     if type(nargs, odd) then Bprod(args, 0)
     else sum(omega * h(args[2*i]/omega + omega (H_(args[2*i]) - 1)), k = 1 .. nargs/2)
     fi),
 Softmax = (proc()
   local k,
     g := args[nargs],
     b := proc (k, a) local l: H(add(H(a[k]>a[l]), l = 1..k-1) + add(H(a[k]>=a[l]), l = k+1..nops(a)) - nops(a) + 1.5) end:
     add((g/nargs + (1-g) * b(k, [args[1..nargs-1]])) * args[k], k = 1..nargs-1)
     end),
  Latch_b = ((o, b_1, b_c) -> o = If_b(H_(b_c) = 1, o, b_1)),
  Latch_v = ((o, v_1, v_c) ->  o = If_v(H_(b_c) = 1, o, v_1)),
  Bistable = (proc(o, i)
       if nargs = 3 then
         o = If_b(And(o = 0, args[2] = 1), 1, And(o = 1, args[3] = 0), 0, o)
       else
         (proc(o, i)
            local i0 := new_symbol("i0"), i1 := new_symbol("i1"):
            i1 = If_b(And(i1 = 0, i = 1), 1, o = 0, 0, i1),
            i0 = If_b(And(i0 = 0, i = 0), 1, o = 1, 0, i0),
	    o = If_b(And(o = 0, i1 = 1), 1, And(o = 1, i0 = 0), 0, 0)
	 end)(o, i)
       fi
       end),
  Spikeup = (proc(o, i)
      local r:= new_symbol("r"):
      r = If_b(o = 1, 1, i = 0, 0, r),
      o = If_b(And(r = 0, i = 1),  1, 0)
     end),
  Delay = (proc(o, i, T)
      local v := new_symbol("v"), g := if T > 0 then 1 - 2^(-1/T) else 1 fi:
      v = (1 - g) * v + g * i,
      o = If_b(v > 0.5, 1, 0)
     end),
 Oscillator = (proc(o, c, T)
     local v := new_symbol("v"), gamma := if T > 0 then 2 - 2^(1-1/T) else 2 fi:
     v = (1 - g) * v + g * (1 - o) * c,
     o = If_b(v < 1/3, 0, 0, v > 2/3, 1, o)
     end)
 }:

## Compiles a set of equation as a piece of code

prgm_compile := proc(prgm_file :: string)
  local prgm, next_symbol, next_symbol_count := 0:

  try 

    ### Sets basic options

    prgm := (proc() global prgm_default_options: op(prgm_default_options) end)():
    prgm[file] :=  prgm_file:
    prgm[name] :=  FileTools[Basename](prgm_file):
    prgm[version] :=  StringTools[RegSubs]("T" = "_", StringTools[RegSubs](" .*" = "", convert(Date(), string))):

    ### Reads and parses the source text

    if not FileTools[Exists](prgm[file]) then
      error cat("Syntax error: The file '", prgm[file], "' does not exist, it must.")
    fi:
    prgm[text] := FileTools[Text][ReadFile](prgm[file]):
    prgm[source] := parse(StringTools[RegSubs]("#[^\n]*\n" = "", prgm[text])):
 
    ### Extracts options from the first  input line

    if type(prgm[source], list) and nops(prgm[source]) > 0 then
      if type(op(1, prgm[source]), `=`) and op(1, op(1, prgm[source])) = prgm_options then
        if type(op(2, op(1, prgm[source])), {list,  set}) then
          map(o ->
	    if type(o, `=`) then prgm [op(1, o)] := op(2, o) else prgm [o] := true fi,
	    op(2, op(1, prgm[source])))
        else
           error "Syntax error: The prgm_options is not a set or a list, it must." : 
        fi:
       prgm[source] := [op(2..nops(prgm[source]), prgm[source])]:
     fi:
     map(eq ->
        if type(eq, `=`) and op(1, eq) = prgm_options then
          error "Syntax error: A prgm_options is not given at the 1st line, it must."
        fi, prgm[source]):
    else
      error "Syntax error: The source file content is not a non-empty list, it must."
    fi:
    if prgm [networking] then  prgm [mollification] := true fi:
    
     ### Checks the syntax of the equation list

     (proc(eqs)
       global prgm_functions:
       local function_names := map(eq -> op(1, eq), prgm_functions),
       alert := e -> if e then error cat("Syntax error: ", op(map(a-> convert(a, string), [args[2..nops([args])]]))) fi:
       alert(not type(eqs, list), "The  input is not a list (of equations)"):
       map(proc(l, eqs)
         local eq := eqs[l]:
	 if (type(eq, `=`)) then
	   alert(not type(op(1, eq), name),  "The left hand side of '", eq, "', line number '", l, "' is not a name"):
	   alert(type(op(2, eq), function) and (not op(0, op(2, eq)) in function_names), "The right hand side of '", eq, "', line number '", l, "' is not a known function"):
	else
           alert(not (type(eq, function) and op(0, eq) in function_names), "The '", eq, "', line number '", l, "' is not a known function"):
	fi
     end, [$1..nops(eqs)], eqs)
   end)(prgm[source]):
  
   #### Creates a new symbol

   next_symbol := proc(prefix:: string) next_symbol_count := next_symbol_count + 1:  convert(cat(prefix, "_", next_symbol_count), name) end:

   ### Expands the known functions
  
  prgm[expanded]  := (proc(prgm)
     #### Iterate towards a fixed point
     local fixed_point := proc(f, v_0, context, max_iterations::posint:=10)
       local v0 := null, v1 := v_0, t:
       for t to max_iterations do
         v0 := f(v1, context):
         if  v0 = v1 then return v0 fi:
	 v1 := v0
      od:	
     error "Iteratively expanding '", v_0, ", => '", v0, "' toward a fixed point failed."
   end:
   fixed_point(proc(eqs, prgm)
     global prgm_function:
    #### Manages the Id function on linear combination
   map(proc(eq1)
      local eq2 := evalf(eq1):
      if type(eq2, `=`(name, {`*`, `+`})) then
         op(1, eq2) = Id(op(2, eq2))
      else
        eq2
      fi
   end,
     #### Substitutes known prgm functions
     eval(subs(prgm_functions, prgm, new_symbol = next_symbol, eqs)))
   end, prgm[source], prgm)
  end)(prgm):

   ### Flattens inner functions
   prgm[flattened]  := (proc(eqs1)
     local  eqs2 := [],
       #### Expands flattening on a right-hand side expression
       expand_args := proc(a)
         if type(a, {function, `+`, `*`}) then 
          op(0, a)(op(map(expand_arg, a)))
	else a fi
       end,  
       #### Expands flattening on an expression's argument
       expand_arg := proc(a)
          if type(a, function) then
	    add_eq(next_symbol("x"), expand_args(a))
	  elif type(a, {`+`, `*`}) then
	    expand_args(a)
	 else a fi
       end,
       #### Adds a flattened equation
       add_eq := proc(n, a_n)
         ##### Tests if right-hand side is already in the equation set, to avoid double calculation
         local l := convert(map((l, eqs2) -> if op(2, eqs2[l]) = a_n then l else 0 fi, [$1..nops(eqs2)], eqs2), set) minus {0}:
	 if nops(l) > 0 then
	   op(1, op(op(1, l), eqs2))
	 else
	   eqs2 := [op(eqs2), n = a_n]:
	   n
	 fi
       end:
     #### Applies on the equation list  
     map(proc(eq)
       if type(eq, `=`) then
         add_eq(op(1, eq), expand_args(op(2, eq)))
       else
         error cat("After expanding, one line: '", eq, "' is not an equation")
      fi end, eqs1):
      eqs2
   end)(prgm[expanded]):

  ### Generates the equations in matrix form

  #### Sets variable lists
  if not assigned(prgm[outputs]) then 
    prgm[outputs] := convert(indets(map(eq->op(1,eq), prgm[flattened]), name) minus indets(map(eq->op(2,eq), prgm[flattened]), name), list) fi:
  if not assigned(prgm[inputs]) then
    prgm[inputs] := convert(indets(map(eq->op(2,eq), prgm[flattened]), name) minus indets(map(eq->op(1,eq), prgm[flattened]), name), list) fi:
  prgm[network][state] := convert(indets(prgm[flattened], name), list):
  prgm[network][lhs] := map(eq->op(1,eq),prgm[flattened]):
  #### Checks variable list coherence
  if convert(prgm[inputs], set) intersect convert(prgm[outputs], set) <> {} then
    error cat("Incoherence in variables, the input variables '", prgm[inputs], "' and output variables '", prgm[outputs], "' intersect, it must not.") fi:
  if not convert(prgm[inputs], set) subset indets(prgm[flattened], name) then
    error cat("Incoherence in variables, the input variables '", prgm[inputs], "' is not a subset of the whole variable set '",  prgm[network][state], "', it must.") fi:
  if not convert(prgm[outputs], set) subset convert(prgm[network][lhs], set) then
    error cat("Incoherence in variables, the output variables '", prgm[outputs], "' is not a subset of the left-hand side variable set '", prgm[network][lhs], "', it must.") fi:
  if convert(prgm[network][lhs], set) union convert(prgm[inputs], set) <> indets(prgm[flattened], name) then
    error cat("Incoherence in variables, the left-hand side variables '", prgm[network][lhs], "' with the input variables '", prgm[inputs], "' does not equals the whole variable set '", prgm[network][state], "', it must.") fi:
  ### Checks the flattened code coherence
  map(eq -> if not (type(eq, `=`(name, function(And(polynom(constant, prgm[network][state]), linear)))) and nops(op(2, eq)) = 1) then 
    error cat("Incoherence in the flattened equation '", eq,"', it must be of the form [name = function(linear-combination-with-constant-coefficient),…]") fi,  prgm[flattened]):
  #### Sets network parameters model
  prgm[network][dimension] := nops(prgm[flattened]):
  prgm[network][rhs_f] := map(eq->op(0,op(2,eq)), prgm[flattened]):
  prgm[network][W_out] := Matrix(nops(prgm[outputs]), nops(prgm[network][lhs]), (o, s) -> if prgm[outputs][o] = prgm[network][state][s] then 1 else 0 fi):
  prgm[network][W_in] := Matrix(nops(prgm[network][lhs]), nops(prgm[inputs]), (s, i)  -> coeff(op(1, op(2, prgm[flattened][s])), prgm[inputs][i])):
  prgm[network][W] := Matrix(nops(prgm[network][lhs]), nops(prgm[network][lhs]), (s, r) -> coeff(op(1, op(2, prgm[flattened][s])), prgm[network][lhs][r])):
  prgm[network][w] := Matrix(nops(prgm[network][lhs]), 1, (s, r) -> subs(map(v -> v = 0, prgm[network][state]), op(1, op(2, prgm[flattened][s])))):
  prgm[network][connectivity] := convert(map(M -> rtable_scanblock(M, [], 'NonZeros'), [prgm[network][W_out], prgm[network][W], prgm[network][w],prgm[network][W_in]]), `+`):

  ### Generates python code
  if prgm[python] then 
    (proc(prgm)
      local c, d, wl:
      #### Encapsulates variables in the state dictionnary
      c := subs(map(n -> n = data[convert(n, string)], indets(prgm[flattened], name)), prgm[flattened]):
      #### Calls the python code generation modules avoiding warning on unknown functions
      wl := interface(warnlevel=0):
      c := StringTools[RegSubs]("^" = "\t", StringTools[RegSubs]("\n(.)" = "\n\t\t\\1", CodeGeneration[Python](c, defaulttype=float, output=string))):
      d := StringTools[RegSubs]("cg" = "data[\"network\]", StringTools[RegSubs]("[]][\t\n ]*$" = "", StringTools[RegSubs]("= [[]" = "= ", CodeGeneration[Python]([prgm[network][W_in], prgm[network][W], prgm[network][w], prgm[network][W_out]], defaulttype=float, output=string)))):
      interface(warnlevel=wl):
      #### Builds the complete source file
      c := cat(
        "# This file is automatically generated by the programmatoid compiler, better not edit\n",
        (if prgm[networking] then cat(
	 "class MyState(NetworkState)\n",
	 "\tdef init(self)\n", "\t\t", d, "\n\t\tsuper().init(self)\n")
	 else cat(
	 "class MyState(State)\n",
	 "\tdef init(self)\n",
	  "\t\tdata.update(dict({",op(map(n->cat("\"",n,"\": 0, "), indets(prgm[flattened], name)))," \"init\": True}))\n\n",
	  "\tdef update(self)\n",		   
	  (if not prgm[mollification] then cat(
	    "\n\t\tdef H(x):\n\t\t\treturn 0 if x < 0 else 1 if x > 0 else 0.5\t\n",
	    "\n\t\tdef Id(x):\n\t\t\treturn x\n")
	  else "" fi),
	  "\n\t\tdef h(x):\n\t\t\treturn 1 / (1 + np.exp(-4 * x))\n",
	  "\n", c) fi), "\n"):
      #### Saves and returns
      FileTools[Text][WriteFile](StringTools[RegSubs]("\.mpl$" = "\.py", prgm[file]), c):
      c
    end)(prgm)
  fi:

  ## Stops the compilation if errors
  
  catch:
    prgm["error"] := lastexception:
  end try:

  ## Outputs the results 
  save prgm, StringTools[RegSubs]("\.mpl$" = "\.mw", prgm[file]):
 StringTools[RegSubs]("\"(\\[[^\"\n]*\\])\"" = "\\1", ### Supress "" on one line lis
 StringTools[RegSubs]("\"([a-z_-]*)\"" = "\\1",         ### Supress "" on identifier
 StringTools[RegSubs]("\\\\n" = " \\\n\t\t",             ### Increments indentation
 cat("  compilation: ", JSON[ToString]([
   op(map((n, prgm) -> if assigned(prgm[n]) then n = prgm[n] fi, [file, name, excerpt, homepage, version, license, author, omega, mollification, networking, python, inputs, outputs, count, "error"], prgm)), ### Outputs meta-data in sequence
   op(map((n, prgm) -> n = cat("\n", op(map(l -> cat(convert(l, string), "\n"), prgm[n]))), [source, expanded, flattened], prgm)),  ### Outputs code as multi-line string
  network = [  ### Outputs network meta-data
    dimension = prgm[network][dimension],
    connectivity = prgm[network][connectivity],
    f = convert(prgm[network][rhs_f], string),
    op(map((n, prgm) -> n = StringTools[RegSubs]("cg.*= numpy.mat\\(([^)]*)\\)\n" = "\\1", CodeGeneration[Python](prgm[network][n], defaulttype=float, output=string)),
    [W_in, W, w, W_out], prgm)) ### Outputs network buffers
 ]], style=block)))))

end:

## Saves the package

save prgm_default_options,  prgm_functions, prgm_compile, "../../braincraft/programmatoid.mw":

## Functional tests 

FileTools[Text][WriteFile]("/tmp/prgm_test.mpl", "[ prgm_options = { omega = 10, mollification = false },  Delay(b, i_t, 10),  a = H(H(b))]"):
prgm_compile("/tmp/prgm_test.mpl");

 
