require "sys/socket.h";

$map{"wx"} = "gen_weather";

$sockaddr = "S n a4 x8";

($wx_fqdn, $wx_aliases, $wx_type, $wx_len, $wx_thataddr) = 
    gethostbyname("downwind.sprl.umich.edu");

sub gen_weather {
    local($path) = @_;
    local($user, $site, $sockaddr, $fqdn, $aliases, $type, $len, $thataddr);

    local($city) = ($path =~ m:^us-city/(\w+)$:);





    print '<TITLE>Weather Gateway</TITLE><H1>'; alarm($time_out);
    print 'Weather for $city'
    print '</H1><XMP>', "\n";

    $this = pack($sockaddr, &AF_INET, 0, $thisaddr);
    $that = pack($sockaddr, &AF_INET, 3000, $thataddr);

    socket(FS, &AF_INET, &SOCK_STREAM, $proto) || &error("socket: $!");

    bind(FS, $this) || &error("bind: $!");

    connect(FS, $that) || &error("connect: $!");

    select(FS); $| = 1; alarm($time_out);

    print "";

    select(NS); alarm($time_out);

    alarm($time_out);
			     
    while(<FS>) { print; alarm($time_out); }

    close(FS);
    print '</XMP>', "\n"; alarm($time_out);
}


$faces_path = "faces/local:faces/xface:faces/facedir:faces/facesaver:faces/logos";
@faces_path = split(/\:/, $faces_path);

sub get_face_path {
    local($user, $fqdn) = @_;
    local(@hits, $filename);
    $user =~ tr/[A-Z]/[a-z]/;
    $fqdn =~ tr/[A-Z]/[a-z]/;

  CHECK_DIR:
    foreach $face_dir (@faces_path) {
	local(@fqdn) = reverse(split(/\./, $fqdn));

	while($#fqdn >= $[) {
	    $filename = $face_dir . "/" . join("/",@fqdn) . "/" .
		$user . "/face.xbm";
	    if(-e $filename) {
		last CHECK_DIR unless wantarray;
		push(@hits, $filename);
	    }
	    pop @fqdn;
	}
	last CHECK_DIR if(@hits);
	$filename = "";
    }
    return wantarray ? @hits : $filename;
}

1;
