# bookmark.pl -- bookmark image decoder
#
# $Id: bookmark.pl,v 2.8 1994/06/23 05:42:57 sanders Exp $
#
# Tony Sanders <sanders@earth.com>, April 1993
#
# This is a cute little server that knows how to decode the bookmark.xbm
# image and translate a special URL into the location specified.
#
# The incoming URL looks something like this:
#      /bookmark/dir1_dir2_dir3/up_file:msg/back_file:msg/forw_file:msg
#
# The underscores get translated to slashes to recreate the path to the
# files.  up_file is UP, back_file is BACK, forw_file is FORWARD.  The msg's
# get used to build a menu if a query wan't sent along for the mouse
# position (_'s get translated to spaces in the msg).
#
# pretty tricky hey?
#

# Example:
# $map{'bookmark'} = '&do_bookmark($path, $query)';

package bookmark;

sub main'do_bookmark {
    local($_, $query) = @_;
    local($i);

    local(@path) = split("/", $_);
    $path[1] =~ s/_/\//g;			# _'s -> /'s

    # Make a menu for people without the new browser hack
    unless (defined $query) {
	&main'MIME_header('ok', 'text/html');
	print "<HEAD>\n<TITLE>Bookmark Index: /$path[1]</TITLE>\n</HEAD>\n";
	print "<BODY>\nYou can select one of:\n";
	print "<DL>\n";
	($file, $msg) = split(":",$path[2],2); $msg =~ s/_/ /g;
	print "<DT> Up\n";
	print "<DD> <A HREF=\"/$path[1]/$file\">$msg</A>\n";
	($file, $msg) = split(":",$path[3],2); $msg =~ s/_/ /g;
	print "<DT> Back\n";
	print "<DD> <A HREF=\"/$path[1]/$file\">$msg</A>\n";
	($file, $msg) = split(":",$path[4],2); $msg =~ s/_/ /g;
	print "<DT> Forward\n";
	print "<DD> <A HREF=\"/$path[1]/$file\">$msg</A>\n";
	print "</DL>\n</BODY>\n";
	return;
    }

    local($x, $y) = split(",", $query);		# XXX: x1,y1[+x2,y2]
    local($j) = 2;

    foreach $i (split(":", $bookmark{'regions'})) {
	($file) = split(":",$path[$j++]);
	&main'region("$bookmark{root}/$i.mask",
	    $bookmark{'width'}, $bookmark{'height'},
	    $x, $y) && return &main'retrieve("./$path[1]/$file");
    }

    # DEFAULT: Forward
    ($file) = split(":",$path[$j++]);
    &main'retrieve("./$path[1]/$file");
}

1;
