DESIGN_MODULE_NAME = counter
TEST_BENCH_MODULE_NAME = $(DESIGN_MODULE_NAME)_tb
DESIGN_FILES = *.v
TEST_FILES = *.sv

#DESIGN_SRCS = 
#TEST_BENCH_SRCS =

#all: compile optimize simulate
#
## Create the work library
#work:
#	vlib work
#
## Compile the design and testbench
#compile: work
#	vlog signed_adder.v signed_adder_tb.sv
#
## Optimize the design
#optimize: compile
#	vopt +acc $(TEST_BENCH_MODULE_NAME) -o dbgver
#	vopt +nocheckAll +delay_mode_path $(TEST_BENCH_MODULE_NAME) -o optver
#
## Run the simulation with coverage
#simulate: optimize
#	vsim -c covver -coverage -do "add wave *; run -all; coverage save $(COV_REPORT) -onexit; quit"
#
#
#$(TEST_BENCH_MODULE_NAME): 
#	vlog signed_adder.v signed_adder_tb.sv
#
## Optimize for code coverage
#$(TEST_BENCH_MODULE_NAME)_covver: $(TOP_LEVEL_MODULE)
#	vopt +cover=bcefst $(TEST_BENCH_MODULE_NAME) -o covver
#
#simulate_cc: $(TEST_BENCH_MODULE_NAME)_covver
#	vsim -c covver -coverage -do "add wave *; run -all; coverage save $(COV_REPORT) -onexit; quit"



# TODO:: FIX when running make twice it redoes all rules again even if no file changed!
# 		Modify rule targets to be actual file names instead of phony names

.PHONY: dbg cc

dbg: simulate_dbg

cc : simulate_cc 
	vcover report -details -annotate -all -output code_coverage_rpt.txt $(TEST_BENCH_MODULE_NAME).ucdb

fun : simulate_fun


# SIMULATE
simulate_dbg : optimize_dbg
	vsim -gui dbgver -do \
	"add wave *;\
	run -all;"

simulate_cc : optimize_cc
	vsim -c covver -coverage -do \
	"run -all;\
	coverage save -du $(DESIGN_MODULE_NAME) $(TEST_BENCH_MODULE_NAME).ucdb -onexit;\
	coverage exclude -du $(DESIGN_MODULE_NAME) -togglenode rst;\
	quit"

simulate_fun: optimize_fun
	vsim -c optver -do \
	"run -all;\
	coverage report -detail -output fun_coverage_rpt.txt;\
	quit"

# OPTIMIZE 
optimize_dbg : compile
	vopt +acc $(TEST_BENCH_MODULE_NAME) -o dbgver

optimize_cc : compile
	vopt +cover=bcefst $(TEST_BENCH_MODULE_NAME) -o covver

optimize_fun: compile
	vopt $(TEST_BENCH_MODULE_NAME) -o optver

# COMPILE
compile: $(DESIGN_FILES) $(TEST_FILES)
	vlog $(DESIGN_FILES) $(TEST_FILES)

work:
	vlib work

clean:
	rm -rf work transcript *.wlf *.ucdb coverage_rpt.txt

