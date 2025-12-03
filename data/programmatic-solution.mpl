#
# Symbolic derivations quoted in programmatic-solution.tex
#

## Sigmoid function and properties
h := v -> 1/(1+exp(-4*v)):

### Basic sigmoid values
h__ := limit(h(v),v=-infinity), h(0), D(h)(0), limit(h(v),v=+infinity);

### Link with Heavide function
d_Hv_1 := int(abs(Heaviside(v)-h(w*v)), v=-infinity..infinity) assuming w > 0;

#### Heaviside approximation for v_oo
v_oo := simplify(solve(h(W_oo * v_oo) = 1 - e_oo, v_oo)) assuming 0 < e_oo, e_oo < 1;
v_oo_ := series(v_oo, e_oo = 0, 2)  assuming 0 < e_oo, e_oo < 1;

### Local behavior of h()
h_v0 := series(h(v), v = v0, 2);
h_v0_1 := simplify(series(coeff(h_v0, v - v0, 1), v0=infinity, 1));

## First order continous differential equation and discrete approximation, with variable and fixed input
dsolve({tau * D(v)(t) + v(t) = z(t), v(0) = v0}, {v(t)});
dsolve({tau * D(v)(t) + v(t) = z0, v(0) = v0}, {v(t)});
rsolve({v(t+1) = (1-g) * v(t) + g * z(t), v(0) = v0}, {v(t)});
rsolve({v(t+1) = (1-g) * v(t) + g * z0, v(0) = v0}, {v(t)});

### Continous/discrete correspondence
simplify(solve({(1-g)^t = exp(-t/tau)}, g) assuming 0 < g, g < 1);
simplify(solve({(1-g)^t = exp(-t/tau)}, tau) assuming 0 < g, g < 1);

## Conditional expression

### Verification in the programmatoid case

ok := {}:
for v_l in 1,0 do
  for v_1 in 0,1 do
    for v_0 in 0,1 do
       ok := ok union {evalb(v_l * v_1 + (1 -v_l) * v_0 = Heaviside(v_1 - W_s * (1 - v_l) - W_d)+Heaviside(v_0 - W_s * v_l - W_d))} assuming 0 < W_d, W_d < 1, 1 < W_s:
    od
  od
 od:
ok;

### Inequalities in the neuronoid case

#### Inequalities of the neuronoid mechanism
ineqs := {}:
for v_l in 0,e,1-e,1 do
  for v_1 in 0,e,1-e,1 do
    ineqs := ineqs union {expand(W_w * v_1 - W_s * (1 - v_l) - W_d) * signum(subs(e = 0, v_l * v_1 - 1/2)) > 0}
  od:
  for v_0 in 0,e,1-e,1 do
     ineqs := ineqs union {expand(W_w * v_0 - W_s * v_l - W_d) * signum(subs(e = 0, (1 - v_l) * v_0 - 1/2)) > 0}
  od
od:
ineqs;

#### Verification of particular solution
eqs0 := {W_d = 1, W_w = 2, W_s = 4, e = 1/8}:
ok := map(evalb, subs(eqs0, ineqs));

#### Verification of the canonical form
assume(
  0 < W_d, 0 < W_s, 0 < W_w, 0 < e, e < 1,
  W_d < W_w, W_d < W_s, W_w < W_s,
  W_w * e < W_d, W_s * e < W_d, W_d + e * (W_s + W_w) < W_w,
  0 < mu, mu + W_s * e < W_d, mu + W_d + e * (W_s + W_w) < W_w,
# these two inequalities are redundant, but maple requires them  
  W_d + e * W_w < W_w, mu < W_d, mu + W_d < W_w): 
ok := map(e -> evalb(op(1, e) < signum(op(2, e))), ineqs);
 
#### Verification of the margin
ok := map(e -> evalb(op(1, e) < signum(op(2, e) - mu)), ineqs);
mu0 := solve(subs(eqs0, {mu + W_s * e < W_d, mu + W_d + e * (W_s + W_w) < W_w}), mu);
