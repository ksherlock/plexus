# fortune.pl -- fortune gateway
#
# $Id: fortune.pl,v 2.6 1994/06/23 05:42:50 sanders Exp $
#
# Tony Sanders <sanders@earth.com>, April 1993

package fortune;

sub main'do_fortune {
    local($rest, $query) = @_;
    &main'MIME_header('ok', 'text/html');
    local($_) = $rest || join("", &main'splitquery($query));
    undef $1; m#(-[$opts]*)#;
    $fortune = "$cmd $1";

    print "<HEAD>\n<ISINDEX>\n";
    print "<TITLE>Todays Fortune</TITLE>\n</HEAD>\n";
    print "<BODY>\n<H1>Todays Fortune</H1>\n";
    print "<PRE>\n";
    system($fortune);
    print "</PRE>\n</BODY>\n";
}

1;
