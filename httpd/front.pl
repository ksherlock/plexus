# front.pl, the front-end for handling commands from httpd.pl
# Marc VanHeyningen  March 1993
# This parses the commands and processes them


# file extensions that don't need a <PLAINTEXT> marker
# These are case sensitive, so watch it
$ext{"html"} = 1;
$ext{"mime"} = 1;
$ext{"jpg"} = 1;
$ext{"gif"} = 1;
$ext{"xbm"} = 1;
$ext{"xwd"} = 1;
$ext{"mpg"} = 1;
$ext{"au"} = 1;
$ext{"dvi"} = 1;
$ext{"ps"} = 1;
$ext{"Z"} = 1;
$ext{"z"} = 1;
$ext{"tar"} = 1;

sub process_input {
    if(/^restart/i) {		# quick hack; make this more elegant someday
	print NS "Restarting server...\n";
	close(NS);
	kill 30, getppid;
	exit;
    }

    ($path) = /^get\s+(\S+)\s+/i;

    &error("No backward directory references permitted in $path")
	if($path =~ /\.\./);

    &error("No special characters permitted in $path")
	if($path =~ /[\<\|\>\`]/);


    $path = "home-page.html" if($path eq "/");
    $path =~ s:^$www_dir::o;
    $path =~ s:^/*::;

    ($top_dir, $rest_path) = $path =~ m:^(\w+)/(.*)$:;

    if(defined $map{$top_dir}) {
	local($bogus) = $map{$top_dir};
	do $bogus($rest_path);
    }
    else {
	&send_file($path);
    }
}


sub send_file {
    local($file) = @_;
    local($extension) = $file =~ /\.(\w+)$/;

    if(-d $file) { &error("$file is a directory"); } # Added later, important
    open(FD, $file) || &error("Cannot open $file: $!");
    flock(FD, &LOCK_SH);
    print NS '<PLAINTEXT>' unless(defined $ext{$extension});
    while(<FD>) { print NS; alarm($time_out); }
    close(FD);
}

1;
