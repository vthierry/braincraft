# Braincraft challenge — 1000 neurons, 100 seconds, 10 runs, 2 choices, no reward
# Copyright (C) 2025 Nicolas P. Rougierr, patched by Thierry.Vieville@inria.fr 2026
# Released under the GNU General Public License 3
import time
import numpy as np
from bot import Bot
from camera import Camera

# Defines some non-linear functions

def sigmoid(x):
    """Defines the normalized sigmoid function.
    """
    return 1 / (1 + np.exp(-4 * x))

def step(x):
    """Defines the step (or Heavyside) function.
    """
    return 0 if x < 0 else 1 if x > 0 else 1/2

def init_state_from_network(state):
    """Inits the state from a neuronoid network
    """
   W_in, W, w, W_out = state["network"]
    n = w.size
    state["X"] = np.zeros((n,1))

def update_state_from_network(state):
    """Updates the state from a neuronoid network

    Parameters
    ----------
    state: dictionary
    - "network" : The network parameters list as defined below.
        - It is a `W_in, W, w, W_out` list for this next_output_from_network() callback, where:
            - `p = bot.camera.resolution`, available as `state["camera.resolution"]`.
            - `n` # The network size.
            - `W_in(n,2*p+3)` is the input weights.
            - `W(n,n)` is the internal weights, thus `W(row-count,column-count)`.
            - `w(n)` is the internal offsets..
            - `W_out(1,n)` is the output weights.
         - The following elements are constant in this implementation:
            - `warmup = 0` is the number of iteration, before the bot starts, NOT used.
            - `leak(n, 1) = 0`  the leak vector, or scalar, ALWAYS 0 (leak is integrated in the reccurent connections).
            - `f = sigmoid`  is the internal non-linearity, ALWAYS a sigmoid.
            - `g = identity`  is the output non-linearity, ALWAYS the  identity.
    - "X"   : The network current state.
        - `X[0:n]` is the local state, initialized to 0.
    - "I"   : The network current input.
          - `I[:p] = 1 - bot.camera.depths`.
          - `I[p:2*p] = bot.camera.values`.
          - `I[2*p,2*p+3] = (bot.hit, bot.energy, 1.0)`.
    - "d_o" : The network returned output
    """
    W_in, W, w, W_out = state["network"]
    I, X = state["I"], state["X"]
    X = sigmoid(np.dot(W_in, I) + np.dot(W, X) + w)
    state["d_o"] = np.dot(W_out, X)
    state["X"] = X

