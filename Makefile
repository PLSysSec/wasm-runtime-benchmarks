.PHONY: lmbench_wave lmbench_raw_syscalls lmbench_wasmtime sqlite_run_wasmtime sqlite_run_wasm2c sqlite_run_raw_syscalls run_sqlite run_lmbench run_all

SQLITE_ROOT    ?= sqlite/sqlite

WASI_SDK_ROOT=../tools/wasi-sdk
#WASI_SDK_INSTALL=$(WASI_SDK_ROOT)/build/install/opt/wasi-sdk/bin/
WASI_SDK_INSTALL=$(WASI_SDK_ROOT)/build/install/opt/wasi-sdk/
WASM2C_ROOT=../tools/wasm2c_sandbox_compiler

#WASI_SDK_ROOT=../../../tools/wasi-sdk
#WASI_SDK_INSTALL=$(WASI_SDK_ROOT)/build/install/opt/wasi-sdk/
#WASM2C_ROOT=../../../tools/wasm2c_sandbox_compiler



WASM2C_SRC_ROOT = $(WASM2C_ROOT)/wasm2c
WASM2C_BIN_ROOT = $(WASM2C_ROOT)/bin

SQLITE_BUILD = build/sqlite

WASMTIME_ROOT=runtimes/wasmtime


# These CPU numbers are for elk
PINNED_CPU = 8
# SIBLING_CPU = 48
#SETUP_BENCH = nice -n -20 taskset -c $(PINNED_CPU) 
SETUP_BENCH = 
INVOKE_WAVE = LD_LIBRARY_PATH=../build/wave/release $(SETUP_BENCH) ../$(WASM2C_BIN_ROOT)/wasm2c-runner 
INVOKE_WAVE_RAW_SYSCALLS = LD_LIBRARY_PATH=../build/raw_syscalls/release $(SETUP_BENCH) ../$(WASM2C_BIN_ROOT)/wasm2c-runner
INVOKE_WASMTIME = $(SETUP_BENCH) ../runtimes/wasmtime/target/release/wasmtime run --allow-unknown-exports --allow-precompiled  

INVOKE_WAVE_WITH_SYSCALLS = LD_LIBRARY_PATH=../build/wave_with_syscalls/release $(SETUP_BENCH) ../$(WASM2C_BIN_ROOT)/wasm2c-runner 


#NOW=`date '+%F_%H:%M:%S'`
#RESULTS_BASE=results/$(date "+%Y_%m_%d-%H_%M_%S")
#RESULTS_BASE=results/$(NOW)
RESULTS_BASE:= results/$(shell date --iso=seconds)


# shared commands
# ==============================================================================
build_raw_syscalls:
	cargo build --target-dir=build/raw_syscalls --release --features=time_syscalls

build_wave:
	cargo build --target-dir=build/wave --release --features=time_hostcalls

build_wave_with_syscalls:
	cargo build --target-dir=build/wave_with_syscalls --release --features=time_hostcalls --features=time_syscalls

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

