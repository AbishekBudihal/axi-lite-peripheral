# AXI4-Lite Slave Peripheral — RTL Design & Verification

A fully functional AXI4-Lite slave peripheral implemented in Verilog, 
designed for SoC-level integration as a register-mapped IP block. 
Includes a complete verification environment with assertion-based 
protocol checks and functional coverage.

---

## Overview

AXI4-Lite is ARM's AMBA lightweight bus protocol used for control 
register access in SoC designs — found in virtually every modern 
ASIC and FPGA platform. This project implements the slave side of 
the protocol from scratch, with a focus on bus compliance, clean 
RTL structure, and verifiability.

---

## Features

**RTL Design (`axi_lite_slave.v`)**
- All five AXI4-Lite channels: Write Address (AW), Write Data (W), 
  Write Response (B), Read Address (AR), Read Data (R)
- VALID/READY handshaking on every channel
- Address decoding with a configurable register file
- Byte-enable write strobes (WSTRB) for partial writes
- Synchronous active-low reset
- Structured for direct SoC integration as a register-mapped peripheral

**Verification (`tb_axi_lite_slave.v`)**
- Constrained-random stimulus across write, read, and back-to-back 
  transaction scenarios
- Assertion-based checks for protocol compliance 
  (e.g., VALID must not deassert without a handshake)
- Functional coverage: 100% across all defined transaction types
- Setup/hold timing verification
- Waveform-based debug using GTKWave

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

