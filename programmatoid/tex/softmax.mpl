# Softmax transform i[1..K] -> o between average and max

## Sigmoid function 
h := x -> 1/(1+exp(-4*x)):

Heavyside(0) := 1/2: H := v ->
    if type(v, `<`) or type(v, `<=`) then (if evalb(v) = true then 1 elif evalb(v) = false then 0 else 'procname(args)'  fi)
 elif type(v, constant) then Heaviside(v)
 else 'procname(args)' fi:

read "../../braincraft/programmatoid.mw":

## Numerical test of a max function

maxtest := themax -> evalb(map(evalb, map(proc() local i := op(map(()->rand(16)(), {$0..rand(8)()})): max(i) = themax(i) end, {$1..rand(32)()})) = {true}):
ok := evalb(maxtest(max) = true and maxtest(min) = false);

## Programmatoid max function

b1 := (k, a) -> convert(map((l, a) -> H(a[k]>a[l]), [$1..k-1], a), `*`) * convert(map((l, a) -> H(a[k]>=a[l]), [$k+1..nops(a)], a), `*`):
pmax := proc()  local k: add(b1(k, [args]) * args[k], k = 1..nargs) end:

maxtest(pmax);

b2 := proc(k, a) local l: H(add(H(a[k]>a[l]), l = 1..k-1) + add(H(a[k]>=a[l]), l = k+1..nops(a)) - nops(a) + 3/2) end:
pmax := proc() local k: add(b2(k, [args]) * args[k], k = 1..nargs) end:

maxtest(pmax);

pmax := proc() local k: add((g/nargs + (1-g) * b2(k, [args])) * args[k], k = 1..nargs) end:

## Plot the function for some g
plotsetup(jpeg, plotoutput="softmax.jpg", plotoptions="width=600,height=600"):
plot(map(g_->eval(subs(g=g_, pmax(x, 1/2))), [0,1/4,1/2,3/4,1]),x=-1..1,color=["Black", "Orange", "Red","Green","Blue"]);
#plotsetup(x11):


