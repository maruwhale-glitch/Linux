
RTL_DIR = ./rtl
TB_DIR = ./testbench
BUILD_DIR = ./build
INC_DIR = +incdir+$(RTL_DIR)
SIMV = ./build/simv
COMP_OPT = -full64 -sverilog $(INC_DIR)\
			-debug_access+all -kdb -lca \
			-race=all \
			-timescale=1ns/100ps \
			-o $(BUILD_DIR)/simv -l $(BUILD_DIR)/comp.log

all : vcs simv verdi

generate_f:
	find . -name "*.v" -o -name "*.sv" > files.f

vcs: generate_f
	mkdir -p $(BUILD_DIR)
	vcs $(COMP_OPT) -f files.f 

simv: 
	$(SIMV) -l $(BUILD_DIR)/simulation.log

verdi:
	verdi -dbdir $(BUILD_DIR)/simv.daidir -ssf $(BUILD_DIR)/wave.fsdb &

clean:
	rm -rf $(BUILD_DIR) csrc novas*.* ucli.key verdilog files.f inter*.* *.fsdb

.PHONY: all generate_f vcs simv verdi clean