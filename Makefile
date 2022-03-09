.PHONY: bench_wave bench_raw_syscalls bench_wasmtime run_wasmtime run_wasm2c run_raw_syscalls

SQLITE_ROOT    ?= sqlite/sqlite

RLBOX_ROOT      = ../rlbox_wasm2c_sandbox
WASM2C_SRC_ROOT = $(RLBOX_ROOT)/build/_deps/mod_wasm2c-src/wasm2c
WASM2C_BIN_ROOT = $(RLBOX_ROOT)/build/_deps/mod_wasm2c-src/bin

SQLITE_BUILD = build/sqlite

WASI_SDK_ROOT = $(RLBOX_ROOT)/build/_deps/wasiclang-src/build/install/opt/wasi-sdk

WASMTIME_ROOT=runtimes/wasmtime


PINNED_CPU = 8
SETUP_BENCH = nice -n -20 taskset -c $(PINNED_CPU) 
INVOKE_WAVE = LD_LIBRARY_PATH=../build/wave/release $(SETUP_BENCH) ../../rlbox_wasm2c_sandbox/build/_deps/mod_wasm2c-src/bin/wasm2c-runner 
INVOKE_WAVE_RAW_SYSCALLS = LD_LIBRARY_PATH=../build/raw_syscalls/release $(SETUP_BENCH) ../../rlbox_wasm2c_sandbox/build/_deps/mod_wasm2c-src/bin/wasm2c-runner
INVOKE_WASMTIME = $(SETUP_BENCH) ../runtimes/wasmtime/target/release/wasmtime run --allow-unknown-exports --allow-precompiled  
#--dir=. bin/wasmtime/lat_syscall -- -N 1000000 open data/tmp.txt

bench_wave: build_wave_lmbench
	echo "Bench: null" > wave.txt
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 null data/tmp.txt" --homedir="." >> ../wave.txt
	echo "Bench: read" >> wave.txt
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 read data/tmp.txt" --homedir="/" >> ../wave.txt
	echo "Bench: write" >> wave.txt
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 write data/tmp.txt" --homedir="/" >> ../wave.txt
	echo "Bench: stat" >> wave.txt
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 stat data/tmp.txt" --homedir="." >> ../wave.txt
	echo "Bench: fstat" >> wave.txt
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 fstat data/tmp.txt" --homedir="." >> ../wave.txt
	echo "Bench: open" >> wave.txt
	cd wasi-lmbench && $(INVOKE_WAVE) bin/wave/lat_syscall --args="lat_syscall -N 1000000 open data/tmp.txt" --homedir="." >> ../wave.txt

# We don't need a seperate build for this since we can just update the runtime library
# with the instrumentation to track syscalls
bench_raw_syscalls: build_raw_syscalls_lmbench
	echo "Bench: null" > raw_syscalls.txt
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 null data/tmp.txt" --homedir="." >> ../raw_syscalls.txt
	echo "Bench: read" >> raw_syscalls.txt
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 read data/tmp.txt" --homedir="/" >> ../raw_syscalls.txt
	echo "Bench: write" >> raw_syscalls.txt
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 write data/tmp.txt" --homedir="/" >> ../raw_syscalls.txt
	echo "Bench: stat" >> raw_syscalls.txt
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 stat data/tmp.txt" --homedir="." >> ../raw_syscalls.txt
	echo "Bench: fstat" >> raw_syscalls.txt
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 fstat data/tmp.txt" --homedir="." >> ../raw_syscalls.txt
	echo "Bench: open" >> raw_syscalls.txt
	cd wasi-lmbench && $(INVOKE_WAVE_RAW_SYSCALLS) bin/wave/lat_syscall --args="lat_syscall -N 1000000 open data/tmp.txt" --homedir="." >> ../raw_syscalls.txt

bench_wasmtime: build_wasmtime_lmbench
	echo "Bench: null" > wasmtime.txt
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=. bin/wasmtime/lat_syscall -- -N 1000000 null data/tmp.txt >> ../wasmtime.txt
	echo "Bench: read" >> wasmtime.txt
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=/ bin/wasmtime/lat_syscall -- -N 1000000 read data/tmp.txt >> ../wasmtime.txt
	echo "Bench: write" >> wasmtime.txt
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=/ bin/wasmtime/lat_syscall -- -N 1000000 write data/tmp.txt >> ../wasmtime.txt
	echo "Bench: stat" >> wasmtime.txt
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=. bin/wasmtime/lat_syscall -- -N 1000000 stat data/tmp.txt >> ../wasmtime.txt
	echo "Bench: fstat" >> wasmtime.txt
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=. bin/wasmtime/lat_syscall -- -N 1000000 fstat data/tmp.txt >> ../wasmtime.txt
	echo "Bench: open" >> wasmtime.txt
	cd wasi-lmbench && $(INVOKE_WASMTIME) --dir=. bin/wasmtime/lat_syscall -- -N 1000000 open data/tmp.txt >> ../wasmtime.txt



build_raw_syscalls:
	cargo build --target-dir=build/raw_syscalls --release --features=time_syscalls

build_wave:
	cargo build --target-dir=build/wave --release --features=time_hostcalls

build_wave_lmbench: build_wave
	cd wasi-lmbench && RUNTIME=wave $(MAKE)

build_raw_syscalls_lmbench: build_raw_syscalls
	cd wasi-lmbench && RUNTIME=raw_syscalls $(MAKE)

# Time just the syscalls
# build_raw_syscalls:
# 	cd .. && cargo build --release --features time_syscalls
# 	cd wasi-lmbench && RUNTIME=raw_syscalls $(MAKE)

build_wasmtime_lmbench:
	cd wasi-lmbench && RUNTIME=wasmtime $(MAKE)

clean:
	cd wasi-lmbench && $(MAKE) clean
	rm -rf build



# sqlite benchmarks
# Remember: $< is first input, $@ is output

build_sqlite: speedtest1_wasmtime speedtest1_wasm2c speedtest1_raw_syscalls

clean_sqlite:
	$(RM) $(SQLITE_BUILD)/speedtest1.wasm
	$(RM) $(SQLITE_BUILD)/speedtest1.wasm.c
	$(RM) $(SQLITE_BUILD)/speedtest1.wasm.h
	$(RM) $(SQLITE_BUILD)/speedtest1_wasmtime
	$(RM) $(SQLITE_BUILD)/speedtest1_wasm2c
	$(RM) -r $(SQLITE_BUILD) 

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

run_wasmtime: $(SQLITE_BUILD)/speedtest1_wasmtime
	$(WASMTIME_ROOT)/target/release/wasmtime --dir=. $< --allow-precompiled 2>/dev/null

run_wasm2c: $(SQLITE_BUILD)/speedtest1_wasm2c
	$(WASM2C_BIN_ROOT)/wasm2c-runner $< --homedir=.

run_raw_syscalls: $(SQLITE_BUILD)/speedtest1_raw_syscalls
	$(WASM2C_BIN_ROOT)/wasm2c-runner $< --homedir=.



