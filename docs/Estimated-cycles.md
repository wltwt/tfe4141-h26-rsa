# Estimated Cycle Count

## Requirements

- The hardware accelerator should process the test case in **less than 400 ms**.
- A total of **500 independent messages** must be processed.
- The RSA implementation supports operands up to **256 bits**.

## Montgomery Multiplication

The Montgomery unit processes **2 cycles per bit**.

For a 256-bit operand:

$$
256 \times 2 = 512 \text{ cycles}
$$

The Montgomery unit also requires additional cycles for control and the final conditional subtraction $S-N$. 
For a preliminary estimate, we assume approximately **3 additional cycles**:

$$
L \approx 512 + 3 = 515 \text{ cycles/MonPro}
$$

where $L$ is the estimated number of cycles required for one Montgomery multiplication.

The exact number of cycles will depend on the final datapath and FSM implementation.

## Number of Montgomery Operations

The RSA implementation uses **square-and-multiply**.

For an exponent with $k$ bits and Hamming weight $h$ (number of 1-bits):

$$
N_{\text{MonPro}} = k + h + 1
$$

where:

- $k = 256$ bits
- $h \approx 128$ one-bits for a typical 256-bit exponent
- $+1$ accounts for the final conversion from Montgomery form

Therefore:

$$
N_{\text{MonPro}} = 256 + 128 + 1 = 385
$$

The estimated total number of cycles is then:

$$
N_{\text{cycles}} = 385 \times 515
$$

$$
N_{\text{cycles}} \approx 198\,000 \approx 200\,000 \text{ cycles}
$$

This is a preliminary estimate and does not include all top-level control and communication overhead.

---

# Optimization

The main goal is to minimize the total processing time for the 500 messages.

There are two main parameters we can optimize:

1. **Clock frequency**
2. **Number of parallel RSA cores**

The optimal configuration is ultimately limited by the available FPGA resources and the maximum achievable clock frequency.

## Clock Frequency

The execution time for one RSA operation is approximately:

$$
T_{\text{RSA}} =
\frac{N_{\text{cycles}}}{f_{\text{clk}}}
$$

Using the estimated 200,000 cycles:

$$
T_{\text{RSA}} =
\frac{200\,000}{f_{\text{clk}}}
$$

This gives:

| Clock frequency | Time / RSA operation |
|----------------:|---------------------:|
| 25 MHz          | 8.00 ms              |
| 50 MHz          | 4.00 ms              |
| 100 MHz         | 2.00 ms              |
| 150 MHz         | 1.33 ms              |
| 200 MHz         | 1.00 ms              |

The maximum achievable clock frequency is determined by the FPGA implementation. 
It depends mainly on the critical path, particularly the wide arithmetic operations in the Montgomery datapath.

The actual maximum frequency should therefore be determined after **synthesis and timing analysis**.

---

## Number of Cores

Since the 500 messages are independent, multiple RSA cores can process messages in parallel.

Let:

- $N = 500$ = number of messages
- $N_{\text{cores}}$ = number of RSA cores
- $N_{\text{cycles}} \approx 200\,000$ cycles/message
- $f_{\text{clk}}$ = clock frequency

Ignoring communication and scheduling overhead, the total processing time can be approximated by:

$$
T_{\text{total}}
\approx
\frac{N \times N_{\text{cycles}}}
{N_{\text{cores}} \times f_{\text{clk}}}
$$

For example, using a 100 MHz clock:

| Number of cores | Approx. time for 500 messages |
|----------------:|------------------------------:|
| 1               | 1.00 s                        |
| 2               | 0.50 s                        |
| 4               | 0.25 s                        |
| 8               | 0.125 s                       |
| 16              | 0.0625 s                      |

Increasing the number of cores improves throughput, but the number of cores is limited by the available FPGA resources.

Adding more cores may also reduce the maximum achievable clock frequency due to increased routing and resource utilization.

---

## Next Steps

The final configuration should be determined experimentally:

1. Implement and synthesize **one RSA core**.
2. Measure the actual **$F_{\max}$** and resource utilization.
3. Verify the actual number of cycles required by the Montgomery FSM.
4. Replicate the core to test **2, 4, 8, ... cores**.
5. Compare resource utilization, clock frequency, and total processing time.
6. Select the configuration that satisfies the **400 ms requirement** while making efficient use of the available FPGA resources.
