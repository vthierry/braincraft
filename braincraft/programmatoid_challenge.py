# Braincraft challenge — 1000 neurons, 100 seconds, 10 runs, 2 choices, no reward
# Copyright (C) 2025 Nicolas P. Rougierr, patched by Thierry.Vieville@inria.fr 2026
# Released under the GNU General Public License 3
import time
import numpy as np
from bot import Bot
from camera import Camera

def sigmoid(x):
    """Defines the normalized sigmoid function.
    """
    return 1 / (1 + np.exp(-4 * x))

def step(x):
    """Defines the step (or Heavyside) function.
    """
    return 0 if x < 0 else 1 if x > 0 else 1/2

# Implements the network state init and update

class State:
    """ Implements a programmatoid state.
    """

    data = dict()
    """ The state data: dictionary.
         - Stores all input, output, and internal variables, including parameters.
    """
    
    def init(self):
    	""" Inits some data, if needed.
    	"""
        
    def update(self):
    	""" Updates, at each step, the data from input and sets the output value.
        """

class NetworkState(State):
    """ Implements a neuronoid network
       data: dictionary
       - "network" : The network parameters list as defined below.
           - It is a `W_in, W, w, W_out` list
               - `p = bot.camera.resolution`
               - `n` # The network size.
               - `W_in(n,2*p+3)` is the input weights.
               - `W(n,n)` is the internal weights, thus `W(row-count,column-count)`.
               - `w(n)` is the internal offsets..
               - `W_out(1,n)` is the output weights.
           - The following elements are constant in this implementation:
               - `warmup = 0` number of iteration before start, NOT used.
               - `leak(n, 1) = 0`  the leak vector, or scalar, ALWAYS 0 (leak is integrated in the reccurent connections).
               - `f = sigmoid`  is the internal non-linearity, ALWAYS a sigmoid.
               - `g = identity`  is the output non-linearity, ALWAYS the  identity.
       - "X"   : The network current state.
           - `X[0:n]` is the local state, initialized to 0.
       - "I"   : The current input.
           - `I[:p] = 1 - bot.camera.depths`.
           - `I[p:2*p] = bot.camera.values`.
           - `I[2*p,2*p+3] = (bot.hit, bot.energy, 1.0)`.
       - "O" : The returned output
     """
    def init(self):
        W_in, W, w, W_out = data["network"]
        n = w.size
        data["X"] = np.zeros((n,1))
        
    def update(self):
        W_in, W, w, W_out = data["network"]
        I, X = data["I"], data["X"]
        X = sigmoid(np.dot(W_in, I) + np.dot(W, X) + w)
        data["O"] = np.dot(W_out, X)
        data["X"] = X

def evaluate(Bot, Environment, State):
    """Evaluates a programatoid

    Parameters
    ----------
    Bot: class.
     - The Bot class to use for evaluation.

    Environment: class.
    - The Environment class to use for evaluation.

    State: class.
    - The system State used  for evaluation.
        - It calls state.init() which initializes the state parameters and variables, at the beggining of each run.
        - It calls state.update()  which computes the next `O` value from the input `I` or preprocessed input, at each step.
         - It uses the dict state.data for input and ouput values.
   - The system state contains the following parameters for evaluation
      - state.data["challenge"] : Challenge number 1, 2, or 3
      - state.data["timeout"] :  Maximum number of iterations (default is 0, i.e., no bound).
     - state.data["runs"] :  Number of runs (default is 1).
     - state.data["display"] : Whether to display animation or not (default is True).
     """
    state = State()
 
    state.init()
        
    debug = False if "display" in state.data.keys() and state.data["display"] == False else True
    runs = int(state.data["runs"]) if "runs"  in state.data.keys() else 10
    timeout = int(state.data["timeout"]) if "timeout" in state.data.keys() else 0
    challenge = int(state.data["challenge"]) if "challenge" in state.data.keys() else 0
    if not challenge in (1, 2, 3):
        print(f"  no execution of the evaluation, state.data[\"challenge\"] = '{challenge}' is not 1,2, or 3")
        return
    
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
        
    iterations = []
    distances = []
    hits = []

    for i in range(runs):
        environment = Environment()

        if debug:
            graphics["topview"].set_data(environment.world_rgb)
            
        bot = Bot()
        
        p = bot.camera.resolution

        state.init()
        
        distance = 0
        hit = 0
        iteration = 0

        # Initial update
        if debug:
            bot.camera.render(bot.position, bot.direction,
                              environment.world, environment.colormap)
        else:
            bot.camera.update(bot.position, bot.direction,
                              environment.world, environment.colormap)

        # Run until no energy
        while bot.energy > 0 and (timeout == 0 or timeout > iteration):

            energy = bot.energy

            p = bot.camera.resolution
            I = np.zeros((2*p+3,1))
            I[:p,0] = 1 - bot.camera.depths
            I[p:2*p,0] = bot.camera.values
            I[2*p:,0] = bot.hit, bot.energy, 1.0
            state.data["I"] = I

            ##  Input preprocessing
            state.data["p_l"] = np.mean(I[0:int(p/2),0])
            state.data["p_r"] = np.mean(I[int(p/2):p,0])
            state.data["c_lb"] = 1 if 4 in I[p:p+int(p/2),0] else 0
            state.data["c_lr"] = 1 if 5 in I[p:p+int(p/2),0] else 0
            state.data["c_rb"] = 1 if 4 in I[p+int(p/2):2*p,0] else 0
            state.data["c_rr"] = 1 if 5 in I[p+int(p/2):2*p,0] else 0

            state.update()

            if "d_l" in state.data.keys() and "d_r" in state.data.keys():
                state.data["O"] = 5 * (state.data["d_l"] - state.data["d_r"])
            O = state.data["O"]

            iteration += 1
            p = bot.position
            bot.forward(O, environment, debug)
            distance += np.linalg.norm(p - bot.position)
            hit += bot.hit

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

        distances.append(distance)
        hits.append(hit)
        iterations.append(iteration)
    if debug:
        elapsed = time.time() - start_time
        print(f"\texecution: \u007b\n\t\tchallenge: {challenge}\n\t\ttimeout: {timeout}\n\t\truns: {runs}\n\t\tdisplay: {"true" if debug else "false"}\n\t\tevaluation-time: \"{elapsed:.2f} sec\" \n\t\titerations: \"{np.mean(iterations):.2f} ± {np.std(iterations):.2f}\" \n\t\tdistances: \"{np.mean(distances):.2f} ± {np.std(distances):.2f}\"\n\t\thits: \"{np.mean(hits):.2f} ± {np.std(hits):.2f}\"\t\n \t\u007d")


