#!/usr/bin/perl

require "sys/file.ph";

$www_dir = "/usr/local/www";
$man_dir = "$www_dir/man/" . shift;

chdir("$man_dir") || die "chdir: $!";

opendir(MANDIRS, ".") || die "opendir: $!";

foreach $directory (readdir(MANDIRS)) {
    next unless(-d "$man_dir/$directory");
    opendir(MANDIR, "$man_dir/$directory") || die "open $man_dir/$directory: $!";
     foreach $sect_dir (grep(/^man/,readdir(MANDIR))) {
	chdir("$man_dir/$directory/$sect_dir") || next;
	opendir(DIR, ".");
	foreach $entry (readdir(DIR)) {
	    next if(-d $entry);
	    ($name, $section) = ($entry =~ /^([\w\-]+)\.(\w+)/);
	    $section =~ tr/[a-z]/[A-Z]/;
	    open(ENTRY, $entry);
	    while(<ENTRY>) {
		last if(/^\.SH NAME/);
		if(/^\.so\s+(\S+)/ && $1 !~ /\.h$/) {
		    $newfile = $1;
		    close(ENTRY);
		    open(ENTRY, "../$newfile") || next;
		}
	    }
	    $_ = <ENTRY>; chop;
	    ($description = $_) =~ s/\\\-/\-/g;
	    $description =~ s/\\f\w//g;
	    close(ENTRY);
	    push(@index, "$name($section)~$directory/$sect_dir/$entry~$description")
	    } 
	closedir(DIR);
    }
    close(MANDIR);
}
close(MANDIRS);

open(INDEX, "> $man_dir/manindex") || die "cannot create index: $!";
flock(INDEX, &LOCK_EX);
foreach $entry (sort @index) {
    print INDEX $entry, "\n";
}
close(INDEX);

