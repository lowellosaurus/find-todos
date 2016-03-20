#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

use Getopt::Long;

my $token      = 'TODO: ';
my $format     = '{LINE_NUM}. {LINE}';
my $file       = 0;     # default: false  
my $incl_token = 1;     # default: true
# TODO: Add unbreak-lines option.
# my $rem_breaks = 0;     # default: false

GetOptions(
    'token=s'       => \$token,
    'format=s'      => \$format,
    'file=s'        => \$file,
    'include-token' => \$incl_token,
) or die "Error in command line arguments\n";

my $todos = [];
my $todo_index = 0;

open(my $fh, "<", $file)
    or die "Cannot open file '$file': $!";

my $prev_pretext;
my $line_num = 0;
while (my $line = <$fh>) {
    $line_num++;
    chomp $line;

    # TODO: If we find the token again, make it a new todo.
    my ($pretext, $text) = $line =~ m/(^.*)$token(.*$)/i;
    $prev_pretext = $pretext
        if $pretext;

    # Skip this line unless $prev_pretext is defined. $prev_pretext not being
    # defined indicates that no todo was found on this line.
    next unless length($prev_pretext);

    ($text) = $line =~ m/^$prev_pretext(.*$)/i
        unless $text;

    # If no todo text is found, reset $prev_pretext and increment $todo_index.
    if (!$text) {
        $prev_pretext = q{};
        $todo_index++;
        next;
    }

    # Create hashref for this todo if it does not already exist.
    if (!$todos->[$todo_index]) {
        push @$todos, { lines => [], line_num => $line_num };
    }

    # Add the token text if --include-token and first line.
    $text = $token . $text
        if $incl_token && !scalar(@{$todos->[$todo_index]->{lines}});

    push @{$todos->[$todo_index]->{lines}}, $text;
}

foreach my $todo (@$todos) {
    my $line_no = $todo->{line_num};
    foreach my $todo_line (@{$todo->{lines}}) {
        my $line = "$format\n";
        $line =~ s/{LINE_NUM}/$line_no/g;
        $line =~ s/{LINE}/$todo_line/g;

        print $line;
        $line_no++;
    }
}
