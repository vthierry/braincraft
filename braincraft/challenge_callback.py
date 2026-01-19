# Braincraft challenge — 1000 neurons, 100 seconds, 10 runs, 2 choices, no reward
# Copyright (C) 2025 Nicolas P. Rougierr, patched by Thierry.Vieville@inria.fr 2026
# Released under the GNU General Public License 3
import time
import numpy as np
from bot import Bot
from camera import Camera

# Defines some non-linear functions
def identity(x):
    """Defines the identity function value.
    """
    return x

def sigmoid(x):
    """Defines the normalized sigmoid function.
    """
    return 1 / (1 + np.exp(-4 * x))

def d_sigmoid(x):
    """Defines the normalized sigmoid function derivative.
    """
    e_x = np.exp(-4 * x)
    e_xp1 = 1 + e_x
    return 4 * e_x / (e_xp1* e_xp1)

def step(x):
    """Defines the step (ot Heavyside) function.
    """
    return 0 if x < 0 else 1

# Defines the next function for a the global neurnoid model and state
def next_output_from_network(context):
    """Returns the next bot output and update the state.

    Parameter
    ----------
    context: dictionary
    - "model" : The model parameters list as defined below.
        - It is a `W_in, W, W_out, warmup, leak, f, g` list for this next_output_from_network() callback, where:
            - `p = bot.camera.resolution`.
            - `n` # The network size
            - `W_in(n,2*p+3)` is the input weights.
            - `W(n,n)` is the internal weights, thus `W(row-count,column-count)`.
            - `W_out(1,n)` is the output weights.
            - `warmup` is the number of iteration, before the bot starts.
            - `leak(n, 1)`  the leak vector, or scalar.
            - `f = tanh`  is the internal non-linearity.
            - `g = identity`  is the internal non-linearity.
    - "state"   : The model current input and state.
        - It is a `I, X` list where:
            - `I[:p] = 1 - bot.camera.depths`.
            - `I[p:2*p] = bot.camera.values`.
            - `I[2*p,2*p+3] = (bot.hit, bot.energy, 1.0)`.
            - `X[0:network_size(),0]` is the local state.
    """
    W_in, W, W_out, warmup, leak, f, g = context["model"]
    I, X = context["state"]
    X = leak*X + (1-leak)*f(np.dot(W_in, I) + np.dot(W, X))
    O = np.dot(W_out, g(X))
    context["state"] = I, X
    return O
            
def default_model(n):
    bot = Bot()
    p = bot.camera.resolution
    np.random.seed(1234567)
    Win  = np.random.uniform(-1,1, (n,2*p+3))
    W = np.random.uniform(-1,1, (n,n))*(np.random.uniform(0,1, (n,n)) < 0.1)
    Wout = 0.1*np.random.uniform(-1, 1, (1,n))
    warmup = 0
    f = sigmoid
    g = identity
    leak = 0
    model = Win, W, Wout, warmup, leak, f, g
    return model

def evaluate(Bot, Environment, model, next_output=next_output_from_network, runs=1, debug=False):
    """Evaluates a model.

    Parameters
    ----------
    Bot: class.
      Bot class to use for evaluation.

    Environment: class.
      Environment class to use for evaluation.

    model : list or int
     - A `W_in, W, W_out, warmup, leak, f, g` list, or …
     - A `n` defining the default model size,

    next_output: function
    - The `O = next_output(context)` iteration function.

    runs : int
    - Number of runs.

    debug : boolean
    - Whether to display animation or not.
    
    Returns
    =======
    Mean score (float) and standard deviation over the given number of runs.
    """

    if isinstance(model, int):
        model = default_model(model)
    W_in, W, W_out, warmup, leak, f, g = model
    n = np.shape(W)[0]

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
        I, X = np.zeros((2*p+3,1)), np.zeros((n,1))
        context = dict({"model": model, "state": (I, X)})

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
            
            O = next_output(context)
            
            # During warmup, bot does not move
            if iteration > warmup:
                p = bot.position
                bot.forward(O, environment, debug)
                distance += np.linalg.norm(p - bot.position)
                hits += bot.hit
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


