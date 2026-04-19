# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import h, H, Id, TimeDelay, State, NetworkState, evaluate
## Here consider the 1st environment for task1
from environment_1 import Environment

class ProgrammaticState(State):

        delay = TimeDelay()

        def __init__(self):
                self.data["challenge"] = 1
                self.data["runs"] = 1
                self.data["delay"] = 0.2
                self.data["timeout"] = 1000

        def update(self):
                """ Here the bot simply moves forward and turn left when possible
                """
                v, t, h = 19, 18, 10
                if self.data["time"] % (4 * v + 4 * t + 2 * h) in (v, v + t + h, 3 * v + 2 * t + h, 3 * v + 3 * t + 1.5 * h):
                        self.delay.start(self.data["time"], t)
                if self.delay.is_on(self.data["time"]):
                        self.data["d_l"], self.data["d_r"]  = 5, 0
                else:
                        self.data["d_l"], self.data["d_r"] = 0.02 * self.data["p_l"], 0.02 * self.data["p_r"]
                print(f"t:{self.data["time"]:3d} g_e: {self.data["g_e"]:.3f} p_l: {self.data["p_l"]:.3f} p_r: {self.data["p_r"]:.3f} ", flush=True)

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
	evaluate(Bot, Environment, ProgrammaticState)
