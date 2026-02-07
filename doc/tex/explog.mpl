# Exp-log transform series

el := log(sum(exp(mu * p[k]), k = 1..K)) / mu:

## Series at mu = 0
series(el, mu = 0, 2);

## Series at mu = +oo

### The p[1] extracted formula
el2 := p[1] + log(1 + sum(exp(-mu * (p[1] - p[k])), k = 2..K)) / mu:

#### Numerical verification of the formula (no algebraic derivation easy to find)
ok := evalf(map(n->simplify(subs(map(k->(p[k] = rand(1..10)()/mu), {$1..5}), simplify(expand(subs(K = rand(2..5)(),  el2 - el))))), {$1..10}));








