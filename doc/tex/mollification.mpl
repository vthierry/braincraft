
## Sigmoid function and properties
h := x -> 1/(1+exp(-4*x)):

### Computed error
int(abs(Heaviside(x)-h(w*x)), x=-infinity..infinity) assuming w > 0;

### Approximation at x=1/2
Digits:=3: latex(LinearAlgebra[Transpose](Matrix(map(w->[w,evalf(h(-w/2))],[1,2,5,10,20,50]))));




