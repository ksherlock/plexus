# wais.pl -- WAIS search interface
#
# $Id: wais.pl,v 2.3 1994/11/08 21:52:25 sanders Exp $
#
# Sample, still needs work to be really usable
#
# Tony Sanders <sanders@earth.com>, Nov 1993
#
# Example configuration (in local.conf):
#     map topdir wais.pl &do_wais($top, $path, $query, "database", "title")
#

$waisq = "/home/sanders/web/freeWAIS-0.202/bin/waisq";
$waisd = "/usr/local/wais";

sub do_wais {
    local($top, $path, $query, $src, $title) = @_;

    do { &main'retrieve($path); return; } unless defined $query;
    local(@query) = &main'splitquery($query);
    local($pquery) = &main'printable(join(" ", @query));
    $pquery =~ s/%20/ /g;
    
    open(WAISQ, "-|") || exec ($waisq, "-c", $waisd,
				"-f", "-", "-S", "$src.src", "-g", @query);
    &main'MIME_header('ok', 'text/html');
    print "<HEAD>\n<TITLE>Search of ", $title, "</TITLE>\n</HEAD>\n";
    print "<BODY>\n<H1>", $title, "</H1>\n";

    print "Index \`$src\' contains the following\n";
    print "items relevant to \`$pquery\':<P>\n";
    print "<DL>\n";

    local($hits, $score, $headline, $lines, $bytes, $type, $date);
    while (<WAISQ>) {
	/:score\s+(\d+)/ && ($score = $1);
	/:number-of-lines\s+(\d+)/ && ($lines = $1);
	/:number-of-bytes\s+(\d+)/ && ($bytes = $1);
	/:type "(.*)"/ && ($type = $1);
	/:headline "(.*)"/ && ($headline = $1);         # XXX
	/:date "(\d+)"/ && ($date = $1, $hits++, &docdone);
    }
    close(WAISQ);
    print "</DL>\n";

    if ($hits == 0) {
        print "Nothing found.\n";
    }
    print "</BODY>\n";
}

sub docdone {
    if ($headline =~ /Search produced no result/) {
        print $headline, "<P>\n<PRE>";
        &main'safeopen(WAISCAT, "$waisd/$src.cat") || die "$src.cat: $!";
        while (<WAISCAT>) {
            s#(Catalog for database:)\s+.*#$1 <A HREF="/$top/$src.src">$src.src</A>#;
            s#Headline:\s+(.*)#Headline: <A HREF="$1">$1</A>#;
            print;
	}
	close(WAISCAT);
        print "\n</PRE>\n";
    } else {
	print "<DT><A HREF=\"$headline\">$headline</A>\n";
	print "<DD>Score: $score, Lines: $lines, Bytes: $bytes\n";
    }
    $score = $headline = $lines = $bytes = $type = $date = '';
}

1;
