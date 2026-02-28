# Implementation of the programmatoid mechanisms

## Defines the option list with their default values

prgm_default_options := table([
   omega = 1000,
   all_neuronoid = false
]):

## Defines expandable functions

prgm_functions := {
   h = (v ->
       if type(v, constant) then 1/(1+exp(-4*x))
       else  h(v)
       fi),
   Id = (v-> omega * h(v/omega)),
   H = (v ->
       if type(v, `<=`) then H(H(op(1,v) - op(2,v)))
      #elif type(v, `>=`) then H(op(2,v) <= op(1,v))
      elif type(v, `<`) then Not(H(op(2,v) <= op(1,v)))
      #elif type(v, `>`) then Not(H(op(1,v) <= op(2,v)))
      elif type(v, `=`) then And(H(op(1,v) <= op(2,v)), H(op(2,v) <= op(1,v)))
      elif type(v, `<>`) then Not(H(op(1, v) = op(2, v)))
      elif type(v, constant) then Heaviside(v)
      elif prgm_current_options[all_neuronoid] then h(omega * v - 1/2)
      else H(v)
      fi),
  And = (() -> H(sum(args[k], k = 1..nargs) - nargs +1/2)),
  Or   = (() -> H(sum(args[k], k = 1..nargs) + 1/2)),
  Not = ((v) -> H(1 - v)),
  If_b = ((c, b1, b0) ->
    if nargs = 3 then H(b0 - c - 1/2) + H(b1 + c - 3/2)
    else If_b(c, b1, If_b(args[3..nargs]))
    fi),
  If_v = ((c, v1, v0) ->
    if nargs = 3 then Bprod(c, v1,(1 - c), v0)
    else If_v(c, v1, If_v(args[3..nargs]))
    fi),
 Bprod = (() ->
     if type(nargs, odd) then Bprod(args, 0)
     else sum(omega * h(args[2*i]/omega + omega (args[2*i] - 1)), k = 1 .. nargs/2)
     fi),
###  {\tt Softmax(v\_1, …, G)} & Mean-max operator. \\ & $\mbox{{\tt G}} \in [0_{average}, 1_{maximum}]$ controls the mean-max balance.\\
  Latch_b = ((o, b_1, b_c) -> If_b(b_c = 1, o, b_1)),
  Latch_b = ((o, b_1, b_c) -> If_v(b_c = 1, o, b_1)),
  Bistable = (proc(o, i)
       if nargs = 3 then
         o = If_b(And(o = 0, args[2] = 1), 1, And(o = 1, args[3] = 0), 0, o)
       else
         (proc(o, i)
            local i0 := prgm_new_symbol("i0"), i1 := prgm_new_symbol("i1"):
	    o = If_b(And(o = 0, i1 = 1), 1, And(o = 1, i0 = 0), 0, 0),
            i1 = If_b(And(i1 = 0, i = 1), 1, o = 0, 0, i1),
            i0 = If_b(And(i0 = 0, i = 0), 1, o = 1, 0, i0)
	 end)(o, i)
       fi
       end),
  Spikeup= (proc(o, i)
      local r:= prgm_new_symbol("r"):
      o = If_b(And(r = 0, i = 1),  1, 0),
      r = If_b(o = 1, 1, i = 0, 0, r)
     end),
  Delay= (proc(o, i, T)
      local v := prgm_new_symbol("v"), g := if T > 0 then 1 - 2^(-1/T) else 1 fi:
      o = If_b(v > 1/2, 1, 0),
      v = (1 - g) * v + g * i
     end),
 Oscillator= (proc(o, c, T)
     local v := prgm_new_symbol("v"), gamma := if T > 0 then 2 - 2^(1-1/T) else 2 fi:
     o = If_b(v < 1/3, 0, 0, v > 2/3, 1, o),
     v = (1 - g) * v + g * (1 - o) * c
     end)
}:

## Compiles a set of equation as a piece of code

