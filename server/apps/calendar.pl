# calendar.pl -- calendar gateway
#
# $Id: calendar.pl,v 2.8 1994/06/23 05:42:48 sanders Exp $
#
# Tony Sanders <sanders@earth.com>, April 1993

package calendar;

sub main'do_calendar {
    local($rest, $query) = @_;
    &main'MIME_header('ok', 'text/html');
    local($_) = join("/", &main'splitquery($rest . "+" . $query));
    undef $1; undef $2; m#(\d+)[^\d]+(\d+)# || m#(\d+)#;
    $cal = "$cmd $1 $2";

    print "<HEAD>\n<ISINDEX>\n<TITLE>Calendar</TITLE>\n</HEAD>\n";
    print "<BODY>\n<H1>Calendar $1 $2</H1>\n";
    print "Use the Search Keyword to specify <CODE>year</CODE> or\n";
    print "<CODE>month/year</CODE>.  Try <CODE>9/1752</CODE> to see the\n";
    print "Gregorian Reformation. <P>\n";
    print "<PRE>\n", `$cal`, "</PRE>\n</BODY>\n";
}

1;
