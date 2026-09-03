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
  Protocol checkers are embedded directly inside `interface APB_if`. Advanced checks (Parity, Unaligned Address, Low-Power) are configurable at compile-time per instance via interface parameters.

- **Topology Configuration (N-Endpoint Scalability):**
  The environment (`APB_env`) uses `APB_env_config` to support configurable topologies. It defaults to a Master-only configuration for immediate Slave DUT integration. The VIP Slave Agent and internal Scoreboard can be explicitly enabled for loopback self-testing via `+UVM_ENABLE_SLAVE` and `+UVM_ENABLE_SCOREBOARD`. Kill switches (`+UVM_NO_MASTER`, `+UVM_NO_SLAVE`) are provided for hierarchical overrides. 
  Furthermore, the VIP is designed as a true **Protocol Endpoint**. To verify complex SoC Interconnects, system integrators can instantiate *N* independent pairs of `APB_if` and `APB_env` without altering a single line of VIP code.

- **Factory-Based Error Injection:**
  Protocol violations are injected by overriding the standard drivers with derived error-injecting drivers (e.g., `APB_master_parity_err_driver`) via the UVM Factory, rather than sequence-level flags or callbacks.

- **Scoreboard:** 
  Utilizes an associative array for SRAM emulation, checking data integrity with `PSTRB` support. Disabled by default, intended as a reference model for VIP loopback verification.

## Directory Structure
```text
VIP_APB/
├── agent/                 # Master and Slave UVM Agents
├── env/                   # APB Environment, Configuration, and Scoreboard
├── seq/                   # Parameterized Sequence Items and Sequences
├── tb/                    # APB Interface (SVAs) and Integration Templates
│   ├── APB_if.sv
│   ├── tb_top_loopback.sv
│   ├── tb_top_dut_slave.sv
│   └── tb_top_dut_master.sv
├── test/                  # UVM Testcases
├── run/                   # Compilation and Simulation scripts
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
- **Functional Coverage:** Implement a `uvm_subscriber` containing covergroups for protocol coverage measurement.