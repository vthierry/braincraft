# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_utils import h, H, Id, TimeDelay, State, NetworkState, evaluate
## Here consider the environment for task
from environment_@ import Environment

class ProgrammaticState(State):

        ### Turning state of the bot
        # - b_d: Initial quarter-turn direction, either rightward (1) or rightward (0).
        # - b_k: Unknown (0) versus (1) known direction from a blue cue.
        # - b_t:  Forward (0) versus turning (1) mode.
        # - b_a: Quarter-turn (0) versus About-turn (a) turning mode.
        # - b_w: About-turn delay.
        delay = TimeDelay()
        # - g_e1: Energy after the last turn.
        # - g_d1: Energy difference, before the next turn, and after the last turn.
        ### Color detection
        # - b_r: Blue detected on the right

        def __init__(self):
                self.data["challenge"] = @
                self.data["runs"] = 1
                self.data["rate"] = 0
                self.data["timeout"] = 1000
                
        def update(self):
                """ Implements a Task1 minimal solution
                """
                # Variables initialization
                if self.data["time"] == 1:
                        self.data["b_d"], self.data["b_k"], self.data["b_t"], self.data["b_a"], self.data["b_w"], self.data["g_e1"], self.data["g_d1"] = 0, 0, 0, 0, 0, 0, 0
                # Detects the correct initial direction
                if self.data["challenge"] == 2:
                        if self.data["b_k"] == 0:
                                if self.data["c_lb"] == 1:
                                        self.data["b_k"] = 1
                                        self.data["b_d"] = 1
                                if self.data["c_rb"] == 1:
                                        self.data["b_k"] = 1
                                        self.data["b_d"] = 0
                else:
                        self.data["b_k"] = 1
                # Starts turning because of the wall proximity
                if self.data["b_t"] == 0 and self.data["p_a"] > 0.80:
                        self.data["b_t"] = 1
                        # Decides either quarter-turn or about-turn
                        if self.data["challenge"] == 3:
                                self.data["b_a"] = 1 if self.data["g_d1"] > 0 and self.data["g_e"] - self.data["g_e1"]  > self.data["g_d1"] else self.data["b_a"] 
                        else:
                                self.data["b_a"] = 1 if self.data["g_e1"] > 0 and self.data["g_e"] > self.data["g_e1"]  else self.data["b_a"] 
                        # Starts the delay if in about-turn
                        if self.data["b_a"] == 1:
                                self.data["b_d"] = 1 - self.data["b_d"]
                                self.delay.start(self.data["time"], 40)
                                self.data["b_w"] = 1
                # Stops turning, either in quarter-mode when wall proximity is small enough or in about-turn after a fixed delay
                elif self.data["b_t"] == 1 and (self.data["p_a"] < 0.7 if self.data["b_a"] == 0 else self.delay.is_done(self.data["time"])):
                        self.data["b_t"] = 0
                        if self.data["g_e1"] > 0 and self.data["g_e"] > self.data["g_e1"]:
                                self.data["g_d1"]  = self.data["g_e"] -  self.data["g_e1"]
                        self.data["g_e1"]  = self.data["g_e"]
                        self.data["b_w"] = 0
                # Forward versus turning control
                if self.data["b_t"] == 1:
                        if self.data["b_d"] == 1:
                                self.data["d_l"], self.data["d_r"]  = 5, 0
                        else:
                                self.data["d_l"], self.data["d_r"]  = 0, 5
                else:
                        self.data["d_l"], self.data["d_r"] = 0.035 * self.data["p_r"], 0.035 * self.data["p_l"]
             # Dumps data state
                print(f"   \u007b t: {self.data["time"]:3d} p_lar: [{self.data["p_l"]:.2f} {self.data["p_a"]:.2f} {self.data["p_r"]:.2f}] g_e: [{self.data["g_e"]:.2f} > {self.data["g_e1"]:.2f} ±{self.data["g_d1"]:.2f}] b_d: {self.data["b_d"]} b_t: {self.data["b_t"]}  b_a: {self.data["b_a"]}  b_h: {1 if self.data["b_h"] else 0}  \u007d", flush=True)

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
        evaluate(Bot, Environment, ProgrammaticState)


