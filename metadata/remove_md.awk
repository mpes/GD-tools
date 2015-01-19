#!/usr/bin/awk -f 

# Author: 	Michal Pesicka, GoodData
# Desc: 	Tool using AWK and SED for removing unused metadata created in CloudConnect (C)GoodData
# Version:	0.2
# usage: 	remove_md.awk metadata.grf
# 		 	remove_md.awk metadata.grf -nobackup
# -----------------------------------------------------------------
BEGIN{
	tmpfilecreated = 0;
	for (i = 0; i < ARGC; i++) {
		if (  ARGC == 1 || ARGV[i] == "-h" || ARGV[2] == "--help") { # show help
				print "Removes obsolete metadata from graph. Use the filename of graph as a parameter.";
				print "Usage: remove_md.awk [ file ] | [ -n | -nobackup | -h | --help ]";
				print "Backups are created by default with _bckp suffix.";
				print "To change this behaviour use -n or --nobackup option. ";
				exit 0;
			}
	}
	skip = 0;
	input = ARGV[1];
	if( system( "[ -f " input " ] ") != 0 ) { 
		print "\033[22;31mError: File " input " does not exists.\033[0m" > "/dev/stderr";
		exit 1;
	}
	if (ARGC < 3) {
		system("cp '" input "' '" input "_bckp'");
	}
	else {
		if (ARGV[2] == "-n" || ARGV[2] == "--nobackup") { # do not create backup files
			print "No backup is created." > "/dev/stderr";
		}		
		else {
			print "\033[22;31mParametr is incorrect. Use -h for help. Quitting... \033[0m" > "/dev/stderr";
         	exit 1;
         }
	   	delete ARGV[2]; # to avoid treating params as another filename
	}
	metadata = "sed -ne 's/^\\<Edge.*metadata\\=\"\\([0-9a-zA-Z_]*\\)\".*\\>/\\1/p' -e 's/^\\<LookupTable .* metadata\\=\"\\([0-9a-zA-Z_]*\\)\".*\\>/\\1/p'  '" input "' "; 
	while (( (metadata) | getline) > 0){ 
		a[$0] = a[$0] + 1;
	}
	tmpfilecreated = 1; 
	print "Processing: '"input"'" > "/dev/stderr";
}
/^<Metadata\ *id=\"[0-9a-zA-Z_]*\".*>/{
	skip = 1;
	#edge = gensub(/^<Metadata\ *id=\"([0-9a-zA-Z_]+)\".*/, "\\1"); 
	#gensub() is not in all awk distributions so we must use this workaround
	edge = $2; 									#id is always on the second position
	sub(/^id\=\"/, "", edge);
	sub(/\"/, "", edge);
	sub(/\>/, "", edge);
	if (a[edge] > 0) 
		skip = 0
	else 
		print "removed:", edge > "/dev/stderr"; 
}
{	#print skip, $0;
	if (!skip) print $0 > "/tmp/remove_md.tmp"; # must write into temp as we cannot use read and write on the same file 
}
/<\/Metadata>/{
	skip = 0;
}
END {
	close(metadata)
	if (tmpfilecreated) system("mv -f /tmp/remove_md.tmp '" input "'"); # rewrite original file with the one just cleaned
}
