# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import h, H, Id, State, NetworkState, evaluate
## Here consider the 1st environment for task1
from environment_1 import Environment

class ProgrammaticState(State):

        def __init__(self):
                self.data["challenge"] = 1
                self.data["runs"] = 1
                self.data["delay"] = 0.5
                self.data["timeout"] = 1000

        def delay_start(self, T):
                self.last_delay_stop += self.data["time"] + T

        def delay_on(self):
        	return self.last_delay_stop >= self.data["time"]

        last_delay_stop = 0

        def update(self):
                """ Here the bot simply moves forward and turn left when possible
                """
                if self.data["time"] in (20, 200):
                        self.delay_start(20)
                self.data["d_l"] = 0.1  * pow(float(self.data["p_l"]), 2) + (0.5 if self.delay_on() else 0)
                self.data["d_r"] = 0.1 * pow(float(self.data["p_r"]), 2)
                print(f"t:{self.data["time"]:3d} g_e: {self.data["g_e"]:.3f} p_l: {self.data["p_l"]:.3f} p_r: {self.data["p_r"]:.3f} ", flush=True)

                # Voir utiliser que les deux capteurs extremes

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
	evaluate(Bot, Environment, ProgrammaticState)
