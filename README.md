# AMBA APB5 UVM Verification IP (VIP)

## Overview
This repository contains a complete, industry-standard Universal Verification Methodology (UVM) Verification IP (VIP) for the AMBA APB5 (Advanced Peripheral Bus) protocol. It was developed as a comprehensive training project to demonstrate advanced UVM concepts, robust protocol checking, and rigorous verification methodologies.

## Key Features
- **Full APB5 Support:** Implements all standard signals including `PREADY`, `PSLVERR`, `PSTRB` (Byte Strobes), and `PPROT` (Protection).
- **Robust Architecture:** Clean separation of concerns with independent Master and Slave agents supporting `UVM_ACTIVE` and `UVM_PASSIVE` configurations.
- **Reference Model Scoreboard:** Utilizes an associative array to simulate SRAM behavior, rigorously checking data integrity taking `PSTRB` and overlapping writes into account.
- **Asynchronous Reset Handling:** Advanced thread management (`fork...join_any`) in Drivers and Monitors to gracefully handle mid-transaction `PRESETn` drops without UVM deadlocks.
- **Protocol Assertions (SVA):** A strict, standalone protocol checker module validating timing, pipelining, and protocol rules.
- **Negative Testing Framework:** Specially designed error-injecting sequences to intentionally violate the APB protocol (e.g., dropping `PSEL`, unaligned `PADDR`, extending `SETUP`), physically proving the reliability of the SVAs.

## Directory Structure
```text
VIP_APB/
├── agent/
│   ├── agent_master/      # Master Sequencer, Driver, Monitor, Agent
│   └── agent_slave/       # Slave Sequencer, Driver, Monitor, Agent
├── env/
│   ├── APB_env.sv         # Environment connecting Agents and Scoreboard
│   └── APB_scoreboard.sv  # Data integrity checker
├── seq/
│   ├── APB_sequence_item.sv # Transaction item with error-injection flags
│   ├── seq_master/        # Master sequences (Basic, Stress, Error Injections)
│   └── seq_slave/         # Slave sequences (Wait states, PSLVERR, Timeouts)
├── tb/
│   ├── APB_if.sv          # APB Interface
│   ├── APB_sva_checkers.sv# SystemVerilog Assertions (Protocol Police)
│   └── tb_top.sv          # Top-level testbench
├── test/                  # UVM Testcases mapped to the Verification Plan
├── run/
│   └── Makefile           # Compilation and Simulation scripts
└── APB_VIP_Testplan.csv   # Detailed Verification Plan (Reqs, Coverage, Mapping)
```

## Testcase Categories
The VIP has been rigorously tested against a detailed testplan spanning multiple categories:
- **BSC (Basic):** Single, Back-to-Back, and mixed Read/Write operations.
- **TIM (Timing):** Zero wait states, random wait states, and Watchdog timeout recovery.
- **ERR (Error):** Handling of Slave `PSLVERR` responses.
- **RST (Reset):** System recovery from random asynchronous resets under heavy load.
- **FEAT (Features):** `PSTRB` permutations and `PPROT` coverage.
- **STR (Stress):** High-volume continuous traffic (2000+ transactions) proving VIP stability.
- **AST (Assertions/Negative):** Intentional protocol violations to trigger and verify SVAs (`AST_001` to `AST_008`).

## How to Run
The project uses a standard `Makefile` located in the `run/` directory.

1. Navigate to the `run` directory:
   ```bash
   cd run
   ```
2. Execute a specific testcase (e.g., `APB_TC_BSC_001_test`):
   ```bash
   make all TEST=APB_TC_BSC_001_test
   ```

*Note: The simulation is configured to use Questa/ModelSim. Ensure your environment variables and paths to UVM libraries are correctly set in your terminal.*

## Technical Highlights (For Review)
1. **Race Condition Mitigation:** Implemented `#50ns` drain times in the test `run_phase` before dropping objections. This prevents the UVM Active region from terminating the simulation before SVAs in the Reactive region can flag end-of-cycle violations.
2. **Dynamic Error Injection:** Instead of modifying standard drivers, the `APB_sequence_item` contains `inject_*` metadata flags. The Master/Slave drivers dynamically alter their physical signal timing based on these flags, creating a highly reusable negative-testing infrastructure.
# VIP_APB
