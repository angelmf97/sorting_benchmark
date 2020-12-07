#!/usr/bin/bash

usage() { echo "Usage: $0 [-a <s|i|q>] [-r <number of replicates>] [-s <batch sizes>]" 1>&2; exit 1; }

while getopts ":a:r:s:" opts; do
    case "${opts}" in
        a)
            IFS=',' read -r -a a <<< "${OPTARG}"
            ;;
        r)
            r="${OPTARG}"
            ;;
        s)
            IFS=',' read -r -a s <<< "${OPTARG}"
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${r}" ] || [ -z "${a}" ]; then
    usage
fi

printf "Generating datasets of sizes ${s[*]} with $r replicates. Datasets stored in ./datasets\n"

mkdir -p datasets

for ((e=1; e<=$r; e++));
	do
	for n in "${s[@]}"
	do
		perl -e '$MAX = $ARGV[0];
			     srand(time);
			     for ($i = 0; $i < $MAX; $i++) {
				 print int(rand($MAX)),"\n";
			     };' "$n" > ./datasets/numlist_random_"$n"_"$e".tbl
		
		perl -e '$MAX = $ARGV[0];
			     $number = int(rand($MAX));
			     for ($i = 0; $i < $MAX; $i++) {
				 print "$number\n";
			     };' "$n" > ./datasets/numlist_constant_"$n"_"$e".tbl

		perl -e '$MAX = $ARGV[0];
			     $number = int(rand($MAX));
			     for ($i = 0; $i < $MAX; $i++) {
				 print $i % $number,"\n";
			     };' "$n" > ./datasets/numlist_repeat_"$n"_"$e".tbl
			     
		sort -n ./datasets/numlist_random_"$n"_"$e".tbl > ./datasets/numlist_ordered_"$n"_"$e".tbl

		sort -nr ./datasets/numlist_random_"$n"_"$e".tbl > ./datasets/numlist_deredro_"$n"_"$e".tbl
		
		sort -n ./datasets/numlist_repeat_"$n"_"$e".tbl > ./datasets/numlist_repeat2_"$n"_"$e".tbl
	done
done

printf "Benchmarking. This might take several time for large datasets or a high number of replicates.\n"
for OPTION in "${a[@]}";
        do {

		for DATASET in random ordered deredro constant repeat repeat2;
        		do {
        		for n in "${s[@]}";
			do {
			    for ((e=1; e<=$r; e++));
			    do {

			      perl perlsort.pl $OPTION ./datasets/numlist_"$DATASET"_"$n"_"$e".tbl |\
			      sed -r -e 's/.*_(.*)_([0-9]+)_([0-9]+)[^\t]+/\1\t\2\t\3/'\
			      -e 's/\s+[0-9]+\swallclock.*=\s+([0-9]+\.[0-9]+)\sCPU.*/\t\1/g';
			    } done;
			} done;
		} done;   
        } done > results.txt


printf "Generating plots."
Rscript analysis.R "$r" "${a[*]}" "${s[*]}"
evince *.pdf &


