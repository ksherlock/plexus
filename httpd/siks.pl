

sub siks {
    local($index_fn, $title, $display_line, $prefix, $suffix, $keywords,
	  $limit) = @_;
    local(@hits,$hits,$i,$searcher,@keywords);

    local($count) = (0);
    local($mink) = (1);

    foreach $keyword (split(/\+/, $keywords)) {
	if($keyword =~ /^max\=(\d+)$/i) {
	    $limit = $1;
	} elsif($keyword =~ /^mink\=(\d+)$/i) {
	    $mink = $1;
	} elsif($keyword =~ /^[\w\-]+$/) {
	    push(@keywords, $keyword);
	}
    }
    $searcher = 'while(<INDEX>) { $hits = 0; ' . "\n";
    $searcher .= 'study; ' if($#keywords > 25);
    foreach $keyword (@keywords) { 
	$searcher .= '$hits++ if(/\b' . $keyword . '/i); ' . "\n"
    }
    $searcher .= '$hits[$hits] .= $_; $count++ if($hits >= ' . $mink. ') }', "\n";

    open(INDEX, $index_fn) || &error("cannot open $index_fn: $!");
    flock(INDEX, &LOCK_SH);
    eval $searcher;
    close(INDEX);

    print '<TITLE>Simple Index Keyword Search of ', $title, '</TITLE>', "\n";
    print '<H1>SIKS of ', $title, '</H1>', "\n";
    print '<H2>Keywords: ', join(" ",@keywords), '</H2>', "\n";
    print '<H2>Entries matching at least ', $mink, ' keyword';
    print "s" unless $mink == 1;
    print ' found: ', $count;
    print '; displayed: ', $limit if($limit < $count);
    print '</H2>', "\n";

    alarm($time_out);
  KEYWORDS:
    for($i = $#hits; $i >= $mink; $i--) {
	if($hits[$i]) {
	    if($i >= $mink) {
		print '<H3>', "Matching $i keyword";
		print "s" if($i != 1);
		print ':</H3>', "\n";
	    }
	    print $prefix;
	    alarm($time_out);
	    foreach $entry (split("\n", $hits[$i])) {
		do $display_line($entry,@keywords);
		alarm($time_out);
		if($limit ne "") {
		    $limit--;
		    last KEYWORDS unless $limit > 0;
		}
	    }
	    print $suffix;
	    alarm($time_out);
	}
    }
    print '<H3>', "Nothing found.", '</H3>' if($#hits < 1 && $keywords ne "");
    print "\n";
    alarm($time_out);
}

1;
