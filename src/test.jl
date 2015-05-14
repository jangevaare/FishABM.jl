"""
Informally test Fish_ABM functions
Justin Angevaare
May 2015
"""

# To use package
using DataFrames, Distributions, Fish_ABM

# Stock assumptions
s_a = stock_assumptions([0.50, 0.50, 0.45, 0.4, 0.4],
                        5,
                        [7500, 15000, 20000, 22500, 25000],
                        500000,
                        0.25,
                        0.25,
                        0.25,
                        [0.00001, 0.00002, 0.000025, 0.000025, 0.000025])

# Randomly generate a simple 3x3 environment_assumptions (id, spawning areas, habitat type and risk1)
e_a = environment_assumptions(reshape(1:(4*4), (4,4)),
                              rand(Bool, (4,4)),
                              rand(1:2, (4,4)),
                              rand(Bool, (4,4)))

# Agent assumptions - weekly mortality risks and growth (weeks until next stage)
a_a = agent_assumptions([[0.03 0.03 0.03]
                         [0.05 0.05 0.05]],
                         [0.05, 0.05, 0.05],
                         [19, 52, 104],
                         fill(0.0, (16,16,3)))

# Try the movement_matrix function to specify the movement transition probability matrix
a_a.movement[:,:,1] = movement_matrix([[0 0 0]
                                       [0 1 0]
                                       [0 0 0]], e_a)
a_a.movement[:,:,2] = movement_matrix([[1 1 2]
                                       [1 6 3]
                                       [1 2 2]], e_a)
a_a.movement[:,:,3] = movement_matrix([[1 1 2]
                                       [1 3 3]
                                       [1 2 2]], e_a)

# Must set initial age distribution of adults, and create an empty dataframe for fishing mortality
s_db = stock_db(DataFrame(age_2=500000,
                          age_3=50000,
                          age_4=20000,
                          age_5=6000,
                          age_6=4000),
                DataFrame(age_2=Int[],
                          age_3=Int[],
                          age_4=Int[],
                          age_5=Int[],
                          age_6=Int[]))

# Try the simulate function
@time a_db = simulate(5, fill(0., 5), s_db, s_a, a_a, e_a)
s_db.population
