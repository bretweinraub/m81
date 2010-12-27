#!/usr/bin/perl

$show_output = 0;
while (<>) {
    if (/^-+/) {
        $show_output = 1 ;
    }
    $show_output = 0 if /^\s*\d+\srows\sselected/;
    print $last_line if $show_output;
    $last_line = $_;
}
