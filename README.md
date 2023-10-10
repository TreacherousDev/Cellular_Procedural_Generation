# Cellular_Procedural_Generation
 ProcGen For Grid-Based Roguelike Maps

 The algorithm used in this procedural generator can be best described as a Context-Sensitive Lindenmayer System: a type of tree automaton wherein the production rules are dependent on external factors such as the parent node or its neighboring branches.

As the map is restricted to a 2 dimensional grid, a concept from Cellular Automata called the von-Neumann neighborhood is used to condition the production rules of rooms.

