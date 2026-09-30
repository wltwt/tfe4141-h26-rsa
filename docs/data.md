# In/Out Data

| Signal | Width | Direction | Meaning |
|---|---:|---|---|
| `key_n` | 256 bit | In | Mod $n$ |
| `key_e` | 256 bit | In | Exponent |
| `msgin_data` | 256 bit | In | Message $M$ |
| `msgin_valid` | 1 bit | In | Valid signal message |
| `msgin_ready` | 1 bit | Out | Core ready signal |
| `msgin_last` | 1 bit | In | Last message signal |
| `msgout_data` | 256 bit | Out | Calculate Signal |
| `msgout_valid` | 1 bit | Out | Result valid |
| `msgout_ready` | 1 bit | In | Receiver can accept message |
| `msgout_last` | 1 bit | Out | Last result block in transmission |
| `rsa_status` | 32 bit | Out | Custom status signal |

# Registers

| Register index | Suggested name | Width | Access from CPU | Purpose |
|---|---|---:|---|---|
| 0–7 | `key_n` | 8 $\cdot$ 32 = 256 bits | Read/write | RSA modulus $n$ |
| 8–15 | `key_e` | 8 $\cdot$ 32 = 256 bits | Read/write | Public $e$ for encryption, private $d$ for decryption |
| 16–23 | `mont_r2` | 8 $\cdot$ 32 = 256 bits | Read/write | Precomputed $R^2\bmod n$, used to convert the input into Montgomery form |
| 24–31 | `mont_one` | 8 $\cdot$ 32 = 256 bits | Read/write | Precomputed $R\bmod n$, the Montgomery representation of 1 |
| 32 | `rsa_status` | 32 bits | Read-only | Core status. (e.g.  bit0=busy) |