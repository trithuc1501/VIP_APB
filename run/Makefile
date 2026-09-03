PROJ_DIR = ..
TOP = tb_top_loopback
TEST ?= APB_TC_BSC_001_test
SEED ?= random

all: clean compile run

compile:
	vlib work
	vlog -sv -timescale=1ns/1ps +incdir+$(PROJ_DIR) $(PROJ_DIR)/tb/tb_top_loopback.sv

run:
	vsim -c -sv_seed $(SEED) -voptargs="+acc" -do "run -all; quit" $(TOP) +UVM_TESTNAME=$(TEST) +UVM_ENABLE_SLAVE +UVM_ENABLE_SCOREBOARD

gui:
	vsim -sv_seed $(SEED) -voptargs="+acc" -do "do wave.do; run -all" $(TOP) +UVM_TESTNAME=$(TEST) +UVM_ENABLE_SLAVE +UVM_ENABLE_SCOREBOARD

clean:
	rm -rf work transcript vsim.wlf dump.vcd *.log
