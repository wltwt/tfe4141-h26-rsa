#   Estimated Cycles

Requirements:
  - The hardware accelerator should run a testcase 4 faster than 400 ms. (Should)
  - 500 messages are required to be sent. 


We use 2 cycles per bit, so for a 256 bit signal we get 2 * 256 = 512 cycles from the bits.
In addition 
Number of control steps (states in the FSM controlling the computations) = 8 states

$N_monPro = k + h + 1$

## Optimization
It is important that we use as much of the available logic as posssible to get the most efficient design.
### Clock frequency

$T_RSA = Cycles / f_clk$
If we use the estimated number of cycles, 200 000:

$T_RSA = 200000/f_clk$ we can estimate the time based on different clock frequencies.

| Clock frequency | Time / RSA |            
| --------------: | ---------: |
|          25 MHz |     8.0 ms |
|          50 MHz |     4.0 ms |
|         100 MHz |     2.0 ms |
|         150 MHz |    1.33 ms |
|         200 MHz |     1.0 ms |



The maximum clock frequency is dependent on the FPGA-model used. This is usually done after the synthesis.

### Number of cores
In order to reduce the time, we can aslo distribute the messages independently onto multiple cores. 
N = number of messages = 500
We can calculate this the time using this formula:

$T_total ≈ (N * Cycles) / (N_cores * f_clk)$
f_clk = 100MHz

| Cores | Approx. time for 500 messages |
| ----: | ----------------------------: |
|     1 |                        1.00 s |
|     2 |                        0.50 s |
|     4 |                        0.25 s |
|     8 |                       0.125 s |
|    16 |                      0.0625 s |

This is also limited by the available hardware. 

