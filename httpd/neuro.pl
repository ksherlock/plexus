
$map{"neuroprose"} = "gen_neuroprose";

sub gen_neuroprose {
    local($path) = @_;

    if($path =~ /\?/) {
	local($keywords) = $path;
	$keywords =~ s/^.*\?//;
	&siks("$www_dir/neuroprose/index.packed", "Neuroprose Archive",
	      "display_neuroprose", '<DL>', '</DL>', $keywords);
    } else {
	open(COVER, "$www_dir/neuroprose/cover.html") ||
	    &error("Cannot open cover page: $!");
	while(<COVER>) { print; alarm($time_out); }
	close(COVER);
    }
}


sub display_neuroprose {
    local($line) = @_;

    local($filename, $description, @authors) = split(/~/, $line);
    if(!defined $label) { $label = 1; }

    print '<DT>';
    print '<A NAME=', $label++, ' HREF="ftp://archive.cis.ohio-state.edu/pub/neuroprose/',  $filename, '">', $filename, '</A> ';

    foreach $author (@authors) {
	print " contact: ";
	local($user, $site) = ($author =~ /(\S+)@(\S+)/);
	print '<A NAME=', $label++, ' HREF="/finger/', $site, '/', $user, '/w">', $author,
	'</A> ';
    }
    print "\n";
    print '<DD>', $description, "\n";
}

1;
