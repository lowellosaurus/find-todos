find-todos
==========

find-todos is a utility for finding todos in text documents. I use it to generate an /etc/motd/ that contains outstanding tasks I need to complete, build the outline for TODO sections in README files, and verify my comments are accurate before committing changes.

In its simplest form, find-todos can be run as follows:

    $> perl find-todos.pl --file "my_script.js"

The above command will search my_script.js for lines that contain the text "TODO: " (and following lines if they are a continuation of the comment) and outputs those lines to stdout. For example:

    12. Change the format of this dictionary. Making it two-dimensional streamlines
    13. several functions later on.
    75. Return an error object instead of undefined on error.
    110. Improve user-facing message. Print "One result found" instead of "One 
    111. result(s) found".

Options
-------

find-todos has several options that change its default behavior.

**--token** changes the text the script searches for from "TODO: " to whatever you specify.

    $> perl find-todos.pl --file "my_script.js" --token "Remember! "

**--remove-linebreaks** consolidates todos that span more than one line into a single line. **--include-token** includes the text the script searches for in the output.

    $> perl find-todos.pl --file "my_script.js" --token "Remember! " --remove-linebreaks --include-token

Will output:

    12. Remember! Change the format of this dictionary. Making it two-dimensional streamlines several functions later on.
    75. Remember! Return an error object instead of undefined on error.
    110. Remember! Improve user-facing message. Print "One result found" instead of "One result(s) found".

**--format** changes the formatting of each line of output from the default "{LINE_NUM}. {LINE}" to whatever you specificy. All text within the string that follows --format will be preserved with the exception of {LINE_NUM} and {LINE} which will be replaced, respectively, by the line number and the text of the line (or several lines if --remove-linebreaks is set).

    $> perl find-todos.pl --file "my_script.js" --token "Remember! " --remove-linebreaks --include-token --format "- {LINE} ({LINE_NUM})"

Will output:

    - Remember! Change the format of this dictionary. Making it two-dimensional streamlines several functions later on. (12)
    - Remember! Return an error object instead of undefined on error. (75)
    - Remember! Improve user-facing message. Print "One result found" instead of "One result(s) found". (110)

Also, the script accepts input from stdin, not just the --file option. The following will produce the same output as the first example in this README.

    $> perl find-todos.pl < my_script.js

Why not grep?
-------------

I was motivated to write this script because I often write multi-line comments and grep does not make it easy to capture those todos.

Anything else?
--------------

Below is a little bash command I run to append todos for files in a directory to the README file (expanded to multiple lines for easier reading):

    for f in `ls $dir`;
        do echo "**$f**"; 
        perl find-todos.pl --file $f --format "- {LINE} ({LINE_NUM})" --remove-linebreaks; 
    done
    >> README.md

Todo
----

- Make script die if no $file option is provided and STDIN is empty (currently just hangs until it is killed). (28)
- Make a new todo if todos are on not separated by non-commented lines (currently includes second todo as part of the previous todo). The script will count the following two lines as one todo if they are on consecutive lines. (45)

    `// TODO: Rename the arguments for clarity.`

    `// TODO: Remove the final optional argument.`
