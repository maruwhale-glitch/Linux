
RTL_DIR = ./rtl
TB_DIR = ./testbench
BUILD_DIR = ./build
INC_DIR = +incdir+$(RTL_DIR)
SIMV = ./build/simv
COMP_OPT = -full64 -sverilog $(INC_DIR)\
			-debug_access+all -kdb -lca \
			#-ntb_opts uvm-1.2 \#
			-timescale=1ns/100ps \
			-o $(BUILD_DIR)/simv

# 			-race=all 

SIGNAL          = signal.rc

all : vcs simv verdi

generate_f:
	find . -name "*.v" -o -name "*.sv" > files.f
vcs: generate_f
	mkdir -p $(BUILD_DIR)
	vcs $(COMP_OPT) -f files.f 

simv: $(SIMV)

verdi:
	verdi -dbdir $(BUILD_DIR)/simv.daidir -ssf $(BUILD_DIR)/wave.fsdb -sswr $(SIGNAL) &

clean:
	rm -rf $(BUILD_DIR) csrc novas*.* ucli.key verdilog verdiLog files.f inter*.* *.fsdb *.daidir

.PHONY: all generate_f vcs simv verdi clean
