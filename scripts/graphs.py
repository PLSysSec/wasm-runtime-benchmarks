def make_graph(all_times, output_path, use_percent=False):
    print("Making graph! all_times = " )
    for name, times in all_times.items():
        print(name, times)
    fig = plt.figure(figsize=(6.1,3))
    num_mitigations = len(all_times)
    num_benches = len(next(iter(all_times.values()))) # get any element
    mitigations = list(all_times.keys())
    width = (1.0 / ( (num_mitigations) + 1))        # the width of the bars

    ax = fig.add_subplot(111)

    plt.rcParams['pdf.fonttype'] = 42 # true type font
    plt.rcParams['font.family'] = 'Times New Roman'
    plt.rcParams['font.size'] = '8'

    vals = all_times_to_vals(all_times)

    ind = np.arange(num_benches)
    labels = tuple(sorted(list(next(iter(all_times.values())).keys())))
    print(labels)
    print(vals)

    # https://personal.sron.nl/~pault/data/colourschemes.pdf Section 2 figure 3
    colors = ['#BBBBBB','#0077BB','#EE7733','#EE3377','#009988']

    rects = []
    for idx,val in enumerate(vals):
      # if use_percent:
      val = [v - 1 for v in val]
      bottom=1
      # else:
      #  bottom=0
      rects.append(ax.bar(ind + width*idx, val, width, bottom=bottom, color=colors[idx]))


    #ax.set_xlabel('Spec2006 Benchmarks')
    if use_percent:
         ax.set_ylabel('Execution overhead')
    else:
        ax.set_ylabel('Relative execution time')
    ax.set_xticks(ind+width)
    plt.xticks(rotation=45, ha='right', rotation_mode='anchor')
    for lbl in ax.xaxis.get_majorticklabels():
        lbl.set_transform(lbl.get_transform() + Affine2D().translate(-2, 0))

    plt.axhline(y=1.0, color='black', linestyle='dashed')
    plt.ylim(ymin=.5)
    if not use_percent:
        plt.ylim(ymin=0)

    if use_percent:
        ax.yaxis.set_major_formatter(FuncFormatter(lambda y, _: '{:.0%}'.format(y-1.0)))
        ax.yaxis.set_major_locator(FixedLocator(np.arange(-.5,10,.5)))
    else:
        ax.yaxis.set_major_formatter(FuncFormatter(lambda y, _: '{:.0f}×'.format(y)))
        ax.yaxis.set_major_locator(FixedLocator([1] + list(range(5,25,5))))

    ax.set_xticklabels(labels)
    if use_percent:
        ax.legend( tuple(rects), all_times.keys(), ncol=2, loc=(.455, .59))
    else:
        ax.legend( tuple(rects), all_times.keys(), ncol=1, loc=(0.04, 0.59))
    #fig.subplots_adjust(bottom=0.25)
    plt.subplots_adjust(top = 1, bottom = 0, right = 1, left = 0,
            hspace = 0, wspace = 0)
    plt.margins(0,0)

    if os.path.exists(output_path + ".stats"):
        os.remove(output_path + ".stats")

    for i in range(num_mitigations):
        result_geomean = geomean(vals[i])
        result_median = median(vals[i])
        result_min = min(vals[i])
        result_max = max(vals[i])
        with open(output_path + ".stats", "a+") as myfile:
            myfile.write(f"{mitigations[i]} geomean = {result_geomean} {mitigations[i]} median = {result_median} min = {result_min} max = {result_max}\n")

    plt.tight_layout()
    plt.savefig(output_path + ".pdf", format="pdf", bbox_inches="tight", pad_inches=0)
