# sorting_benchmark

Usage example:
`bash analysis.sh -a s,i,q -r 2 -s 1000,2000,3000`

This command benchmarks the selection, insertion and quicksort algoritms using datasets of 1000, 2000 and 3000 numbers with 2 replicates each.

# Arguments

* -a : algorithms that will be compared. Options are i (insertion), s (selection) and q (quicksort). The different options must be separated by commas and with no blank spaces.
* -r : number of replicates of each data set.
* -s : size of the data sets. Values must be separated by commas and with no blank spaces.

