
Heaviside(0) := 1/2: H := Heaviside:

upsilon := 2: nu := 1/3:

# Checks the Task 1b programmatoid equations

eq := {
 g_i_ = 'if g_c = 0 and nu > g_e then 1 else 0 fi',
 q_p_ = 'if g_i = 0 then  q_p else 1 - q_p fi',
 g_c_ = 'if 2 * nu < g_e then 0 elif g_c = 1 then 1 else g_i fi'
 } = {
 g_i_ = H(H(g_c - 1/2) + H(g_e - nu - 3/2)),
 q_p_ = H(q_p  - 1/2 - upsilon * (1 - g_i)) + H(1/2 - q_p - upsilon * g_i),
 g_c_ = H(g_i - 1/2 - upsilon * g_c - 2 * upsilon *  H(g_e - 2 * nu))
 }:

ok := {}: for g_e in {0,1/4,1/2,3/4,1} do for g_i in {0,1} do for q_p in {0,1} do for g_c in {0,1} do ok := ok union {eq} od od od od: ok;
