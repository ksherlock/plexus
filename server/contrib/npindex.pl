#!/usr/bin/perl
# $Id: npindex.pl,v 2.2 1993/08/29 01:24:08 sanders Exp $

require "sys/file.ph";

chdir("/usr/local/www/neuroprose");
system "/usr/local/bin/ncftp", "archive.cis.ohio-state.edu:/pub/neuroprose/INDEX";

open(INDEX,"INDEX") || die "Cannot open index: $!";

while(<INDEX>) {
    chop;
    if(/^\s*$/) {
	$index{$filename} = join("~", ($cur_line, @authors));
	$cur_line = "";
    } elsif($cur_line eq "") {
	$cur_line = " ";
	@authors = ();
	foreach $entry (split(m:[\s/]+:,$_)) {
	    if($entry =~ /@/) { 
		push(@authors, $entry);
	    } else {
		$filename = $entry;
	    }
	}
    } else {
	$cur_line .= $_ . " ";
    }
}
close(INDEX);
$index{$filename} = join("~", ($cur_line, @authors));

system "echo 'ls -1t >ls' | /usr/local/bin/ncftp archive.cis.ohio-state.edu:/pub/neuroprose";

open(LS,"ls") || die "cannot open ls: $!";
open(HT,">index.packed") || die "cannot open index.packed for writing: $!";
&seize(HT, &LOCK_EX);
select(HT);

while(<LS>) {
    chop;
    print unless(/~$/);
    if(defined $index{$_}) {
	print "~", $index{$_};
    }
    print "\n";
}
close(LS);
close(HT);
