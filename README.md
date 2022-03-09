# wasm-runtime-benchmarks
I/O-heavy benchmarks for testing wasm runtimes

Run benchmarks as root to use "nice" to improve stability of measurements

## Some misc benchmarking commands to keep around

### Disabling turboboost
echo 1 > /sys/devices/system/cpu/intel\_pstate/no\_turbo
to restore: echo 0 > /sys/devices/system/cpu/intel\_pstate/no\_turbo

### Disabling logical CPUs
echo 0 > /sys/devices/system/cpu/cpu4/online
to restore: echo 1 > /sys/devices/system/cpu/cpu4/online

### Disabling dynamic frequency scaling
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
to restore: echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
 



