"""
Functions and types for structured stock-level model components
Justin Angevaare
February 2015
"""

# type stock_db
  """
  A database which contains population size data for each time step and adult class.
  """

# type transition_matrix
  """
  A transition matrix which contains information on the survivorship of an adult into the next age class. For simplicity, initially, this will account for removals due to natural, fishing, and any other forms of mortality. In the future these may be applied and tracked seperately.
  """

# function age_adults!(stock_db::stock_db, transition_matrix::transition_matrix)
  """
  This function will simply apply transition probabilities to the current adult population. This function exists mainly to improve code readability, not due to its complexity.
  """
