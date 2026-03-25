# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import sigmoid, step, State, NetworkState, evaluate
## Here consider the 1st environment for task1
from environment_1 import Environment

class ProgrammaticState(State):
        def update(self):
                """ Here the bot simply moves forward and turn left when possible
                """
                self.data["d_l"] = 40 * self.data["p_r"] + 90 * step(0.25 - self.data["p_l"])
                self.data["d_r"] = 40 * self.data["p_l"]

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
	evaluate(Bot, Environment, ProgrammaticState, challenge = 1, runs = 10, debug = True)
