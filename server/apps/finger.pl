# finger.pl -- WWW to finger gateway (with faces support)
#
# $Id: finger.pl,v 2.10 1994/06/25 06:45:11 sanders Exp $
#
# Marc VanHeyningen  March 1993
#
# This is a simple gateway into finger space from HTTP.
# It is intended to be fast and not to laden the HTTP server, which is
# why it uses sockets within perl rather than simply execing finger.

package finger;

($name, $aliases, $finger_port) = getservbyname("finger","tcp");
$finger_port = 79 unless $finger_port;
($name, $aliases, $proto) = getprotobyname("tcp");
($name, $aliases, $type, $len, $thisaddr) = gethostbyname($main'hostname);

sub main'do_finger {
    local($path, $query, $cover) = @_;
    local($user, $site, $fqdn, $aliases, $type, $len, $thataddr);
    local($face, $bogus);
    @faces_path = split(/\:/, $main'plexus{'faces_path'});

    if($query =~ /^([;\w\-\.]+)@([\w\-\.]+)$/) {
	$user = $1;
	$site = $2;
    } elsif($path eq "gateway") {
	&main'retrieve($cover);
	return;
    } elsif($path =~ m:^([\w\-\.]+)/([;\w\-\.]+)$:) {
	$site = $1;
	$user = $2;
    } else {
	&main'error('bad_request', "Invalid finger path $path");
    }

    ($fqdn, $aliases, $type, $len, $thataddr) = gethostbyname($site);
    if($fqdn eq "") {
	$fqdn = $site;
	$bogus = 1;
    }

    &main'MIME_header('ok', 'text/html');
    print "<HEAD>\n<TITLE>Finger Gateway</TITLE>\n</HEAD>\n";
    print "</BODY>\n<H1>\n";
    if(($face = &get_face_path($user, $fqdn)) ne "") {
	print '<IMG SRC="/', $face, '">', "\n";
    }
    print "$user@$fqdn";
    foreach $face (&get_face_path("unknown", $fqdn)) {
	print '<IMG SRC="/', $face, '">', "\n";
    }
    print "</H1>\n<XMP>\n";
    if($bogus) {
	print "gethostbyname: cannot look up $fqdn\n";
	return;
    }

    # get finger text
    &main'set_timeout();
    $this = pack($main'sockaddr, &main'AF_INET, 0, $thisaddr);
    $that = pack($main'sockaddr, &main'AF_INET, $finger_port, $thataddr);
    socket(FS, &main'AF_INET, &main'SOCK_STREAM, $proto) ||
        &main'error('bad_request', "socket: $!");
    bind(FS, $this) || &main'error('bad_request', "bind: $!");
    connect(FS, $that) || &main'error('bad_request', "connect: $!");
    select((select(FS), $| = 1)[0]);
    print FS "$user\r\n";
    while(<FS>) { print; }
    close(FS);
    print "</XMP>\n";
    print "</BODY>\n";
}


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
