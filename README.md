# AXI4-Lite Slave Peripheral — RTL Design & Verification

A fully functional AXI4-Lite slave peripheral implemented in Verilog,
designed for SoC-level integration as a register-mapped IP block.
Includes a complete verification environment with constrained-random
stimulus, assertion-based protocol checks, scoreboard, and functional
coverage reporting.

---

## Overview

AXI4-Lite is ARM's AMBA lightweight bus protocol used for control
register access in SoC designs — found in virtually every modern
ASIC and FPGA platform. This project implements the slave side of
the protocol from scratch, with a focus on bus compliance, clean
RTL structure, and verifiability.

---

## Features

### RTL Design (`rtl/axi_lite_slave.v`)
- All five AXI4-Lite channels: Write Address (AW), Write Data (W),
  Write Response (B), Read Address (AR), Read Data (R)
- VALID/READY handshaking on every channel per AMBA spec
- 4-register addressable register file (word-aligned, 0x00–0x0C)
- Byte-enable write strobes (WSTRB) for partial byte writes
- Write address latching — AW and W channels properly decoupled
- BRESP and RRESP response signals (OKAY = 2'b00)
- Synchronous active-low reset
- Parameterized DATA_WIDTH, ADDR_WIDTH, NUM_REGS
- Structured for direct SoC integration as a register-mapped peripheral

### Verification (`tb/tb_axi_lite.v`)
- Constrained-random stimulus across all 4 registers with `$random`
- 5 directed test cases: full-word writes, readback, partial WSTRB,
  random write/read, and back-to-back transactions
- Assertion-based protocol checks every clock cycle:
  - VALID stability (must not deassert before handshake)
  - BRESP/RRESP must always return OKAY
- Scoreboard: every read result checked against expected register state
- Functional coverage: 10 coverage points, 100% hit across all tests
- Waveform dump to VCD for GTKWave inspection

---

## Verification Results
```
TEST SUMMARY: 14 PASSED | 0 FAILED

FUNCTIONAL COVERAGE REPORT
  Write reg0       : HIT
  Write reg1       : HIT
  Write reg2       : HIT
  Write reg3       : HIT
  Read  reg0       : HIT
  Read  reg1       : HIT
  Read  reg2       : HIT
  Read  reg3       : HIT
  Partial WSTRB    : HIT
  Back-to-back     : HIT
  Coverage         : 10 / 10 (100%)
```

---

## Project Structure
```
axi-lite-peripheral/
├── rtl/
│   └── axi_lite_slave.v        # AXI4-Lite slave RTL
├── tb/
│   └── tb_axi_lite.v           # Testbench with assertions, scoreboard & coverage
├── waveforms/
│   └── axi.vcd                 # Simulation waveform output
├── sim                         # Compiled simulation binary
└── README.md
```

---

## How to Run

**Requirements:** Icarus Verilog, GTKWave (Linux/WSL/Windows)
```bash
# Compile
iverilog -g2012 -o sim rtl/axi_lite_slave.v tb/tb_axi_lite.v

# Simulate
vvp sim

# View waveforms
gtkwave waveforms/axi.vcd
```

---

## AXI4-Lite Protocol — Write & Read Flow
```
Write path:  Master → AW channel (address)
             Master → W channel (data + WSTRB)
                    ← B channel (BRESP from slave)

Read path:   Master → AR channel (address)
                    ← R channel (data + RRESP from slave)
```

A transfer completes only when both VALID and READY are high
on the rising clock edge. The slave latches the write address
independently before accepting write data, decoupling the two
channels per the AXI4-Lite specification.

---

## Design Decisions

- **Synchronous reset** — predictable behavior in ASIC synthesis flows
- **Address latching** — AW and W channels are decoupled; slave
  captures address before accepting data, preventing channel coupling
- **WSTRB support** — byte-granular writes consistent with real
  register-mapped peripheral requirements
- **Parameterized design** — widths and register count configurable
  for easy reuse across different SoC contexts

---

## Planned Extensions

- [ ] UVM testbench with agent, driver, monitor, and scoreboard
- [ ] AXI error responses (DECERR / SLVERR) for out-of-range addresses
- [ ] Integration into a mini SoC with UART and GPIO over AXI interconnect
- [ ] Vivado synthesis for LUT/FF utilization and timing report

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Icarus Verilog | RTL simulation |
| GTKWave | Waveform analysis |
| Git / GitHub | Version control |

---

## Skills Demonstrated

`Verilog` `AXI4-Lite` `AMBA Protocol` `RTL Design` `FSM`
`Functional Verification` `Assertion-Based Verification`
`Constrained-Random Stimulus` `Functional Coverage` `Scoreboard`
`Digital Design` `ASIC/FPGA`
