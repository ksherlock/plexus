
$map{"internet"} = "gen_internet";

sub gen_internet {
    local($path) = @_;

    if($path =~ /\?/) {
	local($keywords) = $path;
	$keywords =~ s/^.*\?//;
	&siks("$www_dir/internet/INDEX1", "Hypertext Version of the Internet List",
	      "display_internet", '<DL>', '</DL>', $keywords);
    } elsif ($path eq "search") {
      	open(COVER, "$www_dir/internet/cover.html") ||
	    &error("Cannot open cover page: $!");
	while(<COVER>) { print; alarm($time_out); }
	close(COVER);
    } else {
	&send_file("internet/$path");
    }
}


sub display_internet {
    local($line) = @_;

    local($description, $filename) = split(/~/, $line);
#    if(!defined $label) { $label = 1; }

    print '<DT>';
    print '<A HREF="',  $filename, '">', $filename, '</A> ';

    print "\n";
    print '<DD>', $description, "\n";
}

1;
