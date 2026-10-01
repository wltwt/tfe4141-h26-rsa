# What Montgomery is 

Montgomery multiplication computes A*B mod n using only additions and shifts, no division. 

RSA computes M^{e} mod n, which is too big to calculate in one go. Square and multiply breaks it into about 512 smaller multiplication (2 operations x 256 bits). But "mod n" normally needs division, which is slow and takes a lot of hardware. Montgomery gets the same result without dividing.

## The trick: clean up the bottom not the top 

Noraml "mod n" removes n's from the top of the number (division). Montgomery instead makes the bottom of the number clean and chops it off. 

Example (in decimal): 

With n = 7, and the number 23: 

1. 23 does not end in 0 -> add 7 -> 30. Adding n never changes the remainder mod n. 
2. Now it ends in 0 -> chop the 0 -> 3 


In binary, the hardware does the same: if the number is odd, add n (n is odd, so it becomes even), then shift right by 1. Combined with ordinary bit by bit multiplication. These step is just reapeted: 

** Add B (if the bit is 1) -> add n (if odd) -> shift right, repeated 256 times **


![Montgomery multiplication](images/Montgomery%20multiplication.png)

## Montgomery space

Every shift righ halves the number, so 256 sfits divide by 2^{256} = R. Montgomery therefore returns A*B*R^{-1} mod n - the right answer, divided by R. The fix is to tag every number with *R before starting, and at the end remove the tag once. 

Montgomery space is a format where every number is multiplied by R (a power of two), so that hardware can do long chains of modular multiplications using fast shifts instead of slow divisions. NUmbers are converted in once and out once per message. 


## Montgomery diagram

![Montgomery modular exponentiation](images/Montgomery%20modular%20exponentiation.png)
