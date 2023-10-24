import numpy as np

def geomean(iterable):
    return np.exp(np.log(iterable).mean())

# translation_table = {
#     "args_get" : 
#     "args_sizes_get" : 
#     "proc_exit" : 
#     "environ_sizes_get" : 
#     "environ_get" : 
#     "fd_prestat_get" : 
#     "fd_write" : "write"
#     "fd_read" : "read"
#     "fd_close" : "close"
#     "fd_seek" : "seek"
#     "clock_time_get" : 
#     "clock_res_get" : 
#     "fd_advise" : "advise"
#     "fd_allocate" : "allocate"
#     "fd_datasync" : 
#     "fd_fdstat_get" : 
#     "fd_fdstat_set_flags" : 
#     "fd_filestat_get" : 
#     "fd_filestat_set_size" : 
#     "fd_filestat_set_times" : 
#     "fd_pread" : "pread"
#     "fd_prestat_dir_name" : 
#     "fd_pwrite" : "pwrite"
#     "fd_readdir" : 
#     "fd_renumber" : 
#     "fd_sync" : 
#     "fd_tell" : 
#     "path_create_directory" : "mkdirat"
#     "path_filestat_get" : 
#     "path_filestat_set_times" : 
#     "path_link" : 
#     "path_open" : "openat"
#     "path_readlink" : "readlinkat"
#     "path_remove_directory" : "unlinkat"
#     "path_rename" : 
#     "path_symlink" : 
#     "path_unlink_file" : 
#     "poll_oneoff" : 
#     "proc_raise" : 
#     "random_get" : 
#     "sched_yield" : 
#     "sock_recv" : 
#     "sock_send" : 
#     "sock_shutdown" : 
#     "socket" : "socket"
#     "sock_connect" : "connect"
# }

#     h.insert("sync".to_owned(), Vec::new());
#     h.insert("datasync".to_owned(), Vec::new());
#     h.insert("fstat".to_owned(), Vec::new());
#     h.insert("fstatat".to_owned(), Vec::new());
#     h.insert("fgetfl".to_owned(), Vec::new());
#     h.insert("fsetfl".to_owned(), Vec::new());
#     h.insert("ftruncate".to_owned(), Vec::new());
#     h.insert("linkat".to_owned(), Vec::new());
#     h.insert("mkdirat".to_owned(), Vec::new());
#     h.insert("renameat".to_owned(), Vec::new());
#     h.insert("symlinkat".to_owned(), Vec::new());
#     h.insert("futimens".to_owned(), Vec::new());
#     h.insert("utimensat".to_owned(), Vec::new());
#     h.insert("clock_get_time".to_owned(), Vec::new());
#     h.insert("clock_get_res".to_owned(), Vec::new());
#     h.insert("getrandom".to_owned(), Vec::new());
#     h.insert("recv".to_owned(), Vec::new());
#     h.insert("send".to_owned(), Vec::new());
#     h.insert("shutdown".to_owned(), Vec::new());
#     h.insert("nanosleep".to_owned(), Vec::new());
#     h.insert("poll".to_owned(), Vec::new());
#     h.insert("getdents64".to_owned(), Vec::new());
#     RefCell::new(h)
# }

# }

# d = {"wave": hostcalls_data, "syscalls": syscalls_data, "wasmtime": wasmtime_data}

# def create_names_list(data):


# key = benchmark name
# 0 = num samples
# 1 = mean
# 2 = geomean
# {name -> (num_samples, mean, geomean)}
# currently just plots averages
def create_sqlite_summary_table(data):
    names_row = " &"
    wave_row = "Wave & "
    wasmtime_row = "Wasmtime & "
    # syscalls_row = "Syscalls & "
    #for runtime,benchdata in data.items():
    benchdata = data["wave"]
    for benchname in benchdata:
        names_row += "&" + benchname
        wave_row += " & " + str(round(data["wave"][benchname][1], 2))
        wasmtime_row += " & " + str(round(data["wasmtime"][benchname][1], 2))

    # names_row +=      " & ".join([k for k in keys]) + "\\\\"
    # # print([d[1] for d in data['wave'].values()])
    # wave_row +=       " & ".join([str(round(d[1],2)) for d in data['wave'].values()]) + "\\\\"
    # wasmtime_row +=   " & ".join([str(round(d[1],2)) for d in data['wasmtime'].values()]) + "\\\\"
    # #syscalls_row +=   " & ".join([str(round(d[1],2)) for d in data['syscalls'].values()]) + "\\\\"
    names_row += "\\\\"
    wave_row += "\\\\"
    wasmtime_row += "\\\\"

    # mean_row +=    " & ".join([str(round(d[2],2)) for d in data]) + "\\\\"
    # geomean_row +=    " & ".join([str(round(d[2],2)) for d in data]) + "\\\\"
    table_str = "\n\\hline\n".join([names_row, wave_row, wasmtime_row]) + "\n"
    return table_str




