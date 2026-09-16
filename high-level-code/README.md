# High Level Code


The chosen algorithm used is `Montgomery arithmetic on multiprecision integers` implemented in python.

High level code: 

[Montgomery alg. test.py](https://github.com/user-attachments/files/32284541/Montgomery.alg.test.py)
```
 Helper: computes gcd(a, b), used to find modular inverses.
def extended_gcd(a, b):
    if a == 0:
        return b, 0, 1                       # base case: gcd(0, b) = b
    g, x1, y1 = extended_gcd(b % a, a)        # recurse on (b mod a, a)
    x = y1 - (b // a) * x1                    # back-substitute for a's coefficient
    y = x1                                    # b's coefficient carries over
    return g, x, y
 
 
# Helper: computes the modular inverse of a mod m.
def modinv(a, m):
    g, x, _ = extended_gcd(a % m, m)          # solve a*x + m*y = gcd(a, m)
    if g != 1:
        raise ValueError("modular inverse does not exist")  # only exists if gcd = 1
    return x % m                              # normalize into range [0, m)
 
 
# Computes a*b mod n using a single MonPro call.
def ModMul(a, b, n):
    r = 1 << n.bit_length()                   # r = 2^k, smallest power of two > n
    n_prime = (-modinv(n, r)) % r             # n' such that n*n' = -1 mod r
    a_bar = (a * r) % n                       # convert a into Montgomery form
    return MonPro(a_bar, b, n, n_prime, r)    # r, r^-1 cancel -> ordinary a*b mod n
 
 
# Multiplies two Montgomery-form numbers mod n, without dividing by n.
def MonPro(a_bar, b_bar, n, n_prime, r):
    t = a_bar * b_bar                         # Step 1: plain product
    m = (t * n_prime) % r                     # Step 2: multiple of n to cancel low bits
    u = (t + m * n) // r                      # Step 3: divide by r (a shift, not a real div)
    if u >= n:
        return u - n                          # Step 4: final conditional subtraction
    return u
 
 
# Computes M^e mod n using square-and-multiply, powered by MonPro.
def ModExp(M, e, n):
    k = n.bit_length()                        # k = number of bits in n
    r = 1 << k                                # r = 2^k > n
 
    n_prime = (-modinv(n, r)) % r             # n' such that n*n' = -1 mod r
 
    M_bar = (M * r) % n                       # convert base into Montgomery form
    x_bar = r % n                             # Montgomery form of 1 (running accumulator)
 
    for i in range(k - 1, -1, -1):            # scan exponent bits MSB -> LSB
        x_bar = MonPro(x_bar, x_bar, n, n_prime, r)   # always square
        e_i = (e >> i) & 1
        if e_i == 1:
            x_bar = MonPro(M_bar, x_bar, n, n_prime, r)  # multiply in only if bit is 1
 
    x = MonPro(x_bar, 1, n, n_prime, r)       # convert result back out of Montgomery form
    return x
# --- Standalone modular multiplication ---
print(ModMul(7, 3, 13))          # 21 mod 13 = 8

# --- RSA encrypt/decrypt using ModExp ---
n = 3233          # modulus (p=61, q=53 -> n=p*q)
e = 17            # public exponent
d = 2753          # private exponent (d = e^-1 mod phi(n))

message = 100
ciphertext = ModExp(message, e, n)      # encrypt: c = m^e mod n
decrypted = ModExp(ciphertext, d, n)    # decrypt: m = c^d mod n

print(decrypted)
