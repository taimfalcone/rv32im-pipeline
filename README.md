# rv32im-pipeline

A 5-stage pipelined RISC-V processor written in Verilog. Runs the full RV32I base integer ISA and passes synthesis timing at 150 MHz on Kintex-7. M-extension (multiply) is in progress.

I built this to extend a single-cycle RV32I processor I wrote in EECS 31L at UC Irvine. I wanted to use this as an opportunity for me to learn more about Verilog and multi cycle processors. The single-cycle version is tagged 'v1.0-single-cycle' if you want to see the starting point.

## Status

- **v1.0** Single-cycle RV32I baseline (tagged 'v1.0-single-cycle')
- **v2.0** 5-stage pipeline with forwarding, hazard detection, and branch flush
- **v2.1 (current)** Vivado synthesis, timing closure at 150 MHz, CPI measurement
- **v3.0 (in progress)** M extension: MUL, MULH, MULHU, MULHSU

## Architecture

Standard 5-stage pipeline: Instruction Fetch, Instruction Decode, Execute, Memory Access, Writeback. Four pipeline registers between stages.

**Hazard handling:**
- Data forwarding from EX/MEM and MEM/WB into the ALU inputs in EX. EX/MEM has priority when both stages match, so the newer value wins.
- Load-use hazard detection in ID. Stalls PC and IF/ID for one cycle, inserts a bubble into ID/EX. The MEM/WB to EX forwarding path then delivers the loaded value.
- Branch and jump flush. Branches resolve in EX. On a taken branch, JAL, or JALR, the two in-flight instructions in IF and ID get turned into NOPs. 2-cycle penalty per taken control transfer.
- Static predict-not-taken as the branch policy.
- Register file has a same-cycle write/read forward path so a WB write in cycle N is visible to an ID read in cycle N

**Instructions supported (full RV32I):**
- R-type: ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA
- I-type ALU: ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI
- Memory: LW, SW
- Branches: BEQ, BNE, BLT, BGE, BLTU, BGEU
- Jumps: JAL, JALR
- Upper immediate: LUI, AUIPC

## Synthesis Results

Target device: Kintex-7 xc7k70tfbv676-1
Clock constraint: 100 MHz (10 ns period)

| Metric              | Value          |
|---------------------|----------------|
| Fmax                | 150 MHz        |
| LUTs                | 858 (2.09%)    |
| Flip-Flops          | 873 (1.06%)    |
| BRAM                | 0              |
| DSP                 | 0              |
| Setup slack (WNS)   | +3.362 ns      |
| Hold slack (WHS)    | +0.056 ns      |
| Timing met          | Yes            |

The register file and both memories fit in distributed LUT-RAM, so no block RAM was needed. No DSP blocks either since there is no multiplier yet. That changes once the M extension lands.

## Performance

**CPI: 1.34** at steady state, measured over 70 retired instructions on a mixed workload (dependent ALU chains, memory ops, one taken branch).

Ideal CPI for a 5-stage pipeline is 1.0. The over head comes from load-use stalls (one cycle each) and branch flush penalties (two cycles per taken branch or jump). The measurement excludes pipeline fill and drawin, so it reflects steady-state thoughtput rather than startup cost.

## Verification

Tested in Vivado behavioral simulation using two Verilog testbenches:

- 'tb_processor.v' checks register file contents against known-good values after execution (functional regression).
- 'tb_processor_perf.v' measures steady-state CPI.

The functional tests cover:

- Basic ALU operations
- Back-to-back dependent instructions (proves EX/MEM and MEM/WB forwarding work)
- Load-use hazard (proves the stall inserts a bubble and forwarding delivers the loaded value on the next cycle)
- Taken and not-taken branches (proves the flush kills wrong-path instructions)
- JAL and JALR (proves flush plus link register writeback)
- LUI and AUIPC (proves upper-immediate and PC-relative constant generation)

Not tested against the official RISC-V compliance suite yet. That is planned.

## How to Run

Requires Xilinx Vivado 2022.1 or newer.

1. Open Vivado and create a project targeting `xc7k70tfbv676-1` or any 7-series device. The design is portable.
2. Add all design `.v` files as Design Sources.
3. Add the testbench you want as a Simulation Source and set it as the simulation top module.
4. Add `timing.xdc` as a Constraints file.
5. Behavioral simulation: Flow Navigator, Run Simulation, Run Behavioral Simulation.
6. Synthesis: Flow Navigator, Run Synthesis. After it finishes, Open Synthesized Design and check Reports, Report Timing Summary and Report Utilization.

## Author

Tai Falcone - [LinkedIn](https://www.linkedin.com/in/taimfalcone/)

Independent project built on top of the single-cycle processor from UC Irvine EECS 31L
