#!/usr/bin/awk -f

# Author: 	Michal Pesicka, GoodData
# Desc: 	Tool using AWK and SED for removing unused metadata created in CloudConnect (C)GoodData
# usage: 	remove_md.awk metadata.grf
# 		 	remove_md.awk metadata.grf -nobackup
# -----------------------------------------------------------------
BEGIN{
	skip = 0;
	input = ARGV[1];
	for (i = 0; i < ARGC; i++)
		if (  ARGC == 1 || ARGV[i] == "-h" || ARGV[2] == "--help") { # show help
				print "Removes obsolete metadata from graph. Use the filename of graph as a parameter.";
				print "Backups are created by default with _bckp suffix.";
				print "To change this behaviour use -n or --nobackup option. ";
				exit 0;
			}
	if (ARGC < 3) {
		system("cp '" input "' '" input "_bckp'");
		#output;
	}
	else {
		if (ARGV[2] == "-n" || ARGV[2] == "--nobackup") { # do not create backup files
			#output = input;
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
}
/^<Metadata\ *id=\"[0-9a-zA-Z_]*\".*>/{
	skip = 1;
	#edge = gensub(/^<Metadata\ *id=\"([0-9a-zA-Z_]+)\".*/, "\\1"); 
	#gensub() is not in all awk distributions so we must use this workaround
	edge = $2; #id is on the second position
	sub(/^id\=\"/, "", edge);
	sub(/\"/, "", edge);
	sub(/\>/, "", edge);
	if (a[edge] > 0) 
		skip = 0
	else 
		print "removed:", edge > "/dev/stderr"; 
}
{
	if (!skip) print $0 > input;
}
/<\/Metadata>/{
	skip = 0;
}
END {
	close(metadata)
}
