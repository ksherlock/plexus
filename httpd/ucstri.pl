
$map{"cstr"} = "gen_ucstri";

sub gen_ucstri {
    local($path) = @_;

    if($path =~ /\?/) {
	local($keywords) = $path;
	$keywords =~ s/^.*\?//;
	&siks("cstr/index", "Unified Computer Science TR Index",
	      "display_ucstri", '<DL>', '</DL>', $keywords, 50);
    } else {
	open(COVER, "cstr/cover.html") ||
	    &error("Cannot open cover page: $!");
	while(<COVER>) { print; alarm($time_out); }
	close(COVER);
    }
}

sub display_ucstri {
    local($line,@keywords) = @_;
    local($i);

    @line = split(/[\<\>]/, $line);
    $line = "";
    $tag = 0;
    for($i = $[; $i <= $#line; $i++) {
	unless($tag) {
	    foreach $keyword (@keywords) {
		@line[$i] =~ s/\b($keyword)/<STRONG>$1<\/STRONG>/gi;
	    } 
	}
	$line .= '<' if $tag;
	$line .= @line[$i];
	$line .= '>' if $tag;
	$tag = ! $tag;
    }
    local($dt, $dd) = split(/~/, $line);
    print '<DT>', $dt;
    print '<DD>', $dd, "\n";
    alarm($time_out);
}

1;
