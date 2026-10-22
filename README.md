# TFE4141 RSA FPGA

Minimal VHDL project for the PYNQ-Z1 FPGA (`xc7z020clg400-1`).

```text
rtl/          Editable VHDL sources
sim/          Testbenches (initially empty)
constraints/  Future pin and timing constraints
scripts/      create_project.tcl
vivado/       Generated local projects, ignored by Git
```

The instructor's integration kit remains separate and is not included in the
project. Existing work in `docs/`, `high-level-code/` and `pytests/` is preserved;
`pytests/` remains ignored for personal experiments.

Use Git and Vivado with Zynq-7000 device support; this setup was checked with
Vivado 2025.2. Make `vivado` available in your terminal, for example by sourcing
your installation's `settings64.sh` on Linux or using the Vivado command prompt
on Windows. No additional board files are required.

```sh
git clone https://github.com/wltwt/tfe4141-h26-rsa.git
cd tfe4141-h26-rsa
vivado -mode batch -source scripts/create_project.tcl
vivado -mode gui vivado/rsa/rsa.xpr
```

**Sources are referenced directly, not copied.** Saving a source file in Vivado
edits the repository file that Git tracks. Put `.vhd` or `.vhdl` files directly
in `rtl/` or `sim/`, and `.xdc` files directly in `constraints/`; the script does
not search subdirectories. When using Vivado's **Add Sources**, leave **Copy
sources into project** unchecked. Create new files in these repository folders.

The design top is `rsa_core`; change the corresponding line in the Tcl script
when needed. The existing starter still computes message XOR modulus.

To simulate, add a testbench in `sim/`, add it to Vivado's simulation sources
(or regenerate), select **Set as Top**, then **Run Behavioral Simulation**.
There is no testbench included yet. There are also no pin or timing constraints;
this skeleton is not ready for a board bitstream.

After adding/removing files or changing project settings, close Vivado and
regenerate. Save source edits first, then move the old project to an unused
backup name:

```sh
mv vivado/rsa vivado/rsa.previous
vivado -mode batch -source scripts/create_project.tcl
```

On Windows, move the folder with Explorer or PowerShell. Ordinary source edits
only need saving and rerunning the relevant Vivado operation.

Commit source changes using Git; keep generated files under ignored `vivado/`:

```sh
git status --short
git diff
git add rtl sim constraints scripts .gitignore README.md
git diff --cached
git commit -m "Describe the changes"
git push
```
