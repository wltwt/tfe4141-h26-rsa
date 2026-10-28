Put `.vhd` and `.vhdl` testbenches directly here. They are added to Vivado's
simulation fileset. 


Result from running `exponentiation_tb` in vivado:

```text
run all
Note: Test 1 PASS: Received expected result
Time: 2745 ns  Iteration: 0  Process: /exponentiation_tb/stim  File: .../tfe4141-h26-rsa/sim/exponentiation_tb.vhd
Note: Next Test: 5^0 mod 13
Time: 2745 ns  Iteration: 0  Process: /exponentiation_tb/stim  File: .../tfe4141-h26-rsa/sim/exponentiation_tb.vhd
Note: Test 2 PASS: Received expected result
Time: 5095 ns  Iteration: 0  Process: /exponentiation_tb/stim  File: .../tfe4141-h26-rsa/sim/exponentiation_tb.vhd
Note: Next Test: 5^1 mod 13
Time: 5095 ns  Iteration: 0  Process: /exponentiation_tb/stim  File: .../tfe4141-h26-rsa/sim/exponentiation_tb.vhd
Note: Test 3 PASS: Received expected result
Time: 7645 ns  Iteration: 0  Process: /exponentiation_tb/stim  File: .../tfe4141-h26-rsa/sim/exponentiation_tb.vhd
Note: Next Test: 5^3 mod 13
Time: 7645 ns  Iteration: 0  Process: /exponentiation_tb/stim  File: .../tfe4141-h26-rsa/sim/exponentiation_tb.vhd
Note: Test 4 PASS: Received expected result
Time: 10395 ns  Iteration: 0  Process: /exponentiation_tb/stim  File: .../tfe4141-h26-rsa/sim/exponentiation_tb.vhd
$stop called at time : 10395 ns : File ".../tfe4141-h26-rsa/sim/exponentiation_tb.vhd" Line 232
```