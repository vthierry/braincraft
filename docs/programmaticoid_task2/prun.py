# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_utils import h, H, Id, TimeDelay, State, NetworkState, evaluate
## Here consider the task environment
from environment_2 import Environment

class ProgrammaticState(State):

        delay = TimeDelay()
 
        def __init__(self):
                self.data["challenge"] = 2
                self.data["runs"] = 10
                self.data["rate"] = 0
                self.data["timeout"] = 0

        def update(self):
                """ Implements a Task 1,2, or 3 minimal solution
                """
                # Variables initialization
                if self.data["time"] == 1:
                        self.data["b_d"], self.data["b_t"], self.data["b_a"], self.data["b_k"], self.data["b_w"], self.data["g_e1"], self.data["g_d1"] = 0, 0, 0, 0, 0, 0, 0
                # Navigation state update
                self.data["b_d"] = 1 if self.data["challenge"] == 2 and self.data["b_k"] == 0 and self.data["c_lb"] == 1 else self.data["b_d"]
                self.data["b_k"] = 1 if self.data["challenge"] != 2 or self.data["c_lb"] == 1 or self.data["c_rb"] == 1 else self.data["b_k"] 
                self.data["b_1"] = self.data["b_t"] == 0 and self.data["p_a"] > 0.8
                self.data["b_a"]  =  ((1 if self.data["g_e1"] > 0 and self.data["g_e"] > self.data["g_e1"]  else self.data["b_a"]) if self.data["challenge"] != 3 else (1 if self.data["g_d1"] > 0 and self.data["g_e"] - self.data["g_e1"]  > self.data["g_d1"] else self.data["b_a"])) if self.data["b_1"] == 1 else self.data["b_a"]
                self.data["b_d"] = 1 - self.data["b_d"] if  self.data["b_1"] == 1 and self.data["b_a"] == 1 else self.data["b_d"] 
                if self.data["b_1"] == 1 and self.data["b_a"] == 1:
                        self.delay.start(self.data["time"], 42)
                self.data["b_w"] = self.delay.is_done(self.data["time"])
                self.data["b_0"] = self.data["b_t"] == 1 and (self.data["p_a"] < 0.7 if self.data["b_a"] == 0 else self.data["b_w"] == 1)
                self.data["b_t"] = 1 if self.data["b_1"] == 1 else 0 if self.data["b_0"] == 1 else self.data["b_t"]
                self.data["b_s"] = self.data["b_1"] == 0 and self.data["b_0"] == 1
                # Manages gauge energy
                self.data["g_d1"]  = self.data["g_e"] -  self.data["g_e1"] if self.data["b_s"] == 1 and self.data["g_e1"] > 0 and self.data["g_e"] > self.data["g_e1"] else self.data["g_d1"] 
                self.data["g_e1"]  = self.data["g_e"] if self.data["b_s"] == 1 else self.data["g_e1"] 
                # Forward versus backward control
                self.data["d_l"] = 0.035 * self.data["p_r"] if self.data["b_t"] == 0 else 5 if self.data["b_d"] == 1 else 0
                self.data["d_r"] = 0.035 * self.data["p_l"] if self.data["b_t"] == 0 else 5 if self.data["b_d"] == 0 else 0

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
        evaluate(Bot, Environment, ProgrammaticState)


