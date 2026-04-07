# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import sigmoid, step, State, NetworkState, evaluate
## Here consider the 1st environment for task1
from environment_1 import Environment

class ProgrammaticState(State):
        def __init__(self):
                self.data["challenge"] = 1
                self.data["runs"] = 50
                
        def update(self):
                """ Here the bot simply moves forward and turn left when possible
                """
                self.data["d_l"] = 0.05 * self.data["p_r"] + 90 * step(0.25 - self.data["p_l"])
                self.data["d_r"] = 0.05 * self.data["p_l"]
                print(f"p_l: {self.data["p_l"]} p_r: {self.data["p_r"]} ")

                # Voir utiliser que les deux capteurs extremes

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
	evaluate(Bot, Environment, ProgrammaticState)
