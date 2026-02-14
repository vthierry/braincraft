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
plots[setcolors](map(c->"Black",[$1..16])):
plotsetup(jpeg, plotoutput="explog.jpg", plotoptions="width=600,height=600"):
plot(map(mu_->subs(p[1]=x, p[2]=1/2,mu=mu_,expand(subs(K=2, el))),[1,2,100]),x=0..1);
plotsetup(x11):











