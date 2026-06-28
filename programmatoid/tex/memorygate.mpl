# Convergence of the memory gate

h := x -> 1/(1+exp(-4*x)):
Heavside(0) := 1/2: H := Heaviside:

## Programmatoid implementation

eq :=  {o[t] = H(i[t] - i_l[t] - 1/2) + H(o[t - 1] + i_l[t] - 3/2)}:
ok := {}:
for v_i in {0, 1} do for v_o in {0, 1} do
  eq_io := {i_l[t] = 1, i[t]  = v_i, o[t - 1] = v_o}:
  ok := ok union subs(eq_io union subs(eq_io, eq), {o[t] = o[t-1]}):
od od: map(evalb, ok);

## Neuronoid binary implementation 

eq_o := {o[t] = h(omega * (i[t] - i_l[t] - 1/2) ) + h(omega * (o[t - 1] + i_l[t] - 3/2))}:
eq_e := {e[t] = beta + h(omega * (e [t-1] - 1/2))}:

### Generates all the four cases
eqs := {}:
for e_i in {{i[t]  = 0}, {i[t]  = 1}} do
  for e_o in {{o[0] = 0, o[t] = e[t], o[t-1] = e[t-1]}, {o[0] = 1, o[t] = 1 - e[t], o[t-1] = 1 - e[t-1]}}  do
    eq := {i_l[t] = 1} union e_i union e_o union {subs(e_i union e_o, beta =  (1 - 2 * o[0]) *  h(-(3/2 - i[t]) * omega))}:
eqs := {op(eqs), eq} od od:

### Verifies the formula
ok := {}: for eq in eqs do 
    eq_e_ := solve(subs(eq, eq_o), {e[t]});
    ok := {op(ok), {simplify(subs(solve(subs(eq, eq_o), {e[t]}), e[t]) - subs(eq_e, eq, e[t]))}}
od: evalb(ok = {{0}});

### Calculates e[1]
map(eq->{op(subs(eq, {i_t = i[t], o_0 = o[0]})),
  op(map(u->op(1,u) = series(op(2, u), exp_omega=infinity, 6), subs(exp(omega)=exp_omega, expand(subs(eq, {subs(eq, e[t-1] = (2 - i[t] - o[0]) * err/exp(omega)^2)}, eq_e)))))},
eqs) assuming err > 0;
