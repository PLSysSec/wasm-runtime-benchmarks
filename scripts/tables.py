# key = benchmark name
# 0 = num samples
# 1 = mean
# 2 = geomean
# {name -> (num_samples, mean, geomean)}
def generate_summary_table(data):
    names_row = " &"
    num_samples_row = "# of samples & "
    mean_row = "Mean time (ns) & "
    geomean_row = "Geomean time (ns) & "
    
    names_row +=     " & ".join([k for k in data.keys()]) + "\\\\"
    num_samples_row +=   " & ".join([str(num) for num in data]) + "\\\\"
    mean_row +=    " & ".join([str(round(d[2],2)) for d in data]) + "\\\\"
    geomean_row +=    " & ".join([str(round(d[2],2)) for d in data]) + "\\\\"
    table_str = "\n\\hline\n".join([names_row, average_row, median_row, max_row, min_row, num_funcs_row, total_row]) + "\n"
    return table_str
