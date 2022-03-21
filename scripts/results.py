import os
import sys
from collections import defaultdict
import matplotlib.pyplot as plt
import numpy as np
import argparse
from matplotlib.ticker import FuncFormatter, FixedLocator
from matplotlib.transforms import Affine2D
from tables import generate_summary_table
from graphs import make_graph

runtimes = ["hostcalls", "syscalls", "wasmtime"]
lmbench_benchmarks = ["null", "read", "write", "stat", "fstat", "open"]

def geomean(lst):
    # Geomean is conceptually:
    #   product of all terms in the list, take nth root
    # This can overflow, so it is better to compute it as:
    #   log all terms in the list, arithmetic mean, un-log
    # which is equivalent
    lst = np.array(lst)
    return np.exp(np.mean(np.log(1.0*lst)))  # 1.0* and np.log implicitly lift to lists elementwise


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
            d[split_line[0]] = split_line[1:] 
    return d

def run_lmbench(input_path, output_path):
    d = load_data(input_path)
    for k, v in d.items():
        print(k, v)

def run_sqlite(input_path, output_path):
    hostcalls_path = os.path.join(input_path, "hostcalls.txt")
    syscalls_path = os.path.join(input_path, "syscalls.txt")
    wasmtime_path = os.path.join(input_path, "wasmtime.txt")

    hostcalls_data = load_data(hostcalls_path)
    syscalls_data = load_data(syscalls_path)
    wasmtime_data = load_data(wasmtime_path)

    d = {"wave": hostcalls_data, "syscalls": syscalls_data, "wasmtime": wasmtime_data}

    for k, v in d.items():
        print(k, v)

def run_spec(input_path, output_path):
    d = load_data(input_path)
    for k, v in d.items():
        print(k, v)

def run(input_dir, output_dir, benchmark):
    if benchmark == 'lmbench':
        run_lmbench(input_dir, output_dir)
    if benchmark == 'sqlite':
        run_sqlite(input_dir, output_dir)
    if benchmark == 'spec':
        run_spec(input_dir, output_dir)

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