lmbench_wave_with_syscalls: build_wave_with_syscalls_lmbench
	mkdir -p $(RESULTS_BASE)/lmbench
	cd wasi-lmbench && $(INVOKE_WAVE_WITH_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 null data/tmp.txt" --homedir="." 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_null.txt 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_null.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_WITH_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 read data/tmp.txt" --homedir="/" 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_read.txt 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_read.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_WITH_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 write data/tmp.txt" --homedir="/" 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_write.txt 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_write.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_WITH_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 stat data/tmp.txt" --homedir="." 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_stat.txt 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_stat.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_WITH_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 fstat data/tmp.txt" --homedir="." 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_fstat.txt 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_fstat.txt 
	cd wasi-lmbench && $(INVOKE_WAVE_WITH_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 open data/tmp.txt" --homedir="." 
	mv wasi-lmbench/hostcall_results.txt $(RESULTS_BASE)/lmbench/hostcalls_open.txt 
	mv wasi-lmbench/syscall_results.txt $(RESULTS_BASE)/lmbench/syscalls_open.txt 

build_wave_lmbench: build_wave
	cd wasi-lmbench && RUNTIME=wave $(MAKE)

build_raw_syscalls_lmbench: build_raw_syscalls
	cd wasi-lmbench && RUNTIME=raw_syscalls $(MAKE)

build_wasmtime_lmbench:
	cd wasi-lmbench && RUNTIME=wasmtime $(MAKE)

build_wave_with_syscalls_lmbench: build_wave_with_syscalls
	cd wasi-lmbench && RUNTIME=wave_with_syscalls $(MAKE)

build_lmbench: build_wave_lmbench build_raw_syscalls_lmbench build_wasmtime_lmbench

run_lmbench: lmbench_wasmtime lmbench_wave lmbench_raw_syscalls



# sqlite benchmarks
# ==============================================================================
# Remember: $< is first input, $@ is output

build_sqlite: $(SQLITE_BUILD)/speedtest1_wasmtime $(SQLITE_BUILD)/speedtest1_wasm2c $(SQLITE_BUILD)/speedtest1_raw_syscalls

run_sqlite: sqlite_run_wasmtime sqlite_run_wasm2c sqlite_run_raw_syscalls

$(SQLITE_BUILD)/speedtest1.wasm:
	mkdir -p $(SQLITE_BUILD) 
	cd $(SQLITE_BUILD) && ../../sqlite/compile_speedtest1.sh ../../$(WASI_SDK_INSTALL) ../../$(SQLITE_ROOT) ../../$(SQLITE_ROOT)/../lib
	cp $(SQLITE_BUILD)/speedtest1 $(SQLITE_BUILD)/speedtest1.wasm

$(SQLITE_BUILD)/speedtest1.wasm.c: $(SQLITE_BUILD)/speedtest1.wasm
	$(WASM2C_BIN_ROOT)/wasm2c -o $@ $<

$(SQLITE_BUILD)/speedtest1_wasm2c: $(SQLITE_BUILD)/speedtest1.wasm.c
	gcc -shared -fPIC -O3 -o $@ $< -I$(WASM2C_SRC_ROOT) $(WASM2C_SRC_ROOT)/wasm-rt-impl.c $(WASM2C_SRC_ROOT)/wasm-rt-os-unix.c $(WASM2C_SRC_ROOT)/wasm-rt-os-win.c $(WASM2C_SRC_ROOT)/wasm-rt-wasi.c build/wave/release/libwave.so -I../bindings

$(SQLITE_BUILD)/speedtest1_raw_syscalls: $(SQLITE_BUILD)/speedtest1.wasm.c
	gcc -shared -fPIC -O3 -o $@ $< -I$(WASM2C_SRC_ROOT) $(WASM2C_SRC_ROOT)/wasm-rt-impl.c $(WASM2C_SRC_ROOT)/wasm-rt-os-unix.c $(WASM2C_SRC_ROOT)/wasm-rt-os-win.c $(WASM2C_SRC_ROOT)/wasm-rt-wasi.c build/raw_syscalls/release/libwave.so -I../bindings

$(SQLITE_BUILD)/speedtest1_wasmtime: $(SQLITE_BUILD)/speedtest1.wasm
	$(WASMTIME_ROOT)/target/release/wasmtime compile $< -o $@



$(SQLITE_BUILD)/speedtest1_wasm2c_with_syscalls: $(SQLITE_BUILD)/speedtest1.wasm.c
	gcc -shared -fPIC -O3 -o $@ $< -I$(WASM2C_SRC_ROOT) $(WASM2C_SRC_ROOT)/wasm-rt-impl.c $(WASM2C_SRC_ROOT)/wasm-rt-os-unix.c $(WASM2C_SRC_ROOT)/wasm-rt-os-win.c $(WASM2C_SRC_ROOT)/wasm-rt-wasi.c build/wave_with_syscalls/release/libwave.so -I../bindings


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

sqlite_run_wave_with_syscalls: $(SQLITE_BUILD)/speedtest1_wasm2c_with_syscalls
	mkdir -p $(RESULTS_BASE)/sqlite
	$(WASM2C_BIN_ROOT)/wasm2c-runner $< --homedir=.
	mv hostcall_results.txt $(RESULTS_BASE)/sqlite/hostcalls.txt 
	mv syscall_results.txt $(RESULTS_BASE)/sqlite/syscalls.txt


run_all: run_sqlite run_lmbench

