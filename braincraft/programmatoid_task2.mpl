# Task1 implementation as a programmatoid
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
  prgm_options = { omega = 100, all_neuronoid = false, Python = "task1" },
 ## Direction choice
 c_cb = If_b(And(c_cb = 0, c_cr = 0, Or(c_lb = 1, c_rb = 1)), 1, g_e < eta/2, 0, c_cb),
 c_cr = If_b(And(c_cb = 0, c_cr = 0, Or(c_lr = 1, c_rr = 1)), 1, g_e < eta/2, 0, c_cr),
 q_p = If_b(Or(c_lb = c_cb, c_lr = c_rr), 0, Or(c_lb = c_cb, c_lr = c_rr), 1, q_p),
  ## Navigation equations
  t_l = If_b(q_p = 1, beta > p_l, 0),
  t_r = If_b(q_p = 0, beta > p_r, 0),
  d_o = gamma * (p_l - p_r) + alpha * (t_l - t_r)
 ]):

