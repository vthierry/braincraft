# Braincraft challenge — 1000 neurons, 100 seconds, 10 runs, 2 choices, no reward
# Copyright (C) 2025 Nicolas P. Rougier, help or Thierry.Vieville@inria.fr 2026
# Released under the GNU General Public License 3
"""
Evaluation of the performances of a programmatoid
"""
import numpy as np
from bot import Bot
from environment_1 import Environment

if __name__ == "__main__":
    from challenge_callback import evaluate
    evaluate(Bot, Environment, model=10,debug=True)
  
