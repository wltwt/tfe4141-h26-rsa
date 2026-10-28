# TFE4141 RSA FPGA

Alpha VHDL project for the PYNQ-Z1 FPGA (`xc7z020clg400-1`). Project generation and the recorded simulation use Vivado 2025.2 with Zynq-7000 device support. All HDL files use VHDL-2008.


## Setup

```sh
git clone https://github.com/wltwt/tfe4141-h26-rsa.git
cd tfe4141-h26-rsa
vivado -mode batch -source scripts/create_project.tcl
vivado -mode gui vivado/rsa/rsa.xpr
```

The design top is `rsa_core`. 

Add new files by using `add sources` in vivado. Regenerating will also pick up latest update in the repo.


```sh
mv vivado/rsa vivado/rsa.previous
vivado -mode batch -source scripts/create_project.tcl
```

## Alpha status

The recorded XSim run in `sim/README.md` passes four 8-bit cases using the actual exponentiation and Montgomery modules: `5^3 mod 13 = 8`, `5^0 mod 13 = 1`, `5^1 mod 13 = 5`, and `7^3 mod 13 = 5`.

For the time being `exponentiation_tb` was used to verfiy the design as proof of concept. Later iterations will implement the jupyter interface and precalculated r-values.

Full `rsa_core` constant wiring and ARM/integration-kit support remain unfinished in the current iteration.

## Packaging for delivery

Ensure you have `zip` installed, then on linux run from root folder:
```sh
./scripts/package.sh
```

The script creates a new `dist/rsa-alpha-YYYYMMDD-HHMMSS.zip` containing
`README.md`, `rtl/`, `sim/`, `constraints/`, and the setup script for vivado.

It packages the current saved files, including uncommitted and untracked source
files. Generated Vivado projects and repository metadata are not included.
