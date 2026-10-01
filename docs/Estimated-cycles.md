#   Estimated Cycles

Requirements:
  - The hardware accelerator should run a testcase 4 faster than 400 ms. (Should)



Number of control steps (states in the FSM controlling the computations) = 8 states


## Optimization
It is important that we use as much of the available logic as posssible to get the most efficient design.
### Clock frequency

$T_RSA = Cycles / f_clk$
If we use the estimated number of cycles, 200 000:

$T_RSA = 200000/f_clk$ we can estimate the time based on different clock frequencies.


### Number of cores
