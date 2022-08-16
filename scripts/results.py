import os
import sys
from collections import defaultdict
import matplotlib.pyplot as plt
import numpy as np
import argparse
from matplotlib.ticker import FuncFormatter, FixedLocator
from matplotlib.transforms import Affine2D
from tables import *
from graphs import make_graph

runtimes = ["hostcalls", "syscalls", "wasmtime"]
lmbench_benchmarks = ["null", "read", "write", "stat", "fstat", "open"]
spec_benchmarks = ["401.bzip2", "429.mcf", "444.namd", "462.libquantum", "470.lbm", "473.astar"]


# hostcalls_401.bzip2.txt  hostcalls_462.libquantum.txt  
# hostcalls_429.mcf.txt    hostcalls_470.lbm.txt        
# hostcalls_444.namd.txt   hostcalls_473.astar.txt  

# def geomean(lst):
#     # Geomean is conceptually:
#     #   product of all terms in the list, take nth root
#     # This can overflow, so it is better to compute it as:
#     #   log all terms in the list, arithmetic mean, un-log
#     # which is equivalent
#     lst = np.array(lst)
#     return np.exp(np.mean(np.log(1.0*lst)))  # 1.0* and np.log implicitly lift to lists elementwise


# key = benchmark name
# 0 = num samples
# 1 = mean
# 2 = geomean
# {name -> (num_samples, mean, geomean)}
def load_data(input_path):
    d = {}
    with open(input_path, 'r') as f:
        data = f.read()
        lines = data.split('\n')
        for line in lines:
            split_line = line.split(',')
            if len(split_line) == 4:
                bench_name = split_line[0] 
                num_samples = int(split_line[1])
                mean = float(split_line[2])
                geomean = float(split_line[3])
                d[bench_name] = (num_samples, mean, geomean)
    return d

# hostcalls_fstat.txt  hostcalls_open.txt  hostcalls_stat.txt  
# hostcalls_null.txt   hostcalls_read.txt  hostcalls_write.txt  

# syscalls_fstat.txt  syscalls_open.txt  syscalls_stat.txt   
# syscalls_null.txt   syscalls_read.txt  syscalls_write.txt  

# wasmtime_fstat.txt  wasmtime_open.txt  wasmtime_stat.txt
# wasmtime_null.txt   wasmtime_read.txt  wasmtime_write.txt


# bench name -> hostcall
lmbench_translation_table = {
    "null": '"sched_yield"',
    "read": '"fd_read"',
    "write": '"fd_write"',
    "stat": '"path_filestat_get"',
    "fstat": '"fd_filestat_get"',
    "open": '"path_open"',
}

# bench name -> syscall
syscall_translation_table = {
    "read": '"readv"',
    "write": '"writev"',
    "stat": '"newfstatat"',
    "fstat": '"fstat"',
    "open": '"openat"',
}


# {runtime -> {benchmark -> mean}}
def run_lmbench(input_path, output_path):
    all_data = {}
    for runtime in runtimes:
        # if runtime == "syscalls":
        #     continue
        all_data[runtime] = {}
        for benchmark in lmbench_benchmarks:
            input_file = os.path.join(input_path, runtime + "_" + benchmark + ".txt")
            d = load_data(input_file)
            # print(d)
            if runtime == "syscalls":
                print(d)
                if benchmark == "null":
                    all_data[runtime][benchmark] = 0.0
                else:
                    syscall_name = syscall_translation_table[benchmark]
                    mean = d[syscall_name][1] # gather mean for each benchmark
                    all_data[runtime][benchmark] = mean
            else:
                hostcall_name = lmbench_translation_table[benchmark]
                mean = d[hostcall_name][1] # gather mean for each benchmark
                all_data[runtime][benchmark] = mean
            #make_graph(input_file, output_file)
    print(all_data)
    table = create_lmbench_summary_table(all_data)
    print(table)

    compute_lmbench_stats(all_data)
    # d = load_data(input_path)
    # for k, v in d.items():
    #     print(k, v)

def run_sqlite(input_path, output_path):
    hostcalls_path = os.path.join(input_path, "hostcalls.txt")
    syscalls_path = os.path.join(input_path, "syscalls.txt")
    wasmtime_path = os.path.join(input_path, "wasmtime.txt")

    hostcalls_data = load_data(hostcalls_path)
    syscalls_data = load_data(syscalls_path)
    wasmtime_data = load_data(wasmtime_path)

    d = {"wave": hostcalls_data, "syscalls": syscalls_data, "wasmtime": wasmtime_data}

    table = create_sqlite_summary_table(d)
    print(table)

    aggregate_table = create_sqlite_summary_table_aggregate(d)
    print(aggregate_table)
    # for k, v in d.items():
    #     print(k, v)
    count_sqlite_calls(d)


# hostcalls_401.bzip2.txt  hostcalls_462.libquantum.txt  
# hostcalls_429.mcf.txt    hostcalls_470.lbm.txt        
# hostcalls_444.namd.txt   hostcalls_473.astar.txt      

# wasmtime_401.bzip2.txt  wasmtime_462.libquantum.txt
# wasmtime_429.mcf.txt    wasmtime_470.lbm.txt
# wasmtime_444.namd.txt   wasmtime_473.astar.txt

# syscalls_401.bzip2.txt  syscalls_462.libquantum.txt  
# syscalls_429.mcf.txt    syscalls_470.lbm.txt         
# syscalls_444.namd.txt   syscalls_473.astar.txt       


def run_spec(input_path, output_path):
    all_data = {}
    for benchmark in spec_benchmarks:
        all_data[benchmark] = {}
        for runtime in runtimes:
            print(runtime, benchmark)
            input_file = os.path.join(input_path, runtime + "_" + benchmark + ".txt")
            d = load_data(input_file)
            all_data[benchmark][runtime] = d
            # print(d)
            # hostcall_name = lmbench_translation_table[benchmark]
            # mean = d[hostcall_name][1] # gather mean for each benchmark
            # all_data[runtime][benchmark] = mean
            #make_graph(input_file, output_file)
    table = create_spec_summary_table(all_data)
    print(table)
    count_spec_calls(all_data)
    #print(all_data)
    # d = load_data(input_path)
    # for k, v in d.items():
    #     print(k, v)

def run(input_dir, output_dir, benchmark):
    if benchmark == 'lmbench':
        run_lmbench(input_dir, output_dir)
    elif benchmark == 'sqlite':
        run_sqlite(input_dir, output_dir)
    elif benchmark == 'spec':
        run_spec(input_dir, output_dir)
    else:
        print("Unknown benchmark: {}".format(benchmark))
        exit(0)


def main():
    parser = argparse.ArgumentParser(description='Graph Results')
    parser.add_argument('-i', dest='input_path', help='input directory containing results')
    parser.add_argument('-o', dest='output_path', help='output directory with graphs')
    parser.add_argument('-b', dest='benchmark', help='(lmbench | sqlite | spec)')
    args = parser.parse_args()
    run(args.input_path, args.output_path, args.benchmark)


if __name__ == '__main__':
    main()