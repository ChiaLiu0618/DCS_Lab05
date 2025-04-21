# Digital Circuit and System - Lab05: Nonlinear Function Implementation with DesignWare IP

**Institute of Electronics, NYCU**  
**NYCU CERES LAB**  
**February 27, 2025**

## Introduction
This lab explores the implementation of nonlinear functions commonly used in artificial neural networks (ANNs) using Synopsys DesignWare IP. You are required to implement two floating-point nonlinear functions using a pipelined architecture to meet strict timing constraints.

## DesignWare IP Overview
- **DesignWare IP Types:**
  - **Soft IP:** RTL-level, requires verification.
  - **Firm IP:** Netlist-level, less commonly used.
  - **Hard IP:** GDSII format, high performance, technology dependent.
- **DesignWare Library:** Provides synthesizable and verified IPs for optimized area/speed and timing reduction.

## Project Description
The objective is to implement two nonlinear functions using Synopsys DesignWare IP blocks:
- Functions operate on IEEE 754 floating-point input.
- Must follow the given formulas for function computation.
- You must use floating-point arithmetic IP (e.g., `DW_fp_exp`, `DW_fp_log2`, etc.) in your design.
- The design must be pipelined to meet timing constraints.

## Input and Output Signals
- `in_valid`: High when input data is valid.
- `out_valid`: Must be pulled high within 7 cycles after `in_valid` and remain high until all patterns are complete.
- Input and output delays are both `0.5 * cycle time`.

## Implementation Constraints
- You must reset all output signals after reset is asserted.
- You cannot change the clock cycle (fixed at 18ns).
- `exp(x)` is the most time-consuming operation and defines the cycle time.
- A pipelined design is **mandatory** to meet the 18ns timing constraint.
- You are not allowed to modify IEEE floating-point parameters.

## DesignWare IP Usage
- Refer to Synopsys documentation:  
  `/usr/cad/synopsys/synthesis/cur/dw/doc/manuals/dwbb_userguide.pdf`
- Use Chapter 2 to learn how to instantiate IPs.
- Follow these steps:
  1. Select appropriate IP (e.g., `DW_fp_log2`, `DW_fp_exp`).
  2. Read and understand pin and parameter descriptions.
  3. Copy template, fill in parameters, rename instance if needed.

## Useful References
- [YouTube – Neural Network Activation Functions](https://www.youtube.com/watch?v=e_J9lXnU_vs)
- [ScienceDirect – Activation Function Study](https://www.sciencedirect.com/science/article/pii/S0925231219308884)
