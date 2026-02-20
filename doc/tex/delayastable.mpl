
## Sigmoid function in the discrete case
h := x -> 1/(1+exp(-4*x)):
sl := rsolve({v(t+1) = (1-g) * v(t) + g * z0, v(0) = v0}, {v(t)});

## Delay calculation
solve(subs({v0 = 0, v(t) = 1/2, z0 = 1}, sl), {t});
solve(subs({v0 = 0, v(t) = 1/2, z0 = 1}, sl), {g});
##### latex(%); latex(%%);

## Oscillation period

### Verifies the symmetry
evalb(solve(subs({v0 = 1/3, v(t) = 2/3, z0 = 1}, sl), {t}) = solve(subs({v0 = 2/3, v(t) = 1/3, z0 = 0}, sl), {t}) and solve(subs({v0 = 1/3, v(t) = 2/3, z0 = 1}, sl), {g}) = solve(subs({v0 = 2/3, v(t) = 1/3, z0 = 0}, sl), {g}));

### Period derivation
map(u->op(1,u) = 2 * op(2, u), solve(subs({v0 = 1/3, v(t) = 2/3, z0 = 1}, sl), {t}));
map(u->op(1,u) = 2 * op(2, u), solve(subs({v0 = 1/3, v(t) = 2/3, z0 = 1}, sl), {g}));
##### latex(%); latex(%%);
