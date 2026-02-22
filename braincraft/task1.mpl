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
  b = 3/2,	      	 	###  Distance bound between the starting point and the putative energy sources.
### General constant values
  omega  = 10, 	        ###  Constant to transforms a neuronoid or a boolean product to a step-function threshold.
  omega_ = 1000 	        ###  Constant to transforms a neuronoid to the dentity function.
,[
  ## Navigation equations
  d_o = gamma * (p_l - p_r) + alpha * (t_l - t_r),
  t_l = If_b(q_p = 1, H(beta - p_l), 0),
  t_r = If_b(q_p = 0, H(beta - p_r), 0),
  ## Direction choice
  q_p = If_b(Or(q_p = 1, eta > g_e), 1, 0)
]):

