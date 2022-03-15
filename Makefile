.PHONY: lmbench_wave lmbench_raw_syscalls lmbench_wasmtime sqlite_run_wasmtime sqlite_run_wasm2c sqlite_run_raw_syscalls run_sqlite run_lmbench run_all

SQLITE_ROOT    ?= sqlite/sqlite

RLBOX_ROOT      = ../rlbox_wasm2c_sandbox
WASM2C_SRC_ROOT = $(RLBOX_ROOT)/build/_deps/mod_wasm2c-src/wasm2c
WASM2C_BIN_ROOT = $(RLBOX_ROOT)/build/_deps/mod_wasm2c-src/bin

SQLITE_BUILD = build/sqlite

WASI_SDK_ROOT = $(RLBOX_ROOT)/build/_deps/wasiclang-src/build/install/opt/wasi-sdk

WASMTIME_ROOT=runtimes/wasmtime


PINNED_CPU = 8
#SETUP_BENCH = nice -n -20 taskset -c $(PINNED_CPU) 
SETUP_BENCH = 
INVOKE_WAVE = LD_LIBRARY_PATH=../build/wave/release $(SETUP_BENCH) ../../rlbox_wasm2c_sandbox/build/_deps/mod_wasm2c-src/bin/wasm2c-runner 
INVOKE_WAVE_RAW_SYSCALLS = LD_LIBRARY_PATH=../build/raw_syscalls/release $(SETUP_BENCH) ../../rlbox_wasm2c_sandbox/build/_deps/mod_wasm2c-src/bin/wasm2c-runner
INVOKE_WASMTIME = $(SETUP_BENCH) ../runtimes/wasmtime/target/release/wasmtime run --allow-unknown-exports --allow-precompiled  

#NOW=`date '+%F_%H:%M:%S'`
#RESULTS_BASE=results/$(date "+%Y_%m_%d-%H_%M_%S")
#RESULTS_BASE=results/$(NOW)
RESULTS_BASE:= results/$(shell date --iso=seconds)


SPEC_PATH := ./wave-specbenchmark

# shared commands
# ==============================================================================
build_raw_syscalls:
	cargo build --target-dir=build/raw_syscalls --release --features=time_syscalls

build_wave:
	cargo build --target-dir=build/wave --release --features=time_hostcalls

clean:
	cd wasi-lmbench && $(MAKE) clean
	rm -rf build

# lmbench benchmarks
# ==============================================================================
lmbench_wave: build_wave_lmbench
	mkdir -p $(RESULTS_BASE)/lmbench
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 null data/tmp.txt" --homedir="." 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_null.txt 
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 read data/tmp.txt" --homedir="/" 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_read.txt 
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 write data/tmp.txt" --homedir="/" 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_write.txt 
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 stat data/tmp.txt" --homedir="." 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_stat.txt 
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 fstat data/tmp.txt" --homedir="." 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_fstat.txt 
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 open data/tmp.txt" --homedir="." 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_open.txt 

lmbench_raw_syscalls: build_raw_syscalls_lmbench
	mkdir -p $(RESULTS_BASE)/lmbench
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 null data/tmp.txt" --homedir="." 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_null.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 read data/tmp.txt" --homedir="/" 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_read.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 write data/tmp.txt" --homedir="/" 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_write.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 stat data/tmp.txt" --homedir="." 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_stat.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 fstat data/tmp.txt" --homedir="." 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_fstat.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 open data/tmp.txt" --homedir="." 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_open.txt 

