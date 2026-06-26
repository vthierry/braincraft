
# Approximation of the sigmoid by arctan

# Both functions plot
h := x -> 1/(1+exp(-4*x)):
h_a := x->1/2 + arctan(Pi*x)/Pi:
h_e := x->1/2 + erf(sqrt(Pi)*x)/2:
h_s := x-> 1/2 + x/(1+abs(2*x)):

plotsetup(jpeg, plotoutput="sigmoidatan.jpg", plotoptions="width=600,height=600"):
plot([h, h_a, h_e,h_s], color=["Red","Blue","Green","Orange"]);
plotsetup(x11):

# Verifies  basic properties
limit(h_a(x),x=-infinity), h_a(0), D(h_a)(0), limit(h_a(x),x=+infinity);
evalb(simplify(expand(h_a(x) = 1 - h_a(-x))));

limit(h_e(x),x=-infinity), h_e(0), D(h_e)(0), limit(h_e(x),x=+infinity);
evalb(simplify(expand(h_e(x) = 1 - h_e(-x))));

limit(h_s(x),x=-infinity), h_s(0), limit(D(h_s)(x), x = 0), limit(h_s(x),x=+infinity);
evalb(simplify(expand(h_s(x) = 1 - h_s(-x))));

# L1 norm
L1_a := 2*int(h(x) - h_a(x), x = 0..infinity);
L1_e := 2*int(h(x) - h_e(x), x = 0..infinity); evalf(%);
L1_s := 2*int(h(x) - h_s(x), x = 0..infinity);

# L0 norm
x_max_a := fsolve(diff(h(x)-h_a(x), x), x = 0.2..2);
e_max_a := evalf(h(x_max_a)-h_a(x_max_a));
x_max_e := fsolve(diff(h(x)-h_e(x), x), x = 0.2..2);
e_max_e := evalf(h(x_max_e)-h_e(x_max_e));
x_max_s := fsolve(diff(h(x)-h_s(x), x), x = 0.2..2);
e_max_s := evalf(h(x_max_s)-h_s(x_max_s));

# Max curvatures
max_c_x_h := evalf(solve({D[1,1,1](h)(x), x > 0}, x));
max_c_h := evalf(subs(max_c_x_h, abs(D[1,1](h)(x))));
max_c_x_h_a := evalf(solve({D[1,1,1](h_a)(x), x > 0}, x));
max_c_h_a  := evalf(subs(max_c_x_h_a, abs(D[1,1](h_a)(x))));
max_c_x_h_e := evalf(solve({D[1,1,1](h_e)(x), x > 0}, x));
max_c_h_e  := evalf(subs(max_c_x_h_e, abs(D[1,1](h_e)(x))));
h_s_d := simplify([D[1](h_s)(x), D[1,1](h_s)(x), D[1,1,1](h_s)(x)]) assuming x > 0;
max_c_x_h_s := {x = 0}:
max_c_h_s  := 4:
