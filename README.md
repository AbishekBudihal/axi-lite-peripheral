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

## Repository Structure
```
axi-lite-peripheral/
├── rtl/
│   └── axi_lite_slave.v       # AXI4-Lite slave RTL
├── tb/
│   └── tb_axi_lite_slave.v    # Testbench with assertions & coverage
├── sim/
│   └── run.sh                 # Icarus Verilog compile & simulate script
├── waves/
│   └── dump.vcd               # Sample waveform output
└── README.md
```

---

## How to Simulate

**Requirements:** Icarus Verilog, GTKWave (Linux/WSL)
```bash
# Clone the repo
git clone https://github.com/AbishekBudihal/axi-lite-peripheral.git
cd axi-lite-peripheral

# Compile and simulate
iverilog -o sim_out rtl/axi_lite_slave.v tb/tb_axi_lite_slave.v
vvp sim_out

# View waveforms
gtkwave waves/dump.vcd
```

---

## AXI4-Lite Protocol — Key Concepts

A transfer occurs only when both VALID and READY are high on the 
rising clock edge. This allows the master and slave to independently 
apply backpressure without data loss.
```
Write path:  Master → AW channel (address) + W channel (data)
                    ← B channel (response from slave)

Read path:   Master → AR channel (address)
                    ← R channel (data + response from slave)
```

The slave decodes the incoming address, maps it to an internal 
register, and responds with OKAY (2'b00) on both BRESP and RRESP 
for valid transactions.

---

## Design Decisions

- **Synchronous reset** chosen over asynchronous for synthesis 
  predictability in ASIC flows
- **Separate AR/AW acceptance** — the slave can independently accept 
  read and write addresses, avoiding channel coupling
- **WSTRB support** allows byte-granular writes, consistent with 
  real register-mapped peripheral requirements

---

## Planned Extensions

- [ ] UVM testbench with scoreboard and coverage groups
- [ ] Integration into a mini SoC with UART and GPIO peripherals 
      over an AXI interconnect
- [ ] Vivado synthesis for LUT/FF utilization and timing report

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Icarus Verilog | RTL simulation |
| GTKWave | Waveform analysis |
| Git Bash / GitHub | Version control |

---

## Skills Demonstrated

`Verilog` `SystemVerilog` `AXI4-Lite` `AMBA Protocol` `RTL Design`  
`Functional Verification` `Assertion-Based Verification`  
`Functional Coverage` `Digital Design` `ASIC/FPGA`
