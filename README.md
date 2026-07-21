# 🖥️ Morris Mano Basic Computer (VHDL FPGA Implementation)

![Language](https://img.shields.io/badge/Language-VHDL-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Mano_Basic_Computer-green.svg)
![Toolchain](https://img.shields.io/badge/Toolchain-Xilinx_ISE-red.svg)
![Target](https://img.shields.io/badge/Target-FPGA-orange.svg)

A complete hardware-level VHDL implementation of **M. Morris Mano's classic 16-bit Basic Computer Architecture**. Designed for FPGA deployment, this system includes a custom memory unit, register transfer logic (RTL), PS/2 keyboard interface for ASCII input, and a 4-digit 7-segment display driver.

---

## 📌 Project Overview

This project materializes the theoretical 16-bit microprocessor architecture introduced by M. Morris Mano into synthesis-ready VHDL logic:
* **Registers & Data Path:** Implements 16-bit registers (`IR`, `DR`, `AC`), 12-bit address pointers (`AR`, `PC`), temporary backup buffers, and sequence time counters (`timeCount`).
* **Instruction Cycle Execution:** Implements Fetch, Decode, Indirect Addressing Resolution, and Execution phases (supporting memory-reference, register-reference, and I/O instructions).
* **Interrupt & Control Handling:** Supports interrupt cycle flags (`ien`, `fgi`, `fgo`), hardware resets, and 1 Hz clock step frequency conversion for user observation.
* **PS/2 Keyboard Input Integration:** Debounces raw PS/2 serial signals (`ps2_clk`, `ps2_data`) and translates scan codes into 8-bit ASCII values fed into the Input Register (`INPR`).
* **Multiplexed Display:** Drives a 4-digit 7-Segment display output to view real-time instruction register states (`IR`) in hexadecimal format.

---

## 🏗️ Hardware Architecture & Bus Layout

```text
               +----------------------------------+
               |     Clock Divider (1 Hz Clock)   |
               +----------------+-----------------+
                                |
                                v
+---------------+   +-----------------------+   +--------------------+
| PS/2 Keyboard |-->|  BasicComputer.vhd    |-->| 4-Digit 7-Segment  |
|  (ASCII Code) |   |  (Control Logic & ALU)|   | Display (Display)  |
+---------------+   +-----------+-----------+   +--------------------+
                                |
                                v
                    +-----------------------+
                    | Memory Unit (4096x16) |
                    |     (memory2.vhd)     |
                    +-----------------------+
```

---

## 💻 Instruction Set Architecture (ISA) Supported

* **Memory-Reference Instructions:** `AND`, `ADD`, `LDA`, `STA`, `BUN`, `BSA`, `ISZ`
* **Register-Reference Instructions:** `CLA`, `CLE`, `CMA`, `CME`, `CIR`, `CIL`, `INC`, `SPA`, `SNA`, `SZA`, `SZE`, `HLT`
* **Input-Output Instructions:** `INP`, `OUT`, `SKI`, `SKO`, `ION`, `IOF`

---

## 🚀 Getting Started

### Prerequisites
* **Xilinx ISE Design Suite** (or Vivado)
* **FPGA Board** (e.g., Digilent Basys / Spartan / Artix series with 50 MHz onboard oscillator)
* PS/2 Keyboard (or PS/2 host module)

### Building and Synthesis

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/KorsanPanda/morris_mano_computer.git](https://github.com/KorsanPanda/morris_mano_computer.git)
   cd morris_mano_computer
   ```

2. **Xilinx ISE Setup:**
   * Create a new project in Xilinx ISE.
   * Add all `.vhd` source files to the project hierarchy.
   * Set `BasicComputer.vhd` as the **Top-Level Entity**.
   * Attach `v1.ucf` for physical pin bindings.

3. **Synthesis & Bitstream Generation:**
   * Run **Synthesize - XST**.
   * Run **Implement Design** (Translate, Map, Place & Route).
   * Generate Programming File (`.bit`) and flash to your target FPGA board.

---

## 📁 Directory Structure

```text
korsanpanda-morris_mano_computer/
├── BasicComputer.vhd               # Top-level entity integrating CPU registers, execution & I/O
├── memory2.vhd                     # 4096x16-bit RAM module pre-loaded with boot instructions
├── ps2_keyboard_to_ascii.vhd       # Top-level PS/2 decoder converting key strokes to ASCII
├── ps2_keyboard.vhd                # Low-level PS/2 receiver protocol logic
├── debounce.vhd                    # Noise sifting counter for mechanical PS/2 inputs
├── Display.vhd                     # Multiplexed 7-segment display driver module
├── seven_segment_display_VHDL.vhd  # BCD-to-7-segment cathode decoder
├── clock_divider_1hz.vhd           # Clock scaler converting 50 MHz to 1 Hz execution pulses
├── v1.ucf                          # Physical UCF pin assignment mapping
└── README.md                       # Project documentation
```
