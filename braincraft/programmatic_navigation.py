# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import h, H, Id, TimeDelay, State, NetworkState, evaluate
## Here consider the 1st environment for task1
from environment_1 import Environment

class ProgrammaticState(State):

        delay = TimeDelay()
        quater_turn_step_delay = 18
        turning = 0 

        def __init__(self):
                self.data["challenge"] = 1
                self.data["runs"] = 1
                self.data["rate"] = 0.2
                self.data["timeout"] = 500

        def update(self):
                """ Here the bot simply moves forward and turn left when possible
                """
                if self.turning == 0 and self.data["p_a"] > 0.8:
                        self.turning = 1
                        self.delay.start(self.data["time"], self.quater_turn_step_delay)
                elif self.turning == 0 and self.data["p_a"] < 0.5 and abs(self.data["p_l"] - self.data["p_r"]) > 0.15:
                        self.turning = 2
                        self.delay.start(self.data["time"], self.quater_turn_step_delay)
                elif  self.turning == 1 and not self.delay.is_on(self.data["time"]):
                        self.turning = 0
                if  self.turning > 0:
                        self.data["d_l"], self.data["d_r"]  = 5, 0
                else:
                        self.data["d_l"], self.data["d_r"] = 0.035 * self.data["p_l"], 0.035 * self.data["p_r"]
                print(f"   \u007b t:{self.data["time"]:3d} g_e: {self.data["g_e"]:.2f} p: [{self.data["p_l"]:.2f} {self.data["p_a"]:.2f} {self.data["p_r"]:.2f}] turning: {self.turning} \u007d", flush=True)

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
        evaluate(Bot, Environment, ProgrammaticState)
