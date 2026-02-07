
Heaviside(0) := 1/2: H := Heaviside:

upsilon := 2: nu := 1/3:

# Checks the Task 1 programmatoid equations

eq := {
 q_p_ = 'if q_p = 1 or nu > g_e then  1 else 0 fi'
 } = {
 q_p_ = H(upsilon * q_p + (nu - g_e))
 };

ok := {}: for g_e in {0,1/4,1/2,3/4,1} do for q_p in {0,1} do ok := ok union {evalb(eq)} od od: ok;




