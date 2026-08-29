# AMBA APB5 UVM Verification IP (VIP)

## Overview
This repository contains a Universal Verification Methodology (UVM) Verification IP (VIP) for the AMBA APB5 protocol.

## Key Features

- **APB5 Support:** 
  - Standard signals (`PREADY`, `PSLVERR`, `PSTRB`, `PPROT`).
  - User Signals (`PAUSER`, `PWUSER`, `PRUSER`, `PBUSER`).
  - Low Power Clock Gating (`PWAKEUP`).
  - Interface Protection (Hardware parity for `PADDRCHK`, `PCTRLCHK`, `PWDATACHK`, `PRDATACHK`, `PREADYCHK`).

- **Embedded SVAs (SystemVerilog Assertions):** 
  Protocol checkers are embedded directly inside `interface APB_if`. Checks for Parity and Low-Power can be dynamically enabled/disabled at runtime via interface variables.

- **Topology Configuration:**
  The environment (`APB_env`) uses `APB_env_config` to support configurable topologies. It can operate in loopback mode (Master and Slave active) or be integrated with a DUT by toggling `has_master` or `has_slave` flags.

- **Factory-Based Error Injection:**
  Protocol violations are injected by overriding the standard drivers with derived error-injecting drivers (e.g., `APB_master_parity_err_driver`) via the UVM Factory, rather than sequence-level flags or callbacks.

- **Scoreboard:** 
  Utilizes an associative array for SRAM emulation, checking data integrity with `PSTRB` support.

## Directory Structure
```text
VIP_APB/
├── agent/                 # Master and Slave UVM Agents
├── env/                   # APB Environment, Configuration, and Scoreboard
├── seq/                   # Parameterized Sequence Items and Sequences
├── tb/                    # Top Testbench and APB Interface (SVAs)
├── test/                  # UVM Testcases
├── run/
│   └── Makefile           # Compilation and Simulation scripts
├── APB_VIP_Testplan.csv   # Verification Plan
└── run_regression.sh      # Regression Script
```

## Testcase Categories (25 Tests)
- **BSC (Basic):** Single, Back-to-Back, and mixed Read/Write operations.
- **TIM (Timing):** Zero wait states, random wait states, and timeout recovery.
- **ERR (Error):** Handling of Slave `PSLVERR` responses.
- **FEAT (Features):** `PSTRB` permutations, `PPROT` coverage, User Signals, `PWAKEUP` timing, and Parity Error Injection.
- **RST (Reset):** System recovery from random asynchronous resets.
- **STR (Stress):** High-volume continuous traffic.
- **AST (Assertions/Negative):** Intentional protocol violations injected via Factory Override Drivers to trigger SVAs.

## How to Run

### 1. Run a Single Test
```bash
cd run
make compile
make run TEST=APB_TC_BSC_001_test
```

### 2. Run the Full Regression
```bash
./run_regression.sh
```

## Future Scope
- **Multi-Slave Routing:** Introduce an `APB_Decoder` to map transactions to multiple slaves based on `PADDR`.
- **UVM RAL:** Implement a UVM Register Abstraction Layer model.
