# AXI Lite Peripheral Design and Verification

## Overview

A fully functional AXI4-Lite slave peripheral implemented in Verilog, 
designed for SoC-level integration as a register-mapped IP block. 
Includes a complete verification environment with assertion-based 
protocol checks and functional coverage.
---

## Objectives

- Design a synthesizable AXI4-Lite slave peripheral in Verilog
- Implement address decoding, read/write channels, and reset logic
- Verify protocol correctness using simulation and waveforms
- Follow Linux-based, Git-driven RTL development practices

---

## Technical Highlights

- **Protocol:** AXI4-Lite (single outstanding transaction)
- **RTL Design:** Address decoding, handshake logic, synchronous reset
- **Verification:** Self-checking testbench with functional coverage
- **Simulation:** Icarus Verilog
- **Debug & Analysis:** GTKWave (VCD-based waveform inspection)
- **Environment:** Linux (Git Bash), Git/GitHub

---

## Project Structure

```text
axi-lite-peripheral/
├── rtl/
│   └── axi_lite_slave.v        # AXI Lite slave RTL
├── tb/
│   └── tb_axi_lite.v           # Testbench
├── waveforms/
│   └── axi.vcd                 # Generated simulation waveforms
├── sim                         # Compiled simulation binary
└── README.md

```
---

## How to Run the Simulation
### 1️⃣ Compile RTL and Testbench
#### iverilog -o sim rtl/axi_lite_slave.v tb/tb_axi_lite.v

### 2️⃣ Run Simulation
#### vvp sim

### 3️⃣ View Waveforms
#### gtkwave waveforms/axi.vcd


## If GTKWave opens successfully and displays valid AXI transactions — ✅ simulation passed.

---

## What to Observe in GTKWave  
- AXI Lite handshake signals (VALID, READY)  
- Correct address decoding during read/write  
- Register updates on write transactions  
- Stable read data during read cycles  
- Clean reset behavior and synchronous operation  

---

## Verification Summary  
- Verified read/write functionality across multiple addresses  
- Ensured AXI protocol compliance via handshake timing  
- Achieved 100% functional coverage for core features  
- Confirmed setup/hold correctness through waveform inspection  

---

## Why This Project Matters  
- This project demonstrates:  
 - Strong understanding of SoC bus protocols  
 - Hands-on experience with RTL design and verification  
 - Comfort working in a Linux-based simulation environment  
 - Industry-relevant workflow aligned with ASIC/FPGA development  
 - It is directly applicable to VLSI, verification, and CST internship roles.  

---

## Future Enhancements  
- Add AXI error responses (DECERR/SLVERR)  
- Extend to multiple register banks  
- Integrate assertion-based verification (SVA)  
- Synthesize and test on FPGA  

---

## Author

### Abishek  
- Electronics & Communication Engineering  
- GitHub: https://github.com/AncientDrago  

--- 

## If you find this project useful, feel free to star the repository!

