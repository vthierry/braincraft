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
  prgm_options = { omega = 100, all_neuronoid = false },
 ## Direction choice
  q_p = If_b(And(g_e < g_e1, g_e1 > g_e2, g_c2 > g_c1), 1- q_p, q_p)  
  ## Navigation equations
  t_l = If_b(q_p = 1, beta > p_l, 0),
  t_r = If_b(q_p = 0, beta > p_r, 0),
  d_o = gamma * (p_l - p_r) + alpha * (t_l - t_r)
 ]):

