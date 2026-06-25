
## Sigmoid function and properties
h := x -> 1/(1+exp(-4*x)):

### Computed error magnitude
int(abs(Heaviside(x)-h(w*x)), x=-infinity..infinity) assuming w > 0;

### Residual error asymptotic behavior
series(h(-w), w= infinity, 1);

## Study, in [-1, 1]
plotsetup(jpeg, plotoutput="mollification.jpg", plotoptions="width=600,height=600"):
plot(map(w_->subs(w=w_,h(w * x)), [1,2,5,10,20,50]), x = -1..1, color=["Red","Black","Black","Black","Black","Green"]);

### Approximation at x=1/2
Digits:=3: latex(LinearAlgebra[Transpose](Matrix(map(w->[w,evalf(h(-w/2))],[1,2,5,10,20,50]))));




