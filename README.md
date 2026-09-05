# rv32im-pipeline

A 5-stage pipelined RISC-V processor written in Verilog. Runs the full RV32I base integer ISA and passes synthesis timing at 150 MHz on Kintex-7. M-extension (multiply) is in progress.

I built this to extend a single-cycle RV32I processor I wrote in EECS 31L at UC Irvine. I wanted to use this as an opportunity for me to learn more about Verilog and multi cycle processors. The single-cycle version is tagged 'v1.0-single-cycle' if you want to see the starting point.

## Status

- **v1.0** Single-cycle RV32I baseline (tagged 'v1.0-single-cycle)
- **v2.0** 5-stage pipeline with forwarding, hazard detection, and branch flush
- **v2.1 (current)** Vivado synthesis, timing closure at 150 MHz, CPI measurement
- **v3.0 (in progress)** M extension: MUL, MULH, MULHU, MULHSU

## Architecture

Standard 5-stage pipeline: Instruction Fetch, Instruction Decode, Execute, Memory Access, Writeback. Four pipeline registers between stages.

** Hazard handling:**
- Data forwarding from EX/MEM and MEM/WB into the ALU inputs in EX. EX/MEM has priority when both stages match, so the newer value wins.
- Load-use hazard detection in ID. Stalls PC and IF/ID for one cycle, inserts a bubble into ID/EX. The MEM/WB to EX forwarding path then delivers the loaded value.
- Branch and jump flush. Branches resolve in EX. On a taken branch, JAL, or JALR, the two in-flight instructions in IF and ID get turned into NOPs. 2-cycle penalty per taken control transfer.
- Static predict-not-taken as the branch policy
