# sunman.pl -- the sun man page handler
#
# $Id: sunman.pl,v 2.5 1993/09/03 21:25:29 sanders Exp $
#
# Examples:
# $map{'man'} = '&man_handler($rest, $query)';

package sunman;

$arch_name{'sun'} = 'SunOS';
$arch_name{'solaris'} = 'Solaris';

sub main'man_handler {
    local($path, $query) = @_;

    $path .= "?$query" if defined $query;
    
    ($arch, $arch_path) = $path =~ m:^(\w+)/(.*)$:;
    $arch_man_dir = "$main'http_home/man/$arch";

    if($arch_path =~ /^search/) {
	if($arch_path =~ /^search\?(.*)$/) {
	    &main'siks("$arch_man_dir/manindex", "$arch_name{$arch} Manual Pages", 
		  "display_man_entry", '<DL>', '</DL>', $1);
	} else {
	    &main'retrieve("$arch_man_dir/cover.html");
	}
    } elsif($arch_path =~ /^lookup/) {
	if($arch_path =~ /^lookup\?(.*)$/) {
	    &arch_whatis_lookup($1);
	} else {
	    &main'retrieve("$arch_man_dir/lookup.html");
	}
    } else {
	&fetch_man($arch_path);
    }
}

sub arch_whatis_lookup {
    local($keyword) = @_;
    local($searcher, @hits, $command, $filename, $description);

    local($target) = $keyword =~ /^([\w\-]+\(\w|[\w\-]+)/;
    $target .= "(" unless($target =~ /\(/);
    $target =~ s/\(/\\\(/;
    open(INDEX, "$arch_man_dir/manindex") ||
        &main'error('not_implemented', "open: $!");
    &seize(INDEX, &main'LOCK_SH);
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

    open(MAN, "nroff -man < $manfile |");
    print '<PRE>'; &main'set_timeout();
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
	print; &main'set_timeout();
    }
    close(MAN);
    print '</PRE>', "\n";
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
