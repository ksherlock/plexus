#
# cgi.pl      --- execute CGI scripts
#
$cgi'cgi_pl_version = '$Id: cgi.pl,v 2.3 1994/11/06 20:50:43 sanders Exp $';
#
# Based on htbin.pl by Oscar Nierstrasz <oscar@cui.unige.ch>
#     written by Gisle Aas <aas@nr.no>
#
# For your local.conf file, you write something like:
#  map     cgi-bin         cgi.pl          &cgi'cgi($top,$rest,$query)
#
# tws -- June 22 1994, changed function name from ``do'' to ``cgi''
#

package cgi;

# Beautify the version string
$cgi_pl_version =~ s/.+:\s+//;
$cgi_pl_version =~ s/\s+\d+:\d+:\d+.*.//;

$default_content_type = "text/plain";

sub cgi {
    local($top, $rest,$query) = @_;

    unless (length $rest) {
        &main'error('bad_request', "No CGI script specified");
    }

    # Find the split between scriptname and the rest
    $script = $top;
    do {
       $script .= "/$1"  if $rest =~ s|^/?([^/]*)||;
    } while length $rest && -d $script;
    $nph_script = (substr($1,0,4) eq "nph-");

    unless (-f $script) {
        &main'error('not_found', "CGI: can't find $script");
        exit;
    }
    unless (-x $script) {
        &main'error('forbidden', "CGI: can't execute $script");
        exit;
    }
    #
    # The fork/exec must be done by hand in order to detect errors,
    # and to pick up the Content-type (this will ONLY be printed in
    # the MIME header if the client is using HTTP 1.0).
    #
    pipe(CMDOUT,OUT); # pipes for scripts STDOUT and STDERR
    if ($pid = fork) {
        # This is the parent of the CGI script
        close(OUT);
        local($/); # no record boundaries needed here
        #
        # NB: both STDOUT and STDERR are redirected to CMDOUT
        # to avoid the server deadlocking.
        #
        $out = <CMDOUT>;
        wait;
        if ($? != 0) {
            &main'error('internal_error', "CGI: exec $script failed: $out");
            exit;
        }
        if ($nph_script) {
            print $out;
            exit;
        }

        # Parse output from script
        local($content_type, $location, $status);
        $content_type = $default_content_type;

        # Look through headers
        while ($out =~ s/^([\w-]+):\s+(.*)\n//) {
            $header = $1;
            $value  = $2;
            if      ($header =~ /^Location$/i) {
                $location = $value;
            } elsif ($header =~ /^Content-type$/i) {
                $content_type = $value;
            } elsif ($header =~ /^Status$/i) {
                &main'error('internal_error',
                        "Wrong format on status header for CGI script")
                    unless $value =~ /^\d+\s+.?/;
		$status = $value;
            } else {
                # Unknown headers should be passed on
                &main'add_header(*'out_headers, "$header: $value");
            }
        }
        $out =~ s/^\n//;   # eat newline after headers

        # Handle CGI/1.1 Status reply
        if (defined $status) {
	    print "$main'http_version $status\n";
            &main'unparse_headers(*'out_headers);
            print "MIME-version: 1.0\n";
            if (length $out) {
                print "Content-type: $content_type\n\n";
                print $out;
            }
            exit;
        }

	# Handle Location
        if (defined $location) {
            if ($location =~ /^\//) {
		&main'retrieve($main'plexus_top.$location);
                exit;
            }
            if ($location =~ m#^[\w-]+://#) {
		&main'redirect($location, undef, 'found');
            }
            &main'error('internal_error',
                    "Illegal location '$location' from CGI script");
        }

        # Handle normal output
        &main'MIME_header('ok', $content_type);
        print $out;
        exit;

    } elsif (defined $pid) {
        # This is the child: exec script
        # redirect stdout and stderr:
        close(CMDOUT);
        open(STDERR,">&OUT");
        open(STDOUT,">&OUT");
        close(OUT);
        select(STDOUT); $| = 1;
        # define CGI environment variables
        %ENV=();
        $ENV{"PATH"} = "/bin:/usr/ucb:/local/bin:$main'plexus_top$rest";
        $ENV{"SERVER_SOFTWARE"} = $main'server_version;
        $ENV{"SERVER_NAME"} = $main'hostname;
        $ENV{"GATEWAY_INTERFACE"} = "CGI/1.1";
	$ENV{"SERVER_PORT"} = $main'plexus_port;
        ($ENV{"REQUEST_METHOD"} = $main'action) =~ tr/a-z/A-Z/;
	if ($main'version) {
	    $ENV{'SERVER_PROTOCOL'} = $main'htrq_version;
	} else {
	    $ENV{'SERVER_PROTOCOL'} = 'HTTP';
	    $ENV{'HTTP_ACCEPT'} = 'text/html';
	}
        $ENV{"PATH_INFO"} = $rest;
        $ENV{"PATH_TRANSLATED"} = $main'plexus_top . $rest;
        $ENV{"SCRIPT_NAME"} = "/$script";
        $ENV{"QUERY_STRING"} = $query if defined $query;
	local($af, $port, $inetaddr) = unpack($main'sockaddr, $main'peeraddr);
        $ENV{"REMOTE_HOST"} = &main'hostname($inetaddr);
        $ENV{'REMOTE_ADDR'} = join(".",unpack("C4", $inetaddr));

        # Output additional CGI/1.1 headers
        for $header (keys %'in_headers) {
            next if $header eq 'Content-type';
            next if $header eq 'Content-length';
            $header_name = "HTTP_$header";
            $header_name =~ tr/a-z\-/A-Z_/;
            $header_value = $main'in_headers{$header};
            $header_value =~ s/\377/;/g;
	    $ENV{$header_name} = $header_value;
        }
        $ENV{"X_CGI_GATEWAY_VERSION"} = $cgi_pl_version;

        # only pass $rest and $query if non-empty
        if($main'action eq "post") {
           $ENV{'CONTENT_LENGTH'} = length($main'body);
           $ENV{'CONTENT_TYPE'} = $main'in_headers{'Content-type'};
           open(FOO,"| $script");
           print FOO $main'body;
           close(FOO);
           exit 0;
        } else {
            if ($query =~ /=/) {
		@args = ();
	    } else {
		@args = split(/\+/, $query);
                for (@args) { s/%([\da-f][\da-f])/pack("C",hex($1))/gei }
	    }
	    exec $script, @args;
        }
        print STDERR "CGI: can't exec $script\n$!";
        exit 1;
    } else {
        &main'error('internal_error', "CGI: fork $script failed\n$!");
    }
}

1;
