# RSA implementation on FPGA

Working notes. Just a preliminary design to keep track of implementation strategies, not a final implementation.

## Theory

We want to implement modular exponentiation with focus on hardware optimization,

$$
C = M^e \bmod n
$$

Here, M is the message, e is the exponent, and n is the modulus. Our design uses up to 256-bit operands. The same hardware can decrypt by using the private exponent.

## Optimizations for hardware

**Square-and-multiply** reduces the number of multiplications needed. Starting with x = 1, we read the exponent from most significant to least significant bit: square x, then multiply by M if the bit is 1.

We also use the identity

$$
(a\cdot b)\bmod n = \big((a\bmod n)\cdot(b\bmod n)\big)\bmod n
$$

to reduce intermediate results after each multiplication. This avoids storing the enormous full value of M^e. Reduced values fit within 256 bits, although internal arithmetic can require more bits.

## Montgomery multiplication

Montgomery multiplication makes repeated modular multiplication practical without general division by n in each operation.

For odd n, choose $R = 2^{256} > n$ and represent a value a as:

$$
\bar a = aR \bmod n
$$

A Montgomery product computes:

$$
\operatorname{MonPro}(A,B) = ABR^{-1} \bmod n
$$

Therefore, multiplying two Montgomery-form values gives their product in Montgomery form. We convert the message once, perform the exponentiation in this form, and convert the result back at the end. Reduction uses the power-of-two structure of R; the exact hardware implementation is still to be chosen.

## Proposed architecture

Starting with one reusable Montgomery unit per RSA core.

- Registers hold the converted message M_bar, intermediate result x_bar, exponent, and modulus.
- Operand multiplexers select the inputs to the Montgomery unit.
- An FSM and bit counter control the sequence and wait for each operation to finish.

The core does

-  Convert M to M_bar and initialize x_bar to R mod n (the representation of 1).
-  For each exponent bit, from most significant to least significant
   - Square: x_bar = MonPro(x_bar, x_bar).
   - If the bit is 1: x_bar = MonPro(x_bar, M_bar).
-  Convert back: result = MonPro(x_bar, 1).

The same unit is reused for squaring and multiplication. A Montgomery operation may take many clock cycles; one algorithm step does not imply one clock cycle.

## Parallelism and next steps

We expect to process around 500 independent messages. Multiple RSA cores could process different messages simultaneously, with input distribution and ordered output collection.

Two Montgomery units inside one core are another option, using the right-to-left exponentiation variant from the lectures. Our initial preference is one unit per core, then multiple cores if resources allow. This prioritizes total throughput; the best configuration still needs measurement.


Next step is to choose the internal Montgomery datapath and estimate its cycle count. With k exponent bits, h one-bits, and L cycles per Montgomery operation, the main exponentiation loop takes approximately (k + h)L cycles, excluding conversion and control overhead.
