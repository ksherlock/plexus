$map{"LCD"} = "gen_LCD";

sub gen_LCD {
    local($path) = @_;

    if($path =~ /\?/) {
	local($keywords) = $path;
	$keywords =~ s/^.*\?//;
	&siks("elisp/LCD/index", "Emacs Lisp Archive Index",
	      "display_LCD", '<DL>', '</DL>', $keywords, 100);
    } else {
	open(COVER, "elisp/LCD/cover.html") ||
	    &error("Cannot open cover page: $!");
	while(<COVER>) { print; alarm($time_out); }
	close(COVER);
    }
}

sub display_LCD {
    local($line) = @_;

    local($name, $auth, $contact, $description, $date,$version, $file) =
	split(/\|/, $line);
    return unless $file;
    local($path) = ($file);
    $path =~ s/~/\/pub\/gnu\/emacs\/elisp-archive/;
    $file =~ s:.*/::g;
    print '<DT>', "<A HREF=\"ftp://archive.cis.ohio-state.edu$path\">$file", '</A>'," $auth, $contact\n";
    print '<DD>', $description, "\n";
    alarm($time_out);
}

1;
