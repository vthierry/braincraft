# Exp-log transform p[1..K] -> el between average and max

el := log(sum(exp(mu * p[k]), k = 1..K)) / mu:

## Series at µ = 0
series(el, mu = 0, 2);

## Series at µ = +oo

### The p[1] extracted formula
el2 := p[1] + log(1 + sum(exp(-mu * (p[1] - p[k])), k = 2..K)) / mu:

### Verification for a given K, mu = 1 without loss of generality
evalb(expand(subs(K=11,mu=1,exp(el)=exp(el2))));

## Plot the function for some µ	
plotsetup(jpeg, plotoutput="explog.jpg", plotoptions="width=600,height=600"):
plot(map(mu_->subs(p[1]=x, p[2]=1/2,mu=mu_,expand(subs(K=2, el))),[1,2,100]),x=0..1,color=["Red","Green","Blue"]);
plotsetup(x11):

## Sigmoid function approximation
h := x -> 1/(1+exp(-4*x)):

h_ := x -> a + b * h(x - 1) + c * h(x):
sl_exp := solve({h_(-1) = exp(-1), h_(0) = exp(0), h_(1)=exp(1)}, {a, b, c}):
h_exp:= unapply(subs(sl_exp, h_(x)), x):
err_exp := sum(evalf(abs(h_exp(x/50)-exp(x/50))), x = -50..50)/101;
plotsetup(jpeg, plotoutput="expneuronoid.jpg", plotoptions="width=600,height=600"):
plot([exp, h_exp, h_exp-exp],-1..1, color=["Blue", "Green", "Red"]);
plotsetup(x11):
evalf(sl_exp);

log1 := x -> log(1 + x):
h_ := x -> a + b * h(x/10) + c * h(x/2):
sl_log := solve({h_(0) = log1(0), h_(10) = log1(10), h_(2) = log1(2)}, {a, b, c}):
h_log  := unapply(subs(sl_log , h_(x)), x):
err_log := sum(evalf(abs(h_log(x/100)-log1(x/100))), x = 0..100)/101;
plotsetup(jpeg, plotoutput="logneuronoid.jpg", plotoptions="width=600,height=600"):
plot([log1, h_log, h_log-log1],0..10, color=["Blue", "Green", "Red"]);
plotsetup(x11):
evalf(sl_log);



















