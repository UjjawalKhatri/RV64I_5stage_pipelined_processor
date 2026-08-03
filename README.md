# 🚀 64-bit 5-Stage Pipelined RV64I Processor Core

[![HDL: Verilog](https://img.shields.io/badge/HDL-Verilog_2001-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![Toolchain: Vivado](https://img.shields.io/badge/Vivado-2022.1-red.svg)](https://www.xilinx.com/products/design-tools/vivado.html)
[![Target: Artix-7](https://img.shields.io/badge/FPGA-Xilinx_Artix--7-orange.svg)](https://www.xilinx.com/products/silicon-devices/fpga/artix-7.html)
[![Timing: Met](https://img.shields.io/badge/WNS-%2B2.947_ns-brightgreen.svg)]()
[![CPI: 1.24](https://img.shields.io/badge/CPI-1.24-green.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

A high-performance, synthesizable **64-bit 5-Stage Pipelined RISC-V (RV64I) Processor Core** implemented in Verilog HDL. Optimized for FPGA synthesis on Xilinx Artix-7 devices (`xc7a100tcsg324-1`), featuring full RAW data forwarding, load-use hazard detection, single-port BRAM/LUTRAM word memory architecture, and hardware performance counters.

---

## 📌 Key Architectural Highlights

* **5-Stage Classical Pipeline**: Instruction Fetch (`IF`), Instruction Decode (`ID`), Execute (`EX`), Memory Access (`MEM`), Write-Back (`WB`).
* **Hazard Handling & Forwarding**:
  * **3-Way EX/MEM & MEM/WB Data Forwarding** for RAW (Read-After-Write) hazards.
  * **Direct Load-After-Store Forwarding Unit** resolving back-to-back memory access hazards.
  * **Load-Use Stall Mechanism** with control bubble injection.
  * **2-Bit Branch Prediction & Dynamic Branch/Jump Flushing** (penalty of 1 cycle on taken branches).
* **FPGA-Optimized Memory Subsystem**:
  * **Instruction Memory**: 4KB byte-addressed Big-Endian pre-loader compatible with Xilinx Block RAM (`$readmemh`).
  * **Data Memory**: Word-addressed 64-bit single-port memory (128 words × 64-bit = 1KB) using Distributed LUTRAM with combinational read for 1-cycle pipeline memory latency.
* **Hardware Performance Monitoring Unit**:
  * Tracks total clock cycles, retired instructions, load-use stalls, and branch flush cycles.
  * Calculates real-time CPI (Cycles Per Instruction).
* **Timing Closure Met**: Fully static timing closure achieved at **100 MHz** target clock frequency (**Worst Negative Slack WNS = +2.947 ns**, Zero failing endpoints).

---

## 📐 Pipeline Architecture Block Diagram

```
+---------+      +---------+      +---------+      +---------+      +---------+
| IF      | ---> | ID      | ---> | EX      | ---> | MEM     | ---> | WB      |
| Stage   |      | Stage   |      | Stage   |      | Stage   |      | Stage   |
+---------+      +---------+      +---------+      +---------+      +---------+
   |                |                |                |                |
   v                v                v                v                v
[PC Unit]       [RegFile]        [64-bit ALU]    [Data Memory]   [Write-Back]
[InstrMem]     [Imm Generator]  [Forwarding]     [Ld/Sd Fwd]     [Reg Mux]
                [Control Bubble] [Branch Target]
```

---

## 📊 FPGA Synthesis & Implementation Results

| Metric | Measured Value | Device / Constraint |
| :--- | :--- | :--- |
| **Target Device** | Xilinx Artix-7 `xc7a100tcsg324-1` | Nexys A7-100T Board |
| **Clock Frequency** | **100 MHz** (`10.0 ns` period constraint) | `rv64i_artix7.xdc` |
| **Worst Negative Slack (WNS)** | **`+2.947 ns`** ✅ (Timing Met) | Setup Timing |
| **Worst Hold Slack (WHS)** | **`+0.105 ns`** ✅ (Timing Met) | Hold Timing |
| **Failing Endpoints** | **`0`** | 100% Timing Closure |
| **Achievable Frequency** | **`~141.7 MHz`** ($1 / (10.0 - 2.947)\text{ ns}$) | Maximum Operating Freq |
| **Total On-Chip Power** | `0.117 W` (Dynamic: 0.024 W, Static: 0.093 W) | Vivado Power Report |

### 🛠️ Hardware Performance Counter Results (Fibonacci Benchmark)

| Counter Metric | Value |
| :--- | :--- |
| **Total Clock Cycles** | `250 cycles` |
| **Retired Instructions** | `201 instructions` |
| **Load-Use Stall Cycles** | `1 cycle` |
| **Branch/Jump Flush Cycles** | `55 cycles` |
| **Calculated CPI** | **`1.24`** |

---

## 🧪 Simulation & Verification Results

The core was verified by executing an assembly program that calculates the first 10 Fibonacci numbers, stores them in Data Memory using `sd`, loads them back into registers `x10`–`x19` using `ld`, and computes the sum in `x20`.

### 📋 Register File Verification Table

| Register | Hexadecimal Value | Decimal Value | Expected Result | Verification |
| :--- | :--- | :--- | :--- | :---: |
| **x10** | `0x0000000000000000` | **0** | `fib(0)` loaded from Data Memory | ✅ Pass |
| **x11** | `0x0000000000000001` | **1** | `fib(1)` loaded from Data Memory | ✅ Pass |
| **x12** | `0x0000000000000001` | **1** | `fib(2)` loaded from Data Memory | ✅ Pass |
| **x13** | `0x0000000000000002` | **2** | `fib(3)` loaded from Data Memory | ✅ Pass |
| **x14** | `0x0000000000000003` | **3** | `fib(4)` loaded from Data Memory | ✅ Pass |
| **x15** | `0x0000000000000005` | **5** | `fib(5)` loaded from Data Memory | ✅ Pass |
| **x16** | `0x0000000000000008` | **8** | `fib(6)` loaded from Data Memory | ✅ Pass |
| **x17** | `0x000000000000000d` | **13** | `fib(7)` loaded from Data Memory | ✅ Pass |
| **x18** | `0x0000000000000015` | **21** | `fib(8)` loaded from Data Memory | ✅ Pass |
| **x19** | `0x0000000000000022` | **34** | `fib(9)` loaded from Data Memory | ✅ Pass |
| **x20** | `0x0000000000000037` | **55** | `fib(8) + fib(9)` ($21 + 34$) | ✅ Pass |

---

## 🖼️ Vivado Screenshots & Proofs

### 1. Behavioral Waveform (Fibonacci Sequence Verification)
![Waveform Screenshot](results/waveform%20ss.png)

### 2. Implementation Timing Summary (WNS +2.947 ns)
![Timing Summary](results/timing.png)

### 3. Simulation Console Register File Dump
![Register Dump](results/result_fibo.png)

---

## 📂 Repository Directory Structure

```
RV64I_5stage_pipelined_processor/
├── rtl/                            # Synthesizable Verilog Source Files
│   ├── rv64i_core_top.v            # Top-Level Core Pipeline Wrapper
│   ├── pc.v                        # Program Counter Module
│   ├── Instruction_Memory.v        # 4KB Instruction Memory ($readmemh)
│   ├── Data_Memory.v               # 64-bit Word-Addressed Data Memory
│   ├── register_file.v             # 32 x 64-bit Register File with internal WB forwarding
│   ├── Immediate_Generation.v      # Immediate Decoder (I, S, B, U, J formats)
│   ├── control.v                   # Main Control Unit
│   ├── alu_control.v               # ALU Control Decoder
│   ├── alu.v                       # 64-bit Behavioral ALU
│   ├── hazard_detection.v          # Hazard Detection & Branch Flushing Unit
│   ├── forwarding_unit.v           # 3-Way RAW Forwarding Unit
│   ├── ld_after_sd_forwarding.v    # Load-After-Store Direct Forwarding
│   ├── control_bubble.v            # NOP Multiplexer for Load-Use Stalls
│   ├── IF_ID.v                     # IF/ID Pipeline Register
│   ├── ID_EX.v                     # ID/EX Pipeline Register
│   ├── EX_MEM.v                    # EX/MEM Pipeline Register
│   ├── MEM_WB.v                    # MEM/WB Pipeline Register
│   ├── perf_counters.v             # Hardware Performance Counters (CPI)
│   └── instructions.txt            # Machine Code Byte Text File
├── tb/                             # Simulation Testbenches & Program Listings
│   ├── tb_rv64i_core.v             # Vivado XSim Behavioral Testbench
│   ├── fibonacci_program_listing.txt# Assembly Listing & Hex Machine Code Reference
│   └── instructions.txt            # Pre-loaded Fibonacci Machine Code
├── constraints/                    # Timing Constraints
│   └── rv64i_artix7.xdc            # 100 MHz Clock XDC File for Artix-7
├── scripts/                        # Automation Scripts
│   └── run_vivado_flow.tcl         # Vivado Tcl Script for Batch Flow
├── tools/                          # Assembler Utilities
│   └── assembler.py                # Python RISC-V Assembly to Hex Converter
├── results/                        # Proof Screenshots & Reports
│   ├── waveform ss.png
│   ├── timing.png
│   ├── result_fibo.png
│   ├── counter_results.png
│   └── power.png
├── README.md                       # Project Documentation
└── .gitignore                      # Git Ignore File for Vivado Build Artifacts
```

---

## 🛠️ How to Run in Xilinx Vivado

### Method 1: Using Vivado GUI
1. Open **Xilinx Vivado**.
2. Click **Create Project** $\rightarrow$ Project Name: `rv64i_core`.
3. Select **RTL Project** (Do not specify sources at this step).
4. Select Target Part: **`xc7a100tcsg324-1`** (Artix-7).
5. Add all `.v` files from `rtl/` under **Design Sources**.
6. Add `tb/tb_rv64i_core.v` and `tb/instructions.txt` under **Simulation Sources**.
7. Add `constraints/rv64i_artix7.xdc` under **Constraints**.
8. **Run Behavioral Simulation**: Click *Run Simulation $\rightarrow$ Run Behavioral Simulation*.
9. **Run Synthesis & Implementation**: Click *Run Implementation* (WNS will be `+2.947 ns`).

### Method 2: Batch Tcl Automation
In Vivado TCL Console or Command Line:
```bash
vivado -mode batch -source scripts/run_vivado_flow.tcl
```

---

## 🐍 Python Assembler Usage

To assemble custom RISC-V assembly programs into machine code hex bytes:
```bash
python tools/assembler.py program.s -o rtl/instructions.txt
```

---

## 📜 Author & License

* **Developer**: Ujjawal Khatri
* **License**: MIT License
