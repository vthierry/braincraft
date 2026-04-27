# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import h, H, Id, TimeDelay, State, NetworkState, evaluate
## Here consider the 1st environment for task1
from environment_1 import Environment

class ProgrammaticState(State):

        delay = TimeDelay()
        b_w = 0 # Detects a future turn and wait moving straighahead  before turning
        delay_before_turning = 17
        b_t = 0 # Starts turning and wait until the quarter-turn is done
        delay_during_turning = 18
        b_s = 0 # Stops turning move straighahead and wait to avoid turning again too fast
        delay_after_turning = 1


        def __init__(self):
                self.data["challenge"] = 1
                self.data["runs"] = 1
                self.data["delay"] = 0.4
                self.data["timeout"] = 100

        def update(self):
                """ Here the bot simply moves forward and turn left when possible
                """
                o = self.delay.is_on(self.data["time"])
                if self.b_w == 0 and (self.data["p_l"] < 0.6 or self.data["p_r"] < 0.6):
                        self.b_w =1
                        self.delay.start(self.data["time"], self.delay_before_turning)
                elif self.b_w == 1 and self.b_t == 0 and self.b_s == 0 and (not self.delay.is_on(self.data["time"])):
                        self.b_t = 1
                        self.delay.start(self.data["time"], self.delay_during_turning)
                elif self.b_t == 1 and (not self.delay.is_on(self.data["time"])):
                       self.b_s = 1
                       self.b_t = 0
                       self.delay.start(self.data["time"], self.delay_after_turning)
                elif self.b_s == 1 and (not self.delay.is_on(self.data["time"])):
                       self.b_s = 0
                       self.b_w = 0
                if  self.b_t == 1:
                        self.data["d_l"], self.data["d_r"]  = 5, 0
                else:
                        self.data["d_l"], self.data["d_r"] = 0.02 * self.data["p_l"], 0.02 * self.data["p_r"]
                print(f"t:{self.data["time"]:3d} d:{self.delay.stop:3d} g_e: {self.data["g_e"]:.2f} p: [{self.data["p_l"]:.2f} {self.data["p_r"]:.2f}] b_wtso: {self.b_w:1d}{self.b_t:1d}{self.b_s:1d}{o:1d}", flush=True)

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
	evaluate(Bot, Environment, ProgrammaticState)
