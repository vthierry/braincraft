# This piece of code shows how to implement a challenge at the programmatic level

import numpy as np
from bot import Bot
from programmatoid_challenge import h, H, Id, TimeDelay, State, NetworkState, evaluate
## Here consider the 1st environment for task1
from environment_1 import Environment

class ProgrammaticState(State):

        ### Turning state of the bot
        # - b_d : Quarter-turn direction, either left (1) or right (0).
        # - b_t :  Forward (0) versus turning (1) mode.
        # - b_t0, b_t1, b_t2, b_t3: Turn 0, 1, or 2 mode.
        # - b_t30, b_t3: Turn 3 before and during the turn modes.
        # - ge_0, ge_1: energy after and before turning in the feeding corridor.
        b_d, b_t, b_t0, b_t1, b_t2, b_t30, b_t3, g_e0, g_e1 = 0, 0, 0, 0, 0, 0, 0, 0, 0
        ### Delay variables
        # - b_3w0, b_3w1: delay variables for turn 3 start and stop.
        delay0, delay1, b_3w0, b_3w1  = TimeDelay(), TimeDelay(), 0, 0
        ### Patch because feeding sometime fails
        # - g_ok : lock the quarter-turn direction if it has been feeding at least 5 times, avoiding spurious direction change, set to -1 to avoid the lock
        g_ok = 0

        def __init__(self):
                self.data["challenge"] = 1
                self.data["runs"] = 1
                self.data["rate"] = 0
                self.data["timeout"] = 0

        def update(self):
                """ Implements a Task1 minimal solution
                """
                # Starts turning because of the wall distance
                if self.b_t == 0 and self.b_t30 + self.b_t3 == 0 and self.data["p_a"] > 0.8:
                        self.b_t = 1
                        # Counts the turns
                        if self.b_t0 + self.b_t1 + self.b_t2 == 0:
                                self.b_t0 = 1
                        elif self.b_t1 + self.b_t2 == 0:
                                self.b_t1 = 1
                                self.b_t0 = 0
                        elif self.b_t2 == 0:
                               self.b_t2 = 1
                               self.b_t1 = 0
                        # Stores energy before and after the feeding corridor
                        if self.b_t2 == 1:
                                self.g_e0 = self.data["g_e"]
                        elif self.b_t1 == 1:
                                self.g_e1 = self.data["g_e"]
                        elif self.b_t0 == 1:
                                self.g_e0 = 0
                                self.g_e1 = 0
                elif self.b_t == 1 and self.b_t30 + self.b_t3 == 0 and self.data["p_a"] < 0.7:
                        self.b_t = 0
                 # Updates time delay variables
                if self.b_t == 0 and self.b_t30 == 0 and self.b_t3 == 0 and self.b_t2 == 1:
                        self.b_t3w0 = 0
                        self.delay0.start(self.data["time"], 8)
                self.b_t3w0 = self.delay0.is_done(self.data["time"])
                if self.b_t30 == 1 and self.b_t3w0 == 1:
                        self.b_t3w1 = 0
                        self.delay1.start(self.data["time"], 18)
                self.b_t3w1 = self.delay1.is_done(self.data["time"])
                # Starts turning because of a left crossing
                if self.b_t == 0 and self.b_t30 + self.b_t3 == 0 and self.b_t2 == 1:
                        self.b_t2 = 0
                        self.b_t30 = 1
                elif self.b_t30 == 1 and self.b_t3w0 == 1:
                        self.b_t = 1
                        self.b_t3 = 1
                        self.b_t30 = 0
                elif self.b_t3 == 1 and self.b_t3w1 == 1:
                        self.b_t = 0
                        self.b_t3 = 0
                        # Changes direction if energy did not increase
                        if  self.g_ok < 0.5 and self.g_e0 <  self.g_e1:
                                self.b_d = 1 - self.b_d
                        elif self.g_ok >= 0:
                                self.g_ok = max(1, self.g_ok + 0.1)
                # Implements the turning versus forward modes
                if self.b_t == 1:
                        if self.b_d == 1:
                                self.data["d_l"], self.data["d_r"]  = 5, 0
                        else:
                                self.data["d_r"], self.data["d_l"]  = 5, 0
                else:
                        self.data["d_l"], self.data["d_r"] = 0.035 * self.data["p_r"], 0.035 * self.data["p_l"]
                print(f"   \u007b t: {self.data["time"]:3d} g_e: {self.data["g_e"]:.2f} [{self.g_e0:.2f} {self.g_e1:.2f}] p_lar: [{self.data["p_l"]:.2f} {self.data["p_a"]:.2f} {self.data["p_r"]:.2f}] b_d : {self.b_d} b_t : {self.b_t}  [{self.b_t0} {self.b_t1} {self.b_t2} {self.b_t30}+{self.b_t3}] \u007d", flush=True)

## Runs and evaluate the bot behavior for the given task
if __name__ == "__main__":
        evaluate(Bot, Environment, ProgrammaticState)
