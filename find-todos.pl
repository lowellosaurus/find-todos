#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

# TODO: Possible flags:
# --todo-text "TODO: "
# --include-todo-text
# --output-format "* {LINE_NUM}: {TODO}"
# --force-single-line

my $TODO_TEXT = "TODO:";

my $todos = [];
my $todo_index = 0;

my $prev_pretext;
my $line_num = 0;
while (my $line = <>) {
    $line_num++;
    chomp $line;

    my ($pretext, $text) = $line =~ m/(^.*)($TODO_TEXT.*$)/i;
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
    push @{$todos->[$todo_index]->{lines}}, $text;
}

foreach my $todo (@$todos) {
    $line_num = $todo->{line_num};
    foreach my $todo_line (@{$todo->{lines}}) {
        print $line_num++ . ". $todo_line\n";
    }
}