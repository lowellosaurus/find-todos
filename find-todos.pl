#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

my $TODO_TEXT = "TODO:";

my $prev_pretext;
my $line_num = 0;
while (my $line = <>) {
    $line_num++;
    chomp $line;

    my ($pretext, $text) = $line =~ m/(^.*)($TODO_TEXT.*$)/i;
    $prev_pretext = $pretext
        if $pretext;

    # Skip this line unless $prev_pretext is defined.
    next unless length($prev_pretext);

    ($text) = $line =~ m/^$prev_pretext(.*$)/i
        unless $text;

    # Reset $prev_pretext unless we've captured todo text.
    $prev_pretext = q{}
        unless $text;

    # TODO: Allow different output options.
    print "$line_num. $text\n"
        if $text;
}
