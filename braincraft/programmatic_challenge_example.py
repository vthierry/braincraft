# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import evaluate

## Here consider the 1st environment ofor task1
from environment_1 import Environment

## Initializes some state variables if needed
def init_state(state): 
        
## Updates the required state variable and sets the output value
## - Here the bot simply moves forward and turn left when possible
def update_state(state): 
        state["d_o"] = 40 * (state["p_l"] - state["p_r"]) + 90 * step(0.25 - state["p_l"])

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
	evaluate(Bot, Environment, runs = 10, debug = True)
