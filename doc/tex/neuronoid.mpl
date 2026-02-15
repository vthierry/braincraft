
## Sigmoid function and properties
h := x -> 1/(1+exp(-4*x)):

## Linear relation with tanh
ok := evalb(0 = convert(h(x) - (1+tanh(2 * x))/2, exp));

## Approximation by arctan
h_err := x-> (2*h(x/2)-1) - (arctan(Pi/2*x)/(Pi/2)):
ok := evalb(infinity = int(h_err(x),x=0..infinity));
#####plot([tanh, x->2*h(x/2)-1, x->arctan(Pi/2*x)/(Pi/2)],color=[blue,green,red]);

### Basic sigmoid values
h__ := limit(h(x),x=-infinity), h(0), D(h)(0), limit(h(x),x=+infinity);
evalb(simplify(expand(h(x) = 1 - h(-x))));

## First order continous differential equation and discrete approximation, with variable and fixed input
dsolve({tau * D(v)(t) + v(t) = z(t), v(0) = v0}, {v(t)});
dsolve({tau * D(v)(t) + v(t) = z0, v(0) = v0}, {v(t)});
rsolve({v(t+1) = (1-g) * v(t) + g * z(t), v(0) = v0}, {v(t)});
rsolve({v(t+1) = (1-g) * v(t) + g * z0, v(0) = v0}, {v(t)});

### Continous/discrete correspondence
simplify(solve({(1-g)^t = exp(-t/tau)}, g) assuming 0 < g, g < 1);
simplify(solve({(1-g)^t = exp(-t/tau)}, tau) assuming 0 < g, g < 1);
