# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import sigmoid, step, State, NetworkState, evaluate
## Here consider the 1st environment for task1
from environment_1 import Environment

class ProgrammaticState(State):
        def __init__(self):
                self.data["challenge"] = 1
                self.data["runs"] = 10
                self.data["delay"] = 0.1
                
        def update(self):
                """ Here the bot simply moves forward and turn left when possible
                """
                self.data["d_l"] = 0.05 * self.data["p_r"] +  0.004 * self.data["p_r"]
                self.data["d_r"] = 0.05 * self.data["p_l"]
                if self.data["time"] % 10 == 0:
                        print(f"t:{self.data["time"]:3d} g_e: {self.data["g_e"]:.3f} p_l: {self.data["p_l"]:.3f} p_r: {self.data["p_r"]:.3f} ")

                # Voir utiliser que les deux capteurs extremes

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
	evaluate(Bot, Environment, ProgrammaticState)