lmbench_wasmtime: build_wasmtime_lmbench
	mkdir -p $(RESULTS_BASE)/lmbench
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=. bin/wasmtime/lat_syscall -- -N 1000000 null data/tmp.txt 
	mv wasi-lmbench/wasmtime_results.txt $(RESULTS_BASE)/lmbench/wasmtime_null.txt 
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=/ bin/wasmtime/lat_syscall -- -N 1000000 read data/tmp.txt 
	mv wasi-lmbench/wasmtime_results.txt $(RESULTS_BASE)/lmbench/wasmtime_read.txt 	
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=/ bin/wasmtime/lat_syscall -- -N 1000000 write data/tmp.txt 
	mv wasi-lmbench/wasmtime_results.txt $(RESULTS_BASE)/lmbench/wasmtime_write.txt 	
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=. bin/wasmtime/lat_syscall -- -N 1000000 stat data/tmp.txt 
	mv wasi-lmbench/wasmtime_results.txt $(RESULTS_BASE)/lmbench/wasmtime_stat.txt 	
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=. bin/wasmtime/lat_syscall -- -N 1000000 fstat data/tmp.txt 
	mv wasi-lmbench/wasmtime_results.txt $(RESULTS_BASE)/lmbench/wasmtime_fstat.txt 	
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=. bin/wasmtime/lat_syscall -- -N 1000000 open data/tmp.txt 
	mv wasi-lmbench/wasmtime_results.txt $(RESULTS_BASE)/lmbench/wasmtime_open.txt 


build_wave_lmbench: build_wave
	cd wasi-lmbench && RUNTIME=wave $(MAKE)

build_raw_syscalls_lmbench: build_raw_syscalls
	cd wasi-lmbench && RUNTIME=raw_syscalls $(MAKE)

build_wasmtime_lmbench:
	cd wasi-lmbench && RUNTIME=wasmtime $(MAKE)

run_lmbench: lmbench_wasmtime lmbench_wave lmbench_raw_syscalls



# sqlite benchmarks
# ==============================================================================
# Remember: $< is first input, $@ is output

build_sqlite: $(SQLITE_BUILD)/speedtest1_wasmtime $(SQLITE_BUILD)/speedtest1_wasm2c $(SQLITE_BUILD)/speedtest1_raw_syscalls

run_sqlite: sqlite_run_wasmtime sqlite_run_wasm2c sqlite_run_raw_syscalls

$(SQLITE_BUILD)/speedtest1.wasm:
	mkdir -p $(SQLITE_BUILD) 
	cd $(SQLITE_BUILD) && ../../sqlite/compile_speedtest1.sh ../../$(WASI_SDK_ROOT) ../../$(SQLITE_ROOT) ../../$(SQLITE_ROOT)/../lib
	cp $(SQLITE_BUILD)/speedtest1 $(SQLITE_BUILD)/speedtest1.wasm

$(SQLITE_BUILD)/speedtest1.wasm.c: $(SQLITE_BUILD)/speedtest1.wasm
	$(WASM2C_BIN_ROOT)/wasm2c -o $@ $<

$(SQLITE_BUILD)/speedtest1_wasm2c: $(SQLITE_BUILD)/speedtest1.wasm.c
	gcc -shared -fPIC -O3 -o $@ $< -I$(WASM2C_SRC_ROOT) $(WASM2C_SRC_ROOT)/wasm-rt-impl.c $(WASM2C_SRC_ROOT)/wasm-rt-os-unix.c $(WASM2C_SRC_ROOT)/wasm-rt-os-win.c $(WASM2C_SRC_ROOT)/wasm-rt-wasi.c build/wave/release/libwave.so -I../bindings

$(SQLITE_BUILD)/speedtest1_raw_syscalls: $(SQLITE_BUILD)/speedtest1.wasm.c
	gcc -shared -fPIC -O3 -o $@ $< -I$(WASM2C_SRC_ROOT) $(WASM2C_SRC_ROOT)/wasm-rt-impl.c $(WASM2C_SRC_ROOT)/wasm-rt-os-unix.c $(WASM2C_SRC_ROOT)/wasm-rt-os-win.c $(WASM2C_SRC_ROOT)/wasm-rt-wasi.c build/raw_syscalls/release/libwave.so -I../bindings

$(SQLITE_BUILD)/speedtest1_wasmtime: $(SQLITE_BUILD)/speedtest1.wasm
	$(WASMTIME_ROOT)/target/release/wasmtime compile $< -o $@

