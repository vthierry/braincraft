# Implementation of the programmatoid mechanisms

## TBD
### - factorizes identical expressions, looking the eqs2 table

## Defines the option list with their default values

prgm_default_options := table([
   omega = 1000,
   all_neuronoid = false,
   python = true
]):

## Defines expandable functions

prgm_functions := {
   h = (v ->
       if type(v, constant) then 1/(1+exp(-4*x))
       else  h(v)
       fi),
   H = (v ->
       if type(v, `<=`) then H(H(op(1,v) - op(2,v)))
      #elif type(v, `>=`) then H(op(2,v) <= op(1,v))
      elif type(v, `<`) then Not(H(op(2,v) <= op(1,v)))
      #elif type(v, `>`) then Not(H(op(1,v) <= op(2,v)))
      elif type(v, `=`) then And(H(op(1,v) <= op(2,v)), H(op(2,v) <= op(1,v)))
      elif type(v, `<>`) then Not(H(op(1, v) = op(2, v)))
      elif all_neuronoid then h(omega * v - 0.5)
      elif type(v, constant) then Heaviside(v)
      else H(v)
      fi),
   Id = (v ->
      if all_neuronoid then h(omega * h(v/omega))
     else Id(v)
     fi),
  And = (() -> H(sum(args[k], k = 1..nargs) - nargs +0.5)),
  Or   = (() -> H(sum(args[k], k = 1..nargs) + 0.5)),
  Not = ((v) -> H(1 - v)),
  If_b = ((c, b1, b0) ->
    if nargs = 3 then H(b0 - c - 0.5) + H(b1 + c - 3/2)
    else If_b(c, b1, If_b(args[3..nargs]))
    fi),
  If_v = ((c, v1, v0) ->
    if nargs = 3 then Bprod(c, v1,(1 - c), v0)
    else If_v(c, v1, If_v(args[3..nargs]))
    fi),
 Exp_v = ((v) -> .1821429756+2.339035264*h(v-1)+1.551573291*h(v/2)),
 Log_v = ((v) -> -5.103555789+2.597614937*h(v/2)+4.702926636*h(v/10)),
 Prod_v = ((v1, v2) -> evalf(subs({b=4/(exp(1)-1)^2, c = coth(0.5), l = (v -> Log_v(((exp(1)-1) * v + (exp(1)+1))/2))}, b * Exp_v(l(v1)+l(v2)) - c * (v1 + v2 + c)))),
 Prod_b = (() ->
     if type(nargs, odd) then Bprod(args, 0)
     else sum(omega * h(args[2*i]/omega + omega (args[2*i] - 1)), k = 1 .. nargs/2)
     fi),
 Softmax = (proc()
   local k,
     g := args[nargs],
     b := proc (k, a) local l: H(add(H(a[k]>a[l]), l = 1..k-1) + add(H(a[k]>=a[l]), l = k+1..nops(a)) - nops(a) + 3/2) end:
     add((g/nargs + (1-g) * b(k, [args[1..nargs-1]])) * args[k], k = 1..nargs-1)
     end),
  Latch_b = ((o, b_1, b_c) -> o = If_b(b_c = 1, o, b_1)),
  Latch_v = ((o, v_1, v_c) ->  o = If_v(b_c = 1, o, v_1)),
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
  local prgm := table(), next_symbol, next_symbol_count := 0:

  try 

    ### Sets basic options

    prgm["options"] := (proc() global prgm_default_options: op(prgm_default_options) end)():
    prgm["options"][file] :=  prgm_file:
    prgm["options"][name] :=  FileTools[Basename](prgm_file):
    prgm["options"][version] :=  convert(Date(), string):

    ### Reads and parses the source text

    if not FileTools[Exists](prgm["options"][file]) then
      error cat("Syntax error: The file '", prgm["options"][file], "' does not exist, it must.")
    fi:
    prgm["source"] := FileTools[Text][ReadFile](prgm["options"][file]):
    prgm["input"] := parse(StringTools[RegSubs]("#[^\n]*\n" = "", prgm["source"])):
 
    ### Extracts options from the first  input line

    if type(prgm["input"], list) and nops(prgm["input"]) > 0 then
      if type(op(1, prgm["input"]), `=`) and op(1, op(1, prgm["input"])) = prgm_options then
        if type(op(2, op(1, prgm["input"])), {list,  set}) then
          map(o ->
	    if type(o, `=`) then prgm["options"] [op(1, o)] := op(2, o) else prgm["options"] [o] := true fi,
	    op(2, op(1, prgm["input"])))
        else
           error "Syntax error: The prgm_options is not a set or a list, it must." : 
        fi:
       prgm["input"] := [op(2..nops(prgm["input"]), prgm["input"])]:
     fi:
     map(eq ->
        if type(eq, `=`) and op(1, eq) = prgm_options then
          error "Syntax error: A prgm_options is not given at the 1st line, it must."
        fi, prgm["input"]):
    else
      error "Syntax error: The source file content is not a non-empty list, it must."
    fi:
    
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
   end)(prgm["input"]):

  
   #### Creates a new symbol

   next_symbol := proc(prefix:: string) next_symbol_count := next_symbol_count + 1:  convert(cat(prefix, "_", next_symbol_count), name) end:

   ### Expands the known functions
  
  prgm["expanded"]  := (proc(prgm)
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
     local
       #### Tests if it is a linear combination of constant with symbol or function
       type_linear_combination := proc(a) type_linear_combination_term(a) or (type(a, `+`) and convert(map(type_linear_combination_term, convert(a, list)), `and`)) end,
       type_linear_combination_term := proc(a) type(a, {constant, function}) or (type(a, `*`) and nops(a) <= 2 and type(op(1, a), constant)) end:
    #### Manages the Id function on linear combination
   map(proc(eq1)
      local eq2 := evalf(eq1):
      if type(eq2, `=`) and type(op(2, eq2), {`+`, `*`}) then
        if type_linear_combination(op(2, eq2)) then
	   op(1, eq2) = Id(op(2, eq2))
	else
          error cat("When flattening, one algebraic expression: '", eq2, "' is not a linear combination of constants with symbols")
        fi
      else
        eq2
      fi
   end,
     #### Substitutes known prgm functions
     eval(subs(prgm_functions, prgm["options"], new_symbol = next_symbol, eqs)))
   end, prgm["input"], prgm)
  end)(prgm):

   ### Flattens inner functions
   prgm["flattened"]  := (proc(eqs1)
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
	   op(1, op(l, eqs2))
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
   end)(prgm["expanded"]):

  ### Generates python code
  if prgm["options"][python] then 
    prgm["python"] := (proc(prgm)
      local c,
      #### Calls the python code generation modules avoiding warning on uknown functions
      w := interface(warnlevel=0):
      c := StringTools[RegSubs]("^" = "\t", StringTools[RegSubs]("\n(.)" = "\n\t\\1", CodeGeneration[Python](prgm["flattened"], defaulttype=float, output=string))):
      interface(warnlevel=w):
      #### Builds the complete source file
      c := cat(
        "# This file is automatically generated by the programmatoid compiler, better not edit\n",
	"\ndef ", prgm["options"][name], "(state)\n",
	(if not prgm["options"][all_neuronoid] then cat(
	  "\n\tdef H(x):\n\t\treturn 0 if x < 0 else 1 if x > 0 else 1/2\t\n",
	  "\n\tdef Id(x):\n\t\treturn x\n")
	else "" fi),
	"\n\tdef h(x):\n\t\treturn 1 / (1 + np.exp(-4 * x))\n",
	"\n", c, "\n"):
      #### Saves and returns
      FileTools[Text][WriteFile](StringTools[RegSubs]("\.mpl$" = "\.py", prgm["options"][file]), c):
      c
    end)(prgm):
  fi:

  ### Generates the equations in matrix form

  #### Detects the state, input and output variables
  ##### Sets varibal lists
  if not assigned(prgm["options"][outputs]) then 
    prgm["options"][outputs] := convert(indets(map(eq->op(1,eq), prgm["flattened"]), name) minus indets(map(eq->op(2,eq), prgm["flattened"]), name), list) fi:
  if not assigned(prgm["options"][inputs]) then
    prgm["options"][inputs] := convert(indets(map(eq->op(2,eq), prgm["flattened"]), name) minus indets(map(eq->op(1,eq), prgm["flattened"]), name), list) fi:
  prgm["model"][state] := convert(indets(prgm["flattened"], name), list):
  prgm["model"][lhs] := map(eq->op(1,eq),prgm["flattened"]):
  ##### Checks variable list coherence
  if convert(prgm["options"][inputs], set) intersect convert(prgm["options"][outputs], set) <> {} then
    error cat("Incoherence in variables, the input variables '", prgm["options"][inputs], "' and output variables '", prgm["options"][outputs], "' intersect, it must not.") fi:
  if not convert(prgm["options"][inputs], set) subset indets(prgm["flattened"], name) then
    error cat("Incoherence in variables, the input variables '", prgm["options"][inputs], "' is not a subset of the whole variable set '",  prgm["model"][state], "', it must.") fi:
  if not convert(prgm["options"][outputs], set) subset convert(prgm["model"][lhs], set) then
    error cat("Incoherence in variables, the output variables '", prgm["options"][outputs], "' is not a subset of the left-hand side variable set '", prgm["model"][lhs], "', it must.") fi:
  if convert(prgm["model"][lhs], set) union convert(prgm["options"][inputs], set) <> indets(prgm["flattened"], name) then
    error cat("Incoherence in variables, the left-hand side variables '", prgm["model"][lhs], "' with the input variables '", prgm["options"][inputs], "' does not equals the whole variable set '", prgm["model"][state], "', it must.") fi:
  ##### Sets network parameters model
  prgm["model"][rhs_f] := map(eq->op(0,op(2,eq)), prgm["flattened"]):
  if nops(convert(prgm["model"][rhs_f], set)) = 1 then prgm["model"][the_f] := op(1, prgm["model"][rhs_f]) fi:
  prgm["model"][W_in] := Matrix(nops(prgm["model"][state]), nops(prgm["options"][inputs]), (s, i) -> if prgm["model"][state][s] = prgm["options"][inputs][i] then 1 else 0 fi):
  prgm["model"][W_out] := Matrix(nops(prgm["options"][outputs]), nops(prgm["model"][state]), (o, s) -> if prgm["options"][outputs][o] = prgm["model"][state][s] then 1 else 0 fi):
  prgm["model"][W] := Matrix(nops(prgm["model"][state]), nops(prgm["model"][state]), proc(r, s)
    local i, a, b:
    member(prgm["model"][state][r], prgm["model"][lhs], i):
    if i = 0 then
      0
    else
      a := op(2, op(i, prgm["flattened"])):
      b := prgm["model"][state][s]:
      0
   fi end):

  ### Stops the compilation if errors
  
  catch:
    prgm["error"] := lastexception:
    return prgm
  end try:

    prgm
end:

## Saves the package

save prgm_default_options,  prgm_functions, prgm_compile, "../../braincraft/programmatoid.mw":

## Functional tests 

FileTools[Text][WriteFile]("/tmp/prgm_test.mpl", "[ prgm_options = { omega = 10, all_neuronoid = false },  Delay(b, i_t, 10),  a = H(H(b))]"):
print(prgm_compile("/tmp/prgm_test.mpl"));
 
