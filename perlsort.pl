#!/usr/bin/perl
#
use strict;
use warnings;

use Benchmark;

# Initialization
my @numbers = ();
my @srebmun = ();
my $numlen = 0;
my $sort_function;

# Reading Command-line Arguments
my ($choice,$inputfile) = @ARGV;

# Choose sorting function
SWITCH: {

    ($choice =~ /s/io) && do {
        $sort_function = \&sort_selection;
        last SWITCH;
    };

    ($choice =~ /i/io) && do {
        $sort_function = \&sort_insertion;
        last SWITCH;
    };

    ($choice =~ /q/io) && do {
        $sort_function = \&sort_quicksort_ite;
        last SWITCH;
    };

    ($choice =~ /r/io) && do {
        $sort_function = \&sort_quicksort_rec;
        last SWITCH;
    };

    die("ERROR!!! Please choose a sorting algorithm (s/i/q/r)\n");

}; # SWITCH

# Loading data
&read_numbers(\@numbers,$inputfile);
@srebmun = @numbers;
$numlen = scalar(@numbers);

# Sorting data
my $start_time = (new Benchmark);
&$sort_function(\@numbers,$numlen);
my $stop_time = (new Benchmark);

# Printing Output
print STDOUT "$inputfile","\t","$choice","\t",timestr( timediff($stop_time,$start_time) ),"\n";

exit(0);

# Functions code starts here...
sub read_numbers($$) {
    my ($ary, $file) = @_;

    @$ary = (); # Initialize Array

    open(FILE,"< $file") || die("ERROR !!! Cannot open $file\n");

    while (<FILE>) {

        next if /^\#/o;
        next if /^\s*$/o;

        chomp;
        push @$ary, $_;

    }; # while FILE

    close(FILE);

} # read_numbers

sub sort_selection($$) {
    # SELECTION SORT
    my ($array,$len) = @_;

    my $ilen = $len - 1; # Equal to $#array

    my $i; # The starting index of a minimum-finding scan
    my $j; # The running  index of a minimum-finding scan

    for ( $i = 0; $i < $ilen; $i++ ) {

        my $m = $i; # The index of the minimum element
        my $x = $array->[$m]; # The minimum value

        for ( $j = $i + 1; $j < $len; $j++ ) {

            ($m,$x) = ($j, $array->[$j]) # Update minimum
                if $array->[$j] < $x;

        };

        # swap if needed
        @$array[$m,$i] = @$array[$i,$m] unless $m == $i;

    };
} # sort_selection

sub sort_insertion($$) {
  # INSERTION SORT
    my ($array,$len) = @_;

    my $ilen = $len - 1; # Equal to $#array

    my $i; # The starting index of a minimum-finding scan
    my $j; # The running  index of a minimum-finding scan

    for ( $i = 0; $i < $ilen; $i++ ) {

        my $m = $i; # The index of the minimum element
        my $x = $array->[$m]; # The minimum value

        for ( $j = $i + 1; $j < $len; $j++ ) {

            ($m,$x) = ($j, $array->[$j]) # Update minimum
                if $array->[$j] < $x;

        };

        # The double splice simply moves the $m-th element
        # to be the the $i-th element.
        splice @$array, $i, 0,
                               splice @$array, $m, 1 if $m > $i;

    };
} # sort_insertion

sub sort_quicksort_ite($$) {
# QUICK SORT - ITERATIVE
    my ($array,$len) = @_;

    my $first = 0;
    my $last  = $len - 1; # Equal to $#array

    my @stack = ($first, $last);

    do {
        if ( $last > $first ) {

            my ($last_of_first, $first_of_last) =
                                &partition($array, $first, $last);

            # Larger first
            if ( $first_of_last - $first > $last - $last_of_first ) {

                push @stack, $first, $first_of_last;
                $first = $last_of_first;

            } else {

                push @stack, $last_of_first, $last;
                $last = $first_of_last;

            };

        } else {

            ($first, $last) = splice @stack, -2, 2; # double pop

        };
    } while ( scalar(@stack) > 0 );
} # sort_quicksort_ite

sub sort_quicksort_rec($$$) {
    # QUICK SORT - RECURSIVE
    my ($array,$len) = @_;

    my $first = 0;
    my $last  = $len - 1; # Equal to $#array

    # The recursive version is bad with BIG LISTs
    # because the function call stack gets REALLY DEEP...
    print STDERR "MAIN# F: $0 $array->[0]  L: $last $array->[$last] P: --\n";
    &quicksort_recursive($array,$first,$last);

} # sort_quicksort_rec

sub quicksort_recursive($$$) {

    my ($array,$first,$last) = @_;

    if ($last > $first) {

        my ($last_of_first, $first_of_last) = &partition($array, $first, $last);

        local $^W = 0; # Silence deep recursion warning
    print STDERR "MREL# F: $first $array->[$first]  L: $last $array->[$last] P: -- LoF: $first $last_of_first\n";
        &quicksort_recursive($array, $first,         $last_of_first);
    print STDERR "MRER# F: $first $array->[$first]  L: $last $array->[$last] P: -- FoL: $first_of_last $last\n";
        &quicksort_recursive($array, $first_of_last, $last         );

    };

} # quicksort_recursive

sub partition($$$) {

    my ($array,$first,$last) = @_;

    my $i = $first;
    my $j = $last - 1;
    my $pivot = $array->[$last];

    SCAN: {
      do {

        # $first <= $i <= $j <= $last - 1

        # Move $i as far as possible
        while ( $array->[$i] <= $pivot ) {
            $i++;
            last SCAN if $j < $i;
        };

        # Move $j as far as possible
        while ( $array->[$j] >= $pivot ) {
            $j--;
            last SCAN if $j < $i;
        };

        # $i and $j did not cross-over, so swap a low and a high value
        ($array->[$j], $array->[$i]) = ($array->[$i], $array->[$j]);

      } while ( --$j >= ++$i );
    }; # SCAN

    # Swap the pivot with the first larger element (if there is one)
    if ( $i < $last ) {
        ($array->[$last],$array->[$i]) = ($array->[$i], $array->[$last]);
        ++$i;
    };

    # Extend the middle partition as much as possible
    ++$i while $i <= $last  && $array->[$i] == $pivot;
    --$j while $j >= $first && $array->[$j] == $pivot;

    return ( $i, $j );

} # partition

### EOF ###
