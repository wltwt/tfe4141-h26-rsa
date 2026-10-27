# RSA implementation on FPGA

Working notes. Just a preliminary design to keep track of implementation strategies, not a final implementation.

## Theory

We want to implement modular exponentiation with focus on hardware optimization,

$$
C = M^e \bmod n
$$

Here, M is the message, e is the exponent, and n is the modulus. Our design uses up to 256-bit operands. The same hardware can decrypt by using the private exponent.

We select modulus $n=pq$, where $n<2^{256}$, which in this project will be supplied by the testbench. 


## Optimizations for hardware

**Square-and-multiply** reduces the number of multiplications needed. Starting with $x = 1$, we read the exponent from most significant to least significant bit: square $x$, then multiply by $M$ if the bit is 1.

We also use the identity

$$
(a\cdot b)\bmod n = \big((a\bmod n)\cdot(b\bmod n)\big)\bmod n
$$

to reduce intermediate results after each multiplication. This avoids storing the enormous full value of $M^e$. Reduced values fit within 256 bits, although internal arithmetic can require more bits.


## Montgomery multiplication

Montgomery multiplication makes repeated modular multiplication practical without general division by n in each operation.

For odd n, choose $R = 2^{256} > n$ and represent a value a as:

$$
\bar a = aR \bmod n
$$

A Montgomery product computes:

$$
\text{MonPro}(A,B) = ABR^{-1} \bmod n
$$

Therefore, multiplying two Montgomery-form values gives their product in Montgomery form. We convert the message once, perform the exponentiation in this form, and convert the result back at the end. Reduction uses the power-of-two structure of R; the exact hardware implementation is still to be chosen.

A benefit of montgomery comes from reduction of extensive hardware needed for comparing values, insted we only have to identify if a number is odd, which is a fairly cheap operation.


## Proposed architecture

Starting with one reusable Montgomery unit per RSA core.

- Registers hold the converted message `M_bar`, intermediate result `x_bar`, exponent, and modulus.
- Operand multiplexers select the inputs to the Montgomery unit.


The core does

- Convert M to M_bar and initialize x_bar to R mod n (the representation of 1).
- For each exponent bit, from most significant to least significant
   - Square: `x_bar = MonPro(x_bar, x_bar)`.
   - If the bit is 1: `x_bar = MonPro(x_bar, M_bar)`.
- Convert back: `result = MonPro(x_bar, 1)`.

The same unit is reused for squaring and multiplication. A Montgomery operation may take many clock cycles; one algorithm step does not imply one clock cycle.


For the implementation we use the following hardware

- registers (holds `M_bar`, `x_bar`, exponent and modulus)
- operand-mux
- montgomery-unit
- counter (8-bit?) that keeps track of the current bit
- FSM


### FSM

It should on a high level do

1. Wait for message (need a busy line probably)
2. Initialize message (convert to montgomery)
3. Square numbers
4. Check for exponent bit (1=do MonPro->save result, 0=skip)
5. Next bit
6. Convert back (MonPro(x_bar, 1))
7. Return result (wait for receiver to accept)

The main goal (complemented by a counter) is therefore to control the sequence and wait for each operation to finish.

## Inside Montgomery Unit

- A separate accumulator $S$ which holds intermediate values for the Montgomery operations, this  resets between each multiplication sequence.
- A and B-registers for each of the terms that are being multiplied.
- Should implement its own FSM

For the final step in the sequence it will check if $S\geq n$, such that


```math
S_{\text{final}} =
\begin{cases}
S-n & S \ge n \\
S & S < n
\end{cases}
```


Since we are working with unsigned integers the subtractor is able to tell if $S<n$ occurs in the final comparison step, due to the result being a negative number in that case. Therefore, if the FSM receives `borrow=1`, it sends a signal `load_s=0` which results in the final subtraction not being stored as the final result, then it proceeds to sending a `done`-signal which the external FSM then takes care of the next steps for. 

In the case of $S\geq n$, we end up with a positive number in the final $(S-n)$-correction. Meaning `borrow=0`, we then store the result of $S-n$ into $S$ as the resulting value.




## Hardware Considerations

A wide adder may limit the clock frequency. A narrower, reused adder can shorten the critical path and reduce area, at the cost of more cycles per Montgomery operation.


## Parallelism and next steps

We expect to process around 500 independent messages. Multiple RSA cores could process different messages simultaneously, with input distribution and ordered output collection.

Two Montgomery units inside one core are another option, using the right-to-left exponentiation variant from the lectures. Our initial preference is one unit per core, then multiple cores if resources allow. This prioritizes total throughput; the best configuration still needs measurement.


Next step is to choose the internal Montgomery datapath and estimate its cycle count. With k exponent bits, h one-bits, and L cycles per Montgomery operation, the main exponentiation loop takes approximately (k + h)L cycles, excluding conversion and control overhead.
