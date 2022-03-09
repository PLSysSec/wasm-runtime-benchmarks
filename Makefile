.PHONY: bench_wave bench_wasmtime

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


