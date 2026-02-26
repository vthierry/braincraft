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
       else  'procname(args)'
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
      else 'procname(args)'
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
#  {\tt Softmax(v\_1, …, G)} & Mean-max operator. \\ & $\mbox{{\tt G}} \in [0_{average}, 1_{maximum}]$ controls the mean-max balance.\\
  Latch_b = ((o, b_1, b_c) -> If_b(b_c = 1, o, b_1)),
  Latch_b = ((o, b_1, b_c) -> If_v(b_c = 1, o, b_1)),
  Bistable = (proc(o, i)
       if nargs = 3 then
         o = If(And(o = 0, args[2] = 1), 1, And(o = 1, args[3] = 0), 0, o)
       else
         (proc(o, i)
            local i0 := prgm_new_symbol("i0"): i1 := prgm_new_symbol("i1"):
	    o = If(And(o = 0, i1 = 1), 1, And(o = 1, i0 = 0), 0, 0),
            i1 = If(And(i1 = 0, i = 1), 1, o = 0, 0, i1),
            i0 = If(And(i0 = 0, i = 0), 1, o = 1, 0, i0)
	 end)(o, i)
       fi
       end),
  Spikeup= (proc(o, i)
      local r:= prgm_new_symbol("r"):
      o = If(And(r = 0, i = 1),  1, 0),
      r = If(o = 1, 1, i = 0, 0, r)
     end),
  Delay= (proc(o, i, T)
      local v := prgm_new_symbol("v"), g := if T > 0 then 1 - pow(2, -1/T) else 1 fi:
      o = If (v > 1/2, 1, 0),
      v = (1 - g) * v + g * i
     end),
 Oscillator= (proc(o, c, T)
     local v := prgm_new_symbol("v"), gamma := if T > 0 then 2 - pow(2, 1-1/T) else 2 fi:
     o = If (v < 1/3, 0, 0, v > 2/3, 1, o),
     v = (1 - g) * v + g * (1 - o) * c
     end)
}:

## Compiles a set of equation as a piece of code

prgm_compile := proc(prgm_input:: list)
  global Heaviside, prgm_functions, prgm_current_options, :
  Heaviside(0) := 1/2:

  try
    ## Extracts options from the prgm_input
    prgm_input := (proc(prgm_input)
       global prgm_default_options: local prgm_input_ := prgm_input,  prgm_options_ := {}:
       if type(prgm_input_, list) and nops(prgm_input_) > 0 then
         if type(op(1, prgm_input_), `=`) and op(1, op(1, prgm_input_)) = prgm_options then
           if type(op(2, op(1, prgm_input_)), {list,  set}) then
              prgm_options_ := convert(op(2, op(1, prgm_input_)), set)
           else
             error "The prgm_options is not a set or a list, it must." : 
           fi:
           prgm_input_  := [op(2..nops(prgm_input_), prgm_input_)]:
         fi:
         map(eq -> if type(eq, `=`) and op(1, eq) = prgm_options then error "A prgm_options is not given at the 1st line, it must." fi, prgm_input_)
       else
         error "The prgm_input is not a non empty list, it must."
       fi:
       map(o -> if type(o, `=`) then prgm_current_options[op(1, o)] := op(2, o) else prgm_current_options[o] := true fi, prgm_options_):
       prgm_input_
     end)(prgm_input):

     ## Checks the syntax of the equaltion list
     if not (proc(eqs)
       global prgm_functions:
       local function_names := map(eq -> op(1, eq), prgm_functions),
       check := proc(ok)
         if ok then true else lprint(cat("Syntax error: ", op(map( a-> convert(a, string), [args[2..nops([args])]])))): false fi
       end:
       if not check(type(eqs, list), "The  input is not a list (of equations)") then
         false
       else   
         convert(map(proc(l, eqs)
            local eq := eqs[l]:
           check(type(eq, `=`) or (type(eq, function) and op(0, eq) in function_names),  "This line number '", l, "' of the input '", eq, "' is not an equation or a known function") and
           check((not type(eq, `=`)) or type(op(1, eq), name),  "The left hand side of '", eq, "', line number '", l, "' is not a name") and
           check((not type(eq, `=`) and type(op(2, eq), function)) or op(0, op(2, eq)) in function_names,  "The right hand side of '", eq, "', line number '", l, "' is not a known function")
         end, [$1..nops(eqs)], eqs), `and`)
      fi
     end)() then error "A syntax option has been detected, no compilation" fi:
  catch
    return []
  end try:

  prgm_input 

  # Modifies iteratively the equation-list toward a fixed point
  (proc(eqs)
     local eqs0 := [], eqs1 := eqs, t, max_iterations := 10:
     for t to max_iterations do
        eqs0 := prgm_expand_inner_functions(eval(subs(prgm_functions, eqs1))):
	lprint(eqs1, "=>", eqs0):
        if eqs0 = eqs1 then break else eqs1 := eqs0 fi
     od:
     eqs0
   end)(prgm_input)))
end:
prgm_current_options := op(prgm_default_options):


## Expands inner function appending new equations

prgm_expand_inner_functions := proc(eqs::list(`=`))
   global prgm_functions:
   local eq1, eq2 := []:
   eq1 := map(eq ->
      if type(op(2, eq), function) then
        op(1, eq) = map(proc(a)
           local n:
           if type(a, function) then 
	      n := prgm_new_symbol(""):
	      eq2 := [op(eq2), op(prgm_expand_inner_functions([n = a]))]:
	      n
	   else
	     a
	   fi
       end, op(2, eq)) else eq fi, eqs):
     [op(eq1),op(eq2)]
end:


## Creates a new variable, when expanding the code

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
 
 
  
