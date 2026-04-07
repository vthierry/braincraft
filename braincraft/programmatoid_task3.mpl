# Task3 implementation as a programmatoid
subs(
## Constants values
  gamma  = 5/(w/2),	### Saturates the correction at 5° if the depth difference is half of the path-width.
  alpha  = 90,		    	### Saturates the correction at +-90° to make the quarter-turn.
  beta  = w, 			### Triggers the quarter-turn.
  w = 1/4,			### Rough estimation of the path-width.
  eta  = b*c/s,			### Energy consumption threshold if no source on the path.
  c = 1/1000,	         	### Energy consumption at each step.
  s = 1/100,              	###  Speed: location increment at each steps.
  b = 3/2 	      	 	###  Distance bound between the starting point and the putative energy sources.
,[
  prgm_options = { challenge = 3 },
 ## Direction choices
 b_di = And(g_e > g_e1,  g_e1 < g_e2), ### Increase starts, after a decrease.
 b_ii = And(g_e > g_e1,  g_e1 > g_e2),  ### Increase continues.
 b_id = And(g_e < g_e1,  g_e1 > g_e2), ### Increase has just stopped, now decreases.
 b_i  = H(g_c2 > g_c1),                           ###  Previous energy increase is higher.
 ### Updates direction
 q_p  = If_b(And(b_id, b_i), 1 - q_p, q_p),   ### Changes direction if better choice detected.
 ###  Updates internal cumulative increase
 g_c2 = If_v(b_di, g_c1, g_c2),
 g_c1 = If_v(b_di, (g_e - g_e1), b_ii, g_c1 + (g_e - g_e1), g_c1), 
 g_e2 = g_e1,
 g_e1 = g_e,
  ## Navigation equations
  t_l = If_b(And(q_p = 1, beta > p_l), 1, 0),
  t_r = If_b(And(q_p = 0, beta > p_r), 1, 0),
  d_l = gamma * p_r + alpha * t_l,
  d_r = gamma * p_l + alpha * t_r
 ]):

