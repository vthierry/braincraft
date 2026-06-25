# Task1,2,3 implementation as a programmatoid
subs(
## Constants values
  gamma  = 0.035,	### Linear feedback gain in forward mode
  alpha  = 5,		    	### Maximal turn angle
  beta _1 = 0.8, 		### Proximity turn trigger threshold
  beta _1 = 0.7,		### Proximity turn stop threshold
  delta  = 40,			### About-turn number of steps
,[
  prgm_options = { challenge = @, networking = false},
  # Bot state control
  b_d = If_b(And(challenge = 2, Not(b_k), c_lb), 1, b_d),
  b_k = If_b(Or(challenge != 2 or c_lb or c_rb, 1, b_k),
  b_1 = And(Not(b_t) , p_a > 0.8),
  b_a = If_b(If_b(challenge = 3, And(g_d1 > 0, g_e - g_e1  > g_d1), And(g_e1 > 0, g_e > g_e1)), 1, b_a),
  b_d = If_b(And(b_1, b_a), Not(b_d), b_d),
  Delay_0(b_w, And(b_1, b_a), delta),
  b_0 = And(b_t, If_b(b_a, b_w, p_a < 0.7)),
  b_t = If_b(b_1, 1, b_0, 0, b_t),
  b_s = And(Not(b_1),  b_0),
  ### Energy variables update
  g_d1 = If_v(And(b_s, g_e1 > 0, g_e > g_e1), g_e - g_e1, g_d1),
  g_e1 = If_v(b_s, g_e, g_e1),
  ### Navigation equations
  d_l = If_v(b_t, If_v(b_d, 5, 0), 0.035 * p_r),
  d_r = If_v(b_t, If_v(b_d, 0, 4), 0.035 * p_l)
]):

