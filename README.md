# GD-tools
Repo for GD development

Remove metadata tool
====================
Removes obsolete metadata from graphs. Use the filename of graph as a parameter.

Usage
-----
remove_md.awk [ graph file ] | [ -n | -nobackup | -h | --help ]

Backups are created by default with _bckp suffix.
To change this behaviour use -n or --nobackup option.

Make it first executable "chmod +x remove_md.awk" and place it to the folder you like. Ideally already present in your PATH variable.

Use with caution! Report bugs.

Examples
--------
./remove_md.awk /Users/test-project/graph/metadata.grf 
./remove_md.awk /Users/test-project/graph/metadata.grf -nobackup
./remove_md.awk /Users/test-project/graph/metadata.grf 2> log.txt
Notes
-----
Uses /tmp/remove_md.tmp as a temporary file.
Original file gets rewritten. I found it more common usecase than printing it on standard output.
Logs are printed on standard error output.

