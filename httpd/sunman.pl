
$map{"man"} = "man_handler";
$arch_name{'sun'} = "SunOS";
$arch_name{'solaris'} = "Solaris";

sub man_handler {
    local($path) = @_;
    
    ($arch, $arch_path) = $path =~ m:^(\w+)/(.*)$:;
    $arch_man_dir = "$www_dir/man/$arch";

    if($arch_path =~ /^search/) {
	if($arch_path =~ /^search\?(.*)$/) {
	    &siks("$arch_man_dir/manindex", "$arch_name{$arch} Manual Pages", 
		  "display_man_entry", '<DL>', '</DL>', $1);
	} else {
	    &send_file("$arch_man_dir/cover.html");
	}
    } elsif($arch_path =~ /^lookup/) {
	if($arch_path =~ /^lookup\?(.*)$/) {
	    &arch_whatis_lookup($1);
	} else {
	    &send_file("$arch_man_dir/lookup.html");
	}
    } else {
	&fetch_man($arch_path);
    }
}

sub arch_whatis_lookup {
    local($keyword) = @_;
    local($searcher, @hits, $command, $filename, $description);

    local($target) = $keyword =~ /^([\w\-\.]+\(\w|[\w\-\.]+)/;
    $target .= "(" unless($target =~ /\(/);
    $target =~ s/\(/\\\(/;
    open(INDEX, "$arch_man_dir/manindex") || &error("open: $!");
    flock(INDEX, &LOCK_SH);
    while(<INDEX>) {
	push(@hits, $_)	if(/^$target/o);
    }
    close(INDEX);
    if(@hits) {
	if($#hits == $[) {
	    ($command, $filename, $description) = split(/~/, $hits[$[]);
	    &fetch_man($filename);
	} else {
	    print '<DL>';
	    foreach $entry (@hits) {
		&display_man_entry($entry);
	    }
	    print '</DL>', "\n";
	}
    } else {
	print "No matches\n";
    }
}
    

sub fetch_man {
    local($file) = @_;
    local($dir, $manfile) = $file =~ m:^([\w\-]+)/(.+)$:;
    chdir("$arch_man_dir/$dir");

    open(MAN, "nroff -man $manfile |");
    print NS '<PRE>'; alarm($time_out);
    local(%hits);

    while(<MAN>) {
	%hits = ();
	s/_[\b]//g;
	s,\&,\&\#38\;,g;
	s,\<,\&\#60\;,g;
	s,\>,\&\#62\;,g;
	if(m/\#include \&\#60\;([\S]+\.h)\&\#62\;/) {
	    print STDERR "Got match in line $_";
	   $match = $1;
	   ($regexp = $match) =~ s/\./\\\./;
	   s,$regexp,\<A HREF=\"/$arch-include/$match\"\>$match\</A\>,;
       }
	if(/^\s/) {
	    foreach $match (/([\w\-\.]+\s*\([A-Z0-9]+\))/g) {
		($link = $match) =~ s/[\s]+//g;
		($regexp = $match) =~ s/\(/\\\(/g;
		$regexp =~ s/\)/\\\)/g;
		next if(defined $hits{$regexp});
		$hits{$regexp} = 1;
		s,$regexp,\<A HREF=\"/man/$arch/lookup\?$link\"\>$match\</A\>,g;
	    } 
	    
	}
	print NS; alarm($time_out);
    }
    close(MAN);
    print NS '</PRE>', "\n";
}

sub display_man_entry {
    local($line) = @_;

    local($command, $filename, $description) = split(/~/, $line);
    local($directory) = $filename =~ m:^(\w+)/:;
    print '<DT>';
    print '<A HREF="/man/', $arch, '/' , $filename, '">',
    $command, '</A>', " ($directory)\n";
    print '<DD>', $description, "\n";
}

1;
