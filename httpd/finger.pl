
# Marc VanHeyningen  March 1993

# This is a simple gateway into finger space from HTTP.
# It is intended to be fast and not to laden the HTTP server, which is
# why it uses sockets within perl rather than simply execing finger.

$map{"finger"} = "do_finger";

require "sys/socket.h";

chop($hostname = `hostname`);	# do this just once for efficiency
($name, $aliases, $finger_port) = getservbyname("finger","tcp");
($name, $aliases, $proto) = getprotobyname("tcp");
($name, $aliases, $type, $len, $thisaddr) = gethostbyname($hostname);


sub do_finger {
    local($path) = @_;
    local($user, $site, $sockaddr, $fqdn, $aliases, $type, $len, $thataddr);
    local($face, $bogus);

    if($path eq "gateway") {
	&send_file("finger-cover.html");
	return;
    } elsif($path =~ /^gateway\?([\w\-\.]*)@([\w\-\.]+)$/) {
	$user = $1;
	$site = $2;
    } else {
	($site, $user, $w) = split(m:/:, $path);
    }

    $sockaddr = "S n a4 x8";

    if($site =~ /^[0-9\.]+$/) {
	$numericaddr = 1;
	($fqdn, $aliases, $type, $len) = 
	    gethostbyaddr($thataddr = pack("C4",split(/\./,$site)),&AF_INET);
    } else {
	($fqdn, $aliases, $type, $len, $thataddr) = gethostbyname($site);
    }
    unless($fqdn) {
	$fqdn = $site;
	$bogus = 1 unless $numericaddr;
    }
    
    &error("Sorry, that query is restricted")
	if($fqdn =~ /\.indiana\.edu$/i && $user =~ /\.(clients|free|users)$/i);

    print '<TITLE>Finger Gateway</TITLE><H1>'; alarm($time_out);
    if(($face = &get_face_path($user, $fqdn)) ne "") {
	print NS '<IMG SRC="/', $face, '">'; alarm($time_out);
    }
    print "$user@$fqdn";
    foreach $face (&get_face_path("unknown", $fqdn)) {
	print '<IMG SRC="/', $face, '">'; alarm($time_out);
    }
    print '</H1> <XMP>', "\n";
    if($bogus) {
	print "cannot look up $site\n";
	return
	}


    $this = pack($sockaddr, &AF_INET, 0, $thisaddr);
    $that = pack($sockaddr, &AF_INET, $finger_port, $thataddr);

    socket(FS, &AF_INET, &SOCK_STREAM, $proto) || &error("socket: $!");

    bind(FS, $this) || &error("bind: $!");

    connect(FS, $that) || &error("connect: $!");

    select(FS); $| = 1; alarm($time_out);

    print "/W " if $w;
    print "$user\r\n";

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
