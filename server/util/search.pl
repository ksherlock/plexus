# search.pl -- search interface
#
# $Id: search.pl,v 2.10 1994/06/23 05:44:13 sanders Exp $
#
# Tony Sanders <sanders@earth.com>, April 1993
#
# Example configuration (in local.conf):
#     map topdir search.pl &do_search($path, $query, "String")
# Where "topdir" is the directory to do searches in (e.g., "info", "data",
# this is a toplevel directory so no slashes are allowed) and "String"
# is used to to build the header to for the search results.
#

require 'find.pl';
require 'grep.pl';

sub do_search {
    local($_, $query, $title) = @_;
    local($anyfound, $key, *hits) = 0;
    do { &retrieve($_); return; } unless defined $query;
    local($pquery) = &printable($query);
    $query = join(" ", &splitquery($query));

    local($path) = $_;
    -f $path && do { # dirname
        @path = split("/", $path); pop @path; $path = join("/", @path); };

    &main'clear_timeout;
    &find($path);

    &MIME_header('ok', 'text/html');
    print "<HEAD>\n<TITLE>Search of ", $title, " (", $path;
    print "): ", $pquery, "</TITLE>\n";
    print "</HEAD>\n<BODY>\n<H1>", $title, " query results:</H1>\n";

    if ($anyfound) {
	print "<UL>\n";
	foreach $key (&sort_by_numeric_value(*hits)) {
	    &main'set_timeout();
	    ($hits, $title) = split(" ",$hits{$key},2);
	    printf('<LI>score: %05d, <A HREF="/%s">%s</A>%s',
		$hits, $key, $title, "\n");
	}
	print "</UL>\n";
    } else {
        print "Nothing found.\n";
    }
    print "</BODY>\n";
}

sub sort_by_numeric_value {
    local(*x) = @_;
    sort { $x{$b} <=> $x{$a}; } keys %x;
}

sub grok { $hits++; $anyfound++; 0; }			# return 1 for speed

sub wanted {
    local($/, $i, $pos, $title, $input, $hits) = "\n";
    return unless -f $_ && (!($dir =~ m,/.hidden$,));
    return unless ($_ ne "index.html") && ($_ ne "info.html");
    return unless &safeopen(GREP, $_);
    $pos = tell(GREP);
    $hits = 0;
    &grep('grok', 'i', $query, *GREP) || &error('bad_request', "Invalid regexp: $pquery");
    do { close(GREP); return; } unless $hits;
    if (/\.html$/) {		# Look for <TITLE>...</TITLE> in html files
	seek(GREP, $pos, 0);
	for ($i = 10; $i && ($input = <GREP>); $i--) {
	    last if ($title) = $input =~ m/^<title>(.*)<\/title>/i;
	}
    }
    close(GREP);
    $title = $title || $_;
    $hits{$name} = "$hits /$dir/$title";
}

1;
