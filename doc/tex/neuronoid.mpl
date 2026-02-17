
## Sigmoid function and properties
h := x -> 1/(1+exp(-4*x)):

## Linear relation with tanh
ok := evalb(0 = convert(h(x) - (1+tanh(2 * x))/2, exp));

### Series around huge values
simplify(series(h(x), x = x0, 2));

### Basic sigmoid values
limit(h(x),x=-infinity), h(0), D(h)(0), limit(h(x),x=+infinity);
evalb(simplify(expand(h(x) = 1 - h(-x))));

## Approximation by arctan
h_a := x->1/2+arctan(Pi*x)/Pi:
plots[setcolors](map(c->"Black",[$1..16])):
plotsetup(jpeg, plotoutput="sigmoidatan.jpg", plotoptions="width=600,height=600");
plot([x->h(x), x->h_a(x)]);
plotsetup(x11);
ok := evalb(infinity = int(h(x) - h_a(x),x=0..infinity));
limit(h_a(x),x=-infinity), h_a(0), D(h_a)(0), limit(h_a(x),x=+infinity);
evalb(simplify(expand(h_a(x) = 1 - h_a(-x))));
x_max := fsolve(diff(h(x)-h_a(x), x), x = 0.5..2);
e_max := evalf(h(x_max)-h_a(x_max));

## First order continous differential equation and discrete approximation, with variable and fixed input
dsolve({tau * D(v)(t) + v(t) = z(t), v(0) = v0}, {v(t)});
dsolve({tau * D(v)(t) + v(t) = z0, v(0) = v0}, {v(t)});
rsolve({v(t+1) = (1-g) * v(t) + g * z(t), v(0) = v0}, {v(t)});
rsolve({v(t+1) = (1-g) * v(t) + g * z0, v(0) = v0}, {v(t)});

### Continous/discrete correspondence
simplify(solve({(1-g)^t = exp(-t/tau)}, g) assuming 0 < g, g < 1);
simplify(solve({(1-g)^t = exp(-t/tau)}, tau) assuming 0 < g, g < 1);