prgm_compile := proc(prgm_input:: list)
  global Heaviside:
  local eqs, result := table():
  Heaviside(0) := 1/2:

  try
    ### Extracts options from the prgm_input
    eqs := (proc(prgm_input)
       local eqs := prgm_input:
       if type(prgm_input, list) and nops(prgm_input) > 0 then
         if type(op(1, prgm_input), `=`) and op(1, op(1, prgm_input)) = prgm_options then
           if type(op(2, op(1, prgm_input)), {list,  set}) then
	     map(proc(o)
	        global prgm_current_options:
                if type(o, `=`) then prgm_current_options[op(1, o)] := op(2, o) else prgm_current_options[o] := true fi
	     end, op(2, op(1, prgm_input)))
           else
             error "Syntax error: The prgm_options is not a set or a list, it must." : 
           fi:
           eqs := [op(2..nops(prgm_input), prgm_input)]:
         fi:
         map(eq ->
	    if type(eq, `=`) and op(1, eq) = prgm_options then
	      error "Syntax error: A prgm_options is not given at the 1st line, it must."
	   fi, eqs):
       else
         error "Syntax error: The prgm_input is not a non empty list, it must."
       fi:
       eqs
     end)(prgm_input):

    result[prgm_inputs] := eqs:
    (proc ()
      global prgm_current_options: result[prgm_options] := op(op(prgm_current_options)):
    end)():

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
   end)(eqs):
  catch:
    lprint(lasterror):
    return []
  end try:

  ## Expands the known functions
  eqs := (proc(eqs)
     ### Iterate towards a fixed point
     local fixed_point := proc(f, v_0, max_iterations::posint:=10)
       local v0 := null, v1 := v_0, t:
       for t to max_iterations do
         v0 := f(v1):
         if  v0 = v1 then return v0 fi:
	 v1 := v0
      od:	
     error "Iteratively expanding toward a fixed point failed."
   end:
   fixed_point(proc(eqs)
     global prgm_function:
     eval(subs(prgm_functions, eqs))
   end, eqs)
 end)(eqs);

  result[prgm_expanded] := eqs:
 
   ## Reduces constants
  eqs := evalf(eqs):
  
   ## Expands inner functions
   eqs := (proc(eqs0)
     local
       eqs1, eqs2 := table(), n,
       expand_args := a ->
         if type(a, {function, `+`, `*`}) then 
          op(0, a)(op(map(expand_arg, a)))
	else a fi,  
       expand_arg := a -> 
          if type(a, function) then 
	    n  := prgm_new_symbol("x"):
            eqs2[n = expand_args(a)] := true:
	    n
	  elif type(a, {`+`, `*`}) then
	    expand_args(a)
	 else a fi:
     eqs1 := map(eq ->
        if type(eq, `=`) then
	 op(1, eq) = expand_args(op(2, eq))
       else
         eq
      fi, eqs0):
      [op(eqs1),op(map(e -> op(1,e), op(op(eqs2))))]
   end)(eqs):

  ## To be done
  ### - reintroduces the Id function on sum and product
  ### - factorizes identical expressions, looking the eqs2 table

  result[prgm_flattened] := eqs:

  ## Detects the input
 result[inputs] := indets(eqs, name) minus convert(map(eq -> if type(eq, `=`) then op(1, eq) else eq fi, eqs), set):

 op(result)  
end:
prgm_current_options := op(prgm_default_options):

## Creates a new variable

prgm_new_symbol := proc(prefix:: string)
   global prgm_new_symbol_count: prgm_new_symbol_count := prgm_new_symbol_count + 1:
   convert(cat(prefix, '_', prgm_new_symbol_count), name):
 end:
prgm_new_symbol_count := 0:

## Saves the package

save prgm_default_options,  prgm_functions, prgm_compile, prgm_current_options, prgm_new_symbol, prgm_new_symbol_count, "../../braincraft/programmatoid.mw":

## Functional tests 

prgm_compile([
  prgm_options = { omega = 10 },
  a = H(H(b)),
  Delay(b, i_t, 10)
 ]);
 
 
  
