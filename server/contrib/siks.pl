# siks.pl -- Simple Index Keyword Search
#
# $Id: siks.pl,v 2.6 1993/09/03 21:25:27 sanders Exp $
#

sub siks {
    local($index_fn, $title, $display_line, $prefix, $suffix, $keywords) = @_;
   
    local(@hits,$hits,$i,$searcher);

    local(@keywords) = split(/\+/, $keywords);

    open(INDEX, $index_fn) || &error('bad_request',
        "cannot open $index_fn: $!");
    &seize(INDEX, &LOCK_SH);
    $searcher = 'while(<INDEX>) { $hits = 0; ' . "\n";
    $searcher .= 'study; ' if($#keywords > 5);
    foreach $keyword (@keywords) { 
	$searcher .= '$hits++ if(/' . $keyword . '/i); ' . "\n"
	    if($keyword =~ /[\w\-]+/);
    }
    $searcher .= '$hits[$hits] .= $_ ';
    $searcher .= 'if($hits > 0)' if($keywords);
    $searcher .= '; }' . "\n";
    eval $searcher;
    close(INDEX);

    print '<TITLE>Simple Index Keyword Search of ', $title, '</TITLE>', "\n";
    print '<H1>SIKS of ', $title, '</H1>', "\n";
    print '<H2>Keywords: ', join(" ",@keywords), '</H2>', "\n";

    &main'set_timeout();
    for($i = $#hits; $i >= 0; $i--) {
	if($hits[$i] ne "") {
	    if($i > 0) {
		print '<H3>', "Matching $i keyword";
		print "s" if($i > 1);
		print ':</H3>', "\n";
	    }
	    print $prefix;
	    &main'set_timeout();
	    foreach $entry (split("\n", $hits[$i])) {
		do $display_line($entry);
		&main'set_timeout();
	    }
	    print $suffix;
	    &main'set_timeout();
	}
    }
    print '<H3>', "Nothing found.", '</H3>' if($#hits < 1 && $keywords ne "");
    print "\n";
    &main'set_timeout();
}

1;