def compute_aggregate(data):
    total = 0.0
    for benchname in data:
        num_samples = data[benchname][0]
        time_per_sample = data[benchname][1]
        total += num_samples * time_per_sample
    return total

# key = benchmark name
# 0 = num samples
# 1 = mean
# 2 = geomean
# {name -> (num_samples, mean, geomean)}
# currently just plots averages
def create_sqlite_summary_table_aggregate(data):
    wave_total = compute_aggregate(data['wave'])
    wasmtime_total = compute_aggregate(data['wasmtime'])
    syscalls_total = compute_aggregate(data['syscalls'])

    names_row = "& Execution time"
    wave_row = "wave & " + str(round(wave_total / 1000, 2)) # nanoseconds to milliseconds
    wasmtime_row = "wasmtime & " + str(round(wasmtime_total / 1000, 2))
    syscalls_row = "syscalls & " + str(round(syscalls_total / 1000, 2))

    names_row += "\\\\"
    wave_row += "\\\\"
    wasmtime_row += "\\\\"
    syscalls_row += "\\\\"

    # mean_row +=    " & ".join([str(round(d[2],2)) for d in data]) + "\\\\"
    # geomean_row +=    " & ".join([str(round(d[2],2)) for d in data]) + "\\\\"
    table_str = "\n\\hline\n".join([names_row, wave_row, wasmtime_row, syscalls_row]) + "\n"
    return table_str







def create_lmbench_summary_table(data):
    names_row = " &"
    wave_row = "Wave & "
    wasmtime_row = "Wasmtime & "
    syscalls_row = "Syscalls & "
    #for runtime,benchdata in data.items():
    benchdata = data["hostcalls"]
    for benchname in benchdata:
        names_row += "&" + benchname
        wave_row += " & " + str(round(data["hostcalls"][benchname], 2))
        wasmtime_row += " & " + str(round(data["wasmtime"][benchname], 2))
        syscalls_row += " & " + str(round(data["syscalls"][benchname], 2))

    names_row += "\\\\"
    wave_row += "\\\\"
    wasmtime_row += "\\\\"
    syscalls_row += "\\\\"

    table_str = "\n\\hline\n".join([names_row, wave_row, wasmtime_row, syscalls_row]) + "\n"
    return table_str

def compute_lmbench_stats(data):
    #    benchdata = data["hostcalls"]
    #for benchname in benchdata:
    print("=================================")
    print(data["hostcalls"])
    print(data["syscalls"])
    syscall_data = data["syscalls"]
    hostcall_times = [x[1] / syscall_data[x[0]] for x in data["hostcalls"].items() if x[0] != "null"]
    wasmtime_times = [x[1] / syscall_data[x[0]] for x in data["wasmtime"].items() if x[0] != "null"]
    # syscall_times = [x[1] for x in data["syscalls"].items() if x[0] != "null" ]



    print("hostcall_times: ", min(hostcall_times), "to", max(hostcall_times), "(geomean:", geomean(hostcall_times), ")")
    print("wasmtime_times: ", min(wasmtime_times), "to", max(wasmtime_times), "(geomean:", geomean(wasmtime_times), ")" )
    # print("syscall_times: ", min(syscall_times), max(syscall_times))





def count_sqlite_calls(data):
    #benchdata = data["wave"]
    total_hostcalls = 0
    # for benchdata in data["wave"].values():
    #     print(benchdata)
    #     total_hostcalls += benchdata[0]
    num_samples = [x[0]  for x in data["wave"].values()]
    total_hostcalls = sum(num_samples)

    print("total hostcalls: " + str(total_hostcalls))

