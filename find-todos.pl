#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

use Getopt::Long;

my $token      = 'TODO: ';
my $format     = '{LINE_NUM}. {LINE}';
my $file       = '';    # default: false  
my $incl_token = 0;     # default: false
my $rem_breaks = 0;     # default: false

GetOptions(
    'token=s'       => \$token,
    'format=s'      => \$format,
    'file=s'        => \$file,
    'include-token' => \$incl_token,
    'remove-linebreaks' => \$rem_breaks,
) or die "Error in command line arguments\n";

my $todos = getTodosFromFile($file, $token, $incl_token);
printTodos($todos, $format);

sub getTodosFromFile {
    my ($filename, $token_text, $include_token) = @_;

    my $todos = [];
    my $todo_index = 0;

    my $prev_pretext;
    my $line_num = 0;

    open(my $fh, "<", $filename)
        or die "Cannot open file '$filename': $!";

    while (my $line = <$fh>) {
        $line_num++;
        chomp $line;

        # TODO: If we find the token again, make it a new todo.
        my ($pretext, $text) = $line =~ m/(^.*)$token_text(.*$)/i;
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
        $text = $token_text . $text
            if $include_token && !scalar(@{$todos->[$todo_index]->{lines}});

        if ($rem_breaks) {
            $todos->[$todo_index]->{lines}[0] .= " $text";
        }
        else {
            push @{$todos->[$todo_index]->{lines}}, $text;
        }        
    }

    return $todos;
}

sub printTodos {
    my ($todos, $template) = @_;

    foreach my $todo (@$todos) {
        my $line_no = $todo->{line_num};
        foreach my $todo_line (@{$todo->{lines}}) {
            my $line = "$template\n";
            $line =~ s/{LINE_NUM}/$line_no/g;
            $line =~ s/{LINE}/$todo_line/g;

            print $line;
            $line_no++;
        }
    }   
}
