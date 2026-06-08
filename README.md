# Simple DSP48A1 Block in Verilog

A synthesizable Verilog implementation of the **Xilinx DSP48A1** slice. This module models a hardware Digital Signal Processing (DSP) block, featuring an integrated pre-adder, an $18 \times 18$ multiplier, cascading paths, and a 48-bit post-adder/subtractor.

---

##  Key Features
* **Configurable Pipelining:** Turn internal register stages on/off using parameters to optimize speed or latency.
* **Dynamic Control:** Use the 8-bit `OPMODE` input to change how data flows through the multipliers and adders on the fly.
* **Cascading Support:** Includes `BCIN`/`BCOUT` and `PCIN`/`PCOUT` to easily chain multiple DSP blocks together (great for FIR filters).

---

##  Vivado Synthesis & Timing Results

This design successfully synthesizes in AMD Xilinx Vivado and **fully meets timing constraints** with zero errors.

### ⏱️ Timing
* **Worst Negative Slack (WNS):** 4.762 ns (Passed ✅)
* **Worst Hold Slack (WHS):** 0.140 ns (Passed ✅)
* **Failing Endpoints:** 0

###  Resource Utilization
* **Slice LUTs:** 237
* **Slice Registers:** 180
* **DSPs Used:** 1

---

## Simulation & Verification

The project includes a **self-checking testbench** (`DSP_tb.v`) that automatically verifies the resets and various arithmetic operational pathways.

### How to Run:
1. Load `DSP.v` and `DSP_tb.v` into your favorite simulator (Vivado, ModelSim, or QuestaSim).
2. Run the simulation.
3. Check the console transcript. It will explicitly print output confirmations like:
   ```text
   RESET SUCCESS
   PATH 1 SUCCESS!
   PATH 2 SUCCESS!
