# neuro.pl -- the neuroprose gateway
#
# $Id: neuro.pl,v 2.3 1993/08/29 01:24:06 sanders Exp $
#
# Examples:
# $map{'neuroprose'} = '&gen_neuroprose($query)';

package neuroprose;

sub main'gen_neuroprose {
    local($keywords) = @_;

    if($keywords) {
	&main'siks("$main'http_home/neuroprose/index.packed",
	      "Neuroprose Archive", "display_neuroprose",
	      '<DL>', '</DL>', $keywords);
    } else {
	&main'raw_file("$main'http_home/neuroprose/cover.html");
    }
}

sub display_neuroprose {
    local($line) = @_;

    local($filename, $description, @authors) = split(/~/, $line);
    if(!defined $label) { $label = 1; }

    print '<DT>';
    print '<A NAME=', $label++, ' HREF="file://archive.cis.ohio-state.edu/pub/neuroprose/',  $filename, '">', $filename, '</A> ';

    foreach $author (@authors) {
	print " contact: ";
	local($user, $site) = ($author =~ /(\S+)@(\S+)/);
	print '<A NAME=', $label++, ' HREF="/finger/', $site, '/', $user, '">', $author,
	'</A> ';
    }
    print "\n";
    print '<DD>', $description, "\n";
}

1;
