#
# libplex -- Library of useful routines for Plexus
#
# $Id: libplex.pl,v 2.3 1994/11/08 08:43:16 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, June 1994
#
# These were simply extracted from `plexus' proper and collected
# into a single place so they are easier to find and use.
#
# NOTE: Form processing routines can be found in util/forms.pl

#
# Make an arbitrary string printable in HTML
# usage: $string = &main'printable($data);
#
sub printable {
    local(@_, $_) = @_;
    foreach (@_) { s/([^0-9A-Za-z])/sprintf('%%%02x',ord($1))/eg; }
    join("/",@_);
}

#
# Format plaintext into HTML (escape < & >, etc).
# Handles _^H_ (into bold and italics)
# usage: $string = &main'plaintext($data);
# WARNING: not binary safe (messes with \376 and \377)
#
sub plaintext {
    local($_) = @_;
    s,((_\010.)+),($foo = $1) =~ s/.\010//g; "\376I\377$foo\376/I\377";,ge;
    s,((.\010.)+),($foo = $1) =~ s/.\010//g; "\376B\377$foo\376/B\377";,ge;
    s/.[\b]//g;			# catch sluff
    s/\&/\&amp\;/g; s/\</\&lt\;/g; s/\>/\&gt\;/g;
    s/\376/</g; s/\377/>/g;		# convert back
    $_;
}

#
# Splits up a query request, returns an array of items.
# usage: @items = &main'splitquery($query);
#
sub splitquery {
    local($query) = @_;
    grep((s/%([\da-f]{1,2})/pack(C,hex($1))/eig, 1), split(/\+/, $query));
}

#
# redirect the client to a new URL
# ($how is either 'moved' or 'found', defaults to 'moved'
#
sub redirect {
    local($url, $query, $how) = @_;
    # if url does not specify the scheme part of the URL make it local
    $url = join('', 'http://', $main'hostname,
	    ($main'plexus_port == 80 ? '' : ":$main'plexus_port"),
	    (($url =~ m#^/#) ? '' : '/'), $url) if ($url !~ m#^[\w-]+://#);
    $url .= "?" . $query if $query;
    # Location is the old-style header, URL is new-style header
    $main'out_headers{'URL'} = $main'out_headers{'Location'} = $url;
    &main'MIME_header($how || 'moved', 'text/html');
    print "The URL you requested has been relocated to\n";
    print "<A HREF=\"$url\">$url</A>\n";
    &main'debug("redirected to $url");
    exit(0);
}

#
# return FQDN if possible
# usage: $packed_ip = pack("C4", 192, 124, 34, 12);
# usage: $fqdn = &main'hostname($packed_ip);
#
sub hostname {
    local($ip) = @_;
    local($fqdn) = (($main'plexus{'revdns'} eq "true") &&
	(gethostbyaddr($ip,&main'AF_INET))[0]) ||
        join(".", unpack("C4", $ip));
    $fqdn =~ y/[A-Z]/[a-z]/;
    $fqdn;
}

#
# Safe open routine (opens for input only).
# Can be used to safely open files based on user input.
# usage: &main'safeopen("foo'BAR", "foo.config") || die "foo.config: $!\n";
#
sub safeopen {
    local($fh, $_) = @_;
    s#^\s#./$&#;				# protect leading spaces
    $plexus{'relative'} ne 'enabled'
        && (m#/\.+/# || m#/\.+$#)
        && &main'error('bad_request',
                "No backward directory references permitted: $_");
    open($fh, "< $_\0");
}

#
# Open routine that searches @INC (opens for input only).
# Can be used to safely open files based on user input.
# usage: &main'open("foo'BAR", "foo.config") || die "foo.config: $!\n";
#
sub open {
    local($fh, $file, $pre, $path, $_) = @_;
    foreach $pre (@INC) {
	$path = "$pre/$file";
	return &main'safeopen($fh, $path) if -f $path;
    }
    $! = &main'ENOENT; undef;
}

#
# Converts a fileglob-style regexp to a perl regexp (mostly)
# usage: $regexp = &main'globpat('*.c'); [...]; next unless /$filter/;
#
sub globpat {
    local($_) = @_;
    s/\\([\*\?\[\]])/\377$1/g;			# protect escapes
    s/([^A-Za-z0-9\-\*\?\[\]\377])/\\$1/g;	# protect
    $_ = join('', '^', $_, '$');		# ^ required below
    s/([^\377])\*/$1.*/g;			# process *
    s/([^\377])\?/$1./g;			# process ?
    s/\[\\\^/[^/g;				# process [^...]
    s/\377/\\/g;				# unescape escapes
    $_;
}

#
# Timeout routines.
# usage: &main'set_timeout;	*OR*      &main'set_timeout(1000);
# usage: &main'clear_timeout;
#
sub timeout_error {
    &main'error('timed_out',
	"Server timed out after $plexus{'timeout'} seconds.");
}
sub set_timeout {
    $main'SIG{'ALRM'} = "main'timeout_error";
    alarm($_[0] || $plexus{'timeout'});
}
sub clear_timeout {
    $main'SIG{'ALRM'} = 'IGNORE';
    alarm(0);
}

#
# Set bits in a vector corresponding to the filehandles file descriptors
# usage: $bits = &main'fhbits("main'STDOUT", "main'STDIN");
#
sub fhbits {
    local($bits, $_);
    for (@_) { vec($bits, fileno($_), 1) = 1; }
    $bits;
}

#
# Report error.  The exceptions are defined in plexus.conf.
# usage: &main'error('bad_request', "Your input is invalid");
#
sub error {
    local($exception, $msg) = @_;
    $main'__error_msg = $msg;			# export message to global
    die "EXCEPTION: $exception\n";
}

1;