def evaluate(Bot, Environment, runs = 1, debug = False):
    """Evaluates a programatoid

    - It calls init_state(state) which initializes the state parameters and variables, at the beggining of each run.

    - It calls update_state(state)  which computes the next `d_o` value from the input `I` or preprocessed input, at each step.

    Parameters
    ----------
    Bot: class.
     - The Bot class to use for evaluation.

    Environment: class.
    - The Environment class to use for evaluation.

    runs : int
    - Number of runs.

    debug : boolean
    - Whether to display animation or not.
    
    Returns
    =======
    Mean score (float) and standard deviation over the given number of runs.
    """

    if debug:
        start_time = time.time()
    
    if debug:
        import matplotlib.pyplot as plt
        from matplotlib.patches import Circle
        from matplotlib.animation import FuncAnimation
        from matplotlib.collections import LineCollection

        environment = Environment()
        world = environment.world
        world_rgb = environment.world_rgb
        
        fig = plt.figure(figsize=(10,5))
        ax1 = plt.axes([0.0,0.0,1/2,1.0], aspect=1, frameon=False)
        ax1.set_xlim(0,1), ax1.set_ylim(0,1), ax1.set_axis_off()
        ax2 = plt.axes([1/2,0.0,1/2,1.0], aspect=1, frameon=False)
        ax2.set_xlim(0,1), ax2.set_ylim(0,1), ax2.set_axis_off()

        graphics = {
            "topview" : ax1.imshow(environment.world_rgb, interpolation="nearest", origin="lower",
                                   extent = [0.0, world.shape[1]/max(world.shape),
                                             0.0, world.shape[0]/max(world.shape)]),
            "bot" : ax1.add_artist(Circle((0,0), 0.05,
                                          zorder=50, facecolor="white", edgecolor="black")),
            "rays" : ax1.add_collection(LineCollection([], color="C1", linewidth=0.5, zorder=30)),
            "hits" :  ax1.scatter([], [], s=1, linewidth=0, color="black", zorder=40),
            "camera" : ax2.imshow(np.zeros((1,1,3)), interpolation="nearest",
                                  origin="lower", extent = [0.0, 1.0, 0.0, 1.0]),
            "energy" : ax2.add_collection(
                LineCollection([[(0.1, 0.1),(0.9, 0.1)],
                                [(0.1, 0.1),(0.9, 0.1)],
                                [(0.1, 0.1),(0.9, 0.1)]],
                               color=("black", "white", "C1"), linewidth=(20,18,12),
                               capstyle="round", zorder=150)) }
        
    scores = []

    for i in range(runs):
        environment = Environment()

        if debug:
            graphics["topview"].set_data(environment.world_rgb)
        
        bot = Bot()
        
        p = bot.camera.resolution

        state = dict({"g_e1" : 1, "g_e2" : 1, "g_c1" : 0, "g_c2" : 0, "camera.resolution" : bot.camera.resolution})
        init_state(state)
        
        distance = 0
        hits = 0
        iteration = 0

        # Initial update
        if debug:
            bot.camera.render(bot.position, bot.direction,
                              environment.world, environment.colormap)
        else:
            bot.camera.update(bot.position, bot.direction,
                              environment.world, environment.colormap)

        # Run until no energy
        while bot.energy > 0:

            energy = bot.energy

            p = bot.camera.resolution
            I[:p,0] = 1 - bot.camera.depths
            I[p:2*p,0] = bot.camera.values
            I[2*p:,0] = bot.hit, bot.energy, 1.0
            state["I"] = I

            ##  Input preprocessing
            state["p_l"] = np.mean(I[0:p/2,0]):
            state["p_r"] = np.mean(I[p/2:p,0]):
            state["c_lb"] = 1 if 4 in I[p:p+p/2,0] 0 else
            state["c_lr"] = 1 if 5 in I[p:p+p/2,0] 0 else
            state["c_rb"] = 1 if 4 in I[p+p/2:2*p,0] 0 else
            state["c_rr"] = 1 if 5 in I[p+p/2:2*p,0] 0 else
            state["g_e2"] = state["g_e1"]
            state["g_e1"] = state["g_e"]
            state["g_e"] = bot.energy
            if  state["g_e"] > state["g_e1"] and state["g_e1"] < state["g_e2"]:
                state["g_c2"] = state["g_c1"]
                state["g_c1"] = state["g_e"] - state["g_e1"]
            if  state["g_e"] > state["g_e1"] and state["g_e1"] > state["g_e2"]:
                state["g_c1"] += state["g_e"] - state["g_e1"]

            update_state(state)
            
            O = state["d_o"]
            
            iteration += 1

            if debug:
                graphics["rays"].set_segments(bot.camera.rays)
                graphics["hits"].set_offsets(bot.camera.rays[:,1,:])
                graphics["bot"].set_center(bot.position)
                if energy < bot.energy:
                    graphics["energy"].set_color( ("black", "white", "C2") )
                else:
                    graphics["energy"].set_color( ("black", "white", "C1") )        

                if bot.energy > 0:
                    ratio = bot.energy/bot.energy_max
                    graphics["energy"].set_segments([[(0.1, 0.1),(0.9, 0.1)],
                                                     [(0.1, 0.1),(0.9, 0.1)],
                                                     [(0.1, 0.1),(0.1 + ratio*0.8, 0.1)]])
                else:
                    graphics["energy"].set_segments([[(0.1, 0.1),(0.9, 0.1)],
                                                     [(0.1, 0.1),(0.9, 0.1)]])            
                graphics["camera"].set_data(bot.camera.framebuffer)
                bot.camera.render(bot.position, bot.direction,
                              environment.world, environment.colormap)
                plt.pause(1/60)

        scores.append(distance)
    if debug:
        elapsed = time.time() - start_time
        print(f"Evaluation completed after {elapsed:.2f} seconds")
        print(f"Final score: {np.mean(scores):.2f} ± {np.std(scores):.2f}")

    return np.mean(scores), np.std(scores)