sqlite_run_wasmtime: $(SQLITE_BUILD)/speedtest1_wasmtime
	mkdir -p $(RESULTS_BASE)/sqlite
	$(WASMTIME_ROOT)/target/release/wasmtime --dir=. $< --allow-precompiled 2>/dev/null
	mv wasmtime_results.txt $(RESULTS_BASE)/sqlite/wasmtime.txt

sqlite_run_wasm2c: $(SQLITE_BUILD)/speedtest1_wasm2c
	mkdir -p $(RESULTS_BASE)/sqlite
	$(WASM2C_BIN_ROOT)/wasm2c-runner $< --homedir=.
	mv hostcall_results.txt $(RESULTS_BASE)/sqlite/hostcalls.txt 

sqlite_run_raw_syscalls: $(SQLITE_BUILD)/speedtest1_raw_syscalls
	mkdir -p $(RESULTS_BASE)/sqlite
	$(WASM2C_BIN_ROOT)/wasm2c-runner $< --homedir=.
	mv syscall_results.txt $(RESULTS_BASE)/sqlite/syscalls.txt


# spec benchmarks
# ==========================================================================
# NATIVE_BUILD=linux32-i386-clang linux32-i386-clangzerocost
# NACL_BUILDS=linux32-i386-nacl
# SPEC_BUILDS=$(NACL_BUILDS) $(NATIVE_BUILDS)

# SPEC_BENCHMARKS = 401.bzip2 429.mcf 433.milc 444.namd 445.gobmk 459.sjeng 462.libquantum 464.h264ref 470.lbm 473.astar 
SPEC_BENCHMARKS = 401.bzip2 429.mcf 433.milc 444.namd 462.libquantum 470.lbm 473.astar 
SPEC_BENCH_BASE = wave-specbenchmark/benchspec/CPU2006/


bootstrap_spec: 
	cd $(SPEC_PATH) && SPEC_INSTALL_NOCHECK=1 SPEC_FORCE_INSTALL=1 sh install.sh -f

# TODO: use parallel compilation? remove unnecessary options?
build_spec:
	cd $(SPEC_PATH) && source ./shrc && cd config && \
	runspec --config=wasmtime.cfg --action=build --noreportable --size=test wasm_compatible && \
	runspec --config=wasm2c_wave.cfg --action=build --noreportable --size=test wasm_compatible && \
	runspec --config=wave_raw_syscalls.cfg --action=build --noreportable --size=test wasm_compatible

# echo "Cleaning dirs" && \
# for spec_build in $(SPEC_BUILDS); do \
# 	runspec --config=$$spec_build.cfg --action=clobber all_c_cpp 2&>1 > /dev/null; \
# done && \
#  2>&1 | grep -i "building"

# TODO: change size of spec runs back to size=ref
# TODO: finalize
run_spec:
	mkdir -p $(RESULTS_BASE)/spec && \
	cd $(SPEC_PATH) && source ./shrc && cd config && \
	runspec --config=wasmtime.cfg --wasmtime --action=run --define cores=1 --iterations=1 --noreportable --size=test wasm_compatible && \
	runspec --config=wasm2c_wave.cfg --wasm2c_wave --action=run --define cores=1 --iterations=1 --noreportable --size=test wasm_compatible && \
	runspec --config=wave_raw_syscalls.cfg --wasm2c_wave --action=run --define cores=1 --iterations=1 --noreportable --size=test wasm_compatible
	for bench in $(SPEC_BENCHMARKS); do \
		mv $(SPEC_BENCH_BASE)/$$bench/run/run_base_test_wasmtime.0000/wasmtime_results.txt $(RESULTS_BASE)/spec/wasmtime_$$bench.txt; \
		mv $(SPEC_BENCH_BASE)/$$bench/run/run_base_test_wasm2c_wave.0000/hostcall_results.txt $(RESULTS_BASE)/spec/hostcalls_$$bench.txt; \
		mv $(SPEC_BENCH_BASE)/$$bench/run/run_base_test_wave_raw_syscalls.0000/syscall_results.txt $(RESULTS_BASE)/spec/syscalls_$$bench.txt; \
	done 

run_all: run_sqlite run_lmbench run_spec

