# mime.pl -- handle MIME headers
#
# $Id: mime.pl,v 2.12 1994/12/07 23:44:48 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, April 1993
#

require 'timelocal.pl';		# comes with perl

#
# Any additional headers are expected in %out_headers
#
sub MIME_header {
    local($status, $content) = @_;
    &main'set_timeout();
    return 0 unless $version;       # if $version !~ m/$htrq_version/i;
    $status = 'internal_error' unless defined($main'code{$status});
    printf("%s %s\n", $http_version, $main'code{$status});
    &unparse_headers(*out_headers);
    exit 0 if ($status eq 'not_modified');	# XXX (hack)

    printf("MIME-Version: 1.0\n");
    printf("Content-Type: $content\n");
    &unparse_headers(*mime_headers);
    printf("\n");				# blank line
    exit 0 if $main'access_via_head == 1;	# XXX (hack) HEAD method
    1;
}

sub fmt_date {
    local($time) = @_;
    local(@DoW) = ('Sunday','Monday','Tuesday','Wednesday',
	           'Thursday','Friday','Saturday');
    local(@MoY) = ('Jan','Feb','Mar','Apr','May','Jun',
	           'Jul','Aug','Sep','Oct','Nov','Dec');
    local($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
        gmtime($time);
    sprintf("%s, %02d-%s-%02d %02d:%02d:%02d GMT",
        $DoW[$wday], $mday, $MoY[$mon], $year, $hour, $min, $sec);
}

sub parse_headers {
    local(*headers) = @_;
    local($_, $field);
    return 0 unless $version;	# if $version !~ m/$htrq_version/i;
    while ($_ = <STDIN>) {
	s/[ \t\r\n]*$//;
	last if /^$/;		# end of headers (possibly start of body)
        if (/^[ \t]/) {
	    # continuation line
            last unless $field;
            s/^[ \t]*/ /;
            $headers{$field} .= $_;
        } else {
	    $field = &add_header(*headers, $_);
	}
    }
    $body = &parse_body;
}

sub add_header {
    local(*headers, $_) = @_;
    local($field, $data) = split(/\s*:\s*/, $_, 2);
    $field =~ y/A-Z/a-z/; substr($field,0,1) =~ y/a-z/A-Z/;
    $headers{$field} .= "\377" if defined $headers{$field};
    $headers{$field} .= $data;
    return $field;
}

#
# Spit headers back out from internal format
# Sigh, need perl5's nested data structures.
#
sub unparse_headers {
    local(*headers) = @_;
    local(@list, $i, $,);
    foreach $i (keys %headers) {
	print &resolve_header(*headers, $i);
    }
}

# grab the value of a header 
sub resolve_header {
    local(*headers, $i) = @_;
    local(@list);
    return undef unless defined $headers{$i};
    @list = grep($_ .= "\n", split("\377", $headers{$i}));
    $i =~ s/\b([a-z])/\u$1/;
    join("$i: ", "",@list);
}   

#
# Read input using either Length: or Message-Boundry:
#
sub parse_body {
    local($_, $buf, $len, $length, $boundary);

    $length = $main'in_headers{'Length'}
	if defined $main'in_headers{'Length'};
    $length = $main'in_headers{'Content-length'}
	if defined $main'in_headers{'Content-length'};
    $boundary = $main'in_headers{'Message-boundary'}
	if defined $main'in_headers{'Message-boundary'};

    if (defined $length) {
	&debug("parse_body: wants length $length");
	open(POST, "-");		# XXX: why doesn't STDIN work???
	while (($length > 0) && (($len = read(POST, $_, $length)) != 0)) {
	    &debug("parse_body: got $len\n");
	    &main'set_timeout() if defined &main'set_timeout;
	    if (!defined $len) {
		next if $! =~ /^Interrupted/;
		&main'error('internal_error', "System read error: $!");
	    }
	    $buf .= $_;
	    $length -= $len;
	}
	close(POST);
    } elsif (defined $boundary) {
	&debug("parse_body: boundary");
        $boundary = "--" . $boundary;
        while (<STDIN>) { next if $_ eq $boundary; }
        while (<STDIN>) { last if $_ eq $boundary; $buf .= $_; }
    } else {
        &debug("parse_body: no body on this request");
    }
    &debug("BODY: $buf") if defined($buf);
    $buf;	# returns undef if neither length nor bounary found
}

# adapted from Martijn Koster <m.koster@nexor.co.uk>
sub unfmt_date {
    local($_) = @_;
    local($day, $month, $mday, $time, $year, $zone);

    # Need to handle:
    #      Monday, 18-Apr-94 11:57:26 GMT
    #      Mon, 18 Apr 1994 11:57:26 GMT
    #      Mon Apr 18 11:57:26 GMT 1994
    
    if (/(\w\w\w)\w+,\s+(\d+)\-(\w\w\w)\-(\d+)\s+(\d\d:\d\d:\d\d)\s+(\w+)/) {
	# if the date is like "Monday, 18-Apr-94 11:57:26 GMT"
	($day,$mday,$month,$year,$time,$zone)=($1,$2,$3,$4,$5,$6);
    }
    elsif (/(\w\w\w),\s+(\d+)\s+(\w\w\w)\s+(\d+)\s+(\d\d:\d\d:\d\d)\s+(\w+)/) {
	# if the date is like "Mon, 18 Apr 1994 11:57:26 GMT"
	($day,$mday,$month,$year,$time,$zone)=($1,$2,$3,$4-1900,$5,$6);
    }
    elsif (/(\w\w\w)\s+(\w\w\w)\s+(\d+)\s+(\d\d:\d\d:\d\d)\s+(\w+)\s+(\d+)/) {
	# if the date is like "Mon Apr 18 11:57:26 GMT 1994"
	($day,$month,$mday,$time,$zone,$year)=($1,$2,$3,$4,$5,$6-1900);
    }

    &main'debug("day=$day, month=$month, mday=$mday, time=$time, " .
	"zone=$zone, year=$year");
    return -1 if ($year < 0);	# prevent timegm looping

    local($hour, $min, $sec) = split(':', $time);
    local(%months) = ('Jan',0,'Feb',1,'Mar',2,'Apr',3,'May',4,'Jun',5,
	              'Jul',6,'Aug',7,'Sep',8,'Oct',9,'Nov',10,'Dec',11);
    $month =~ y/A-Z/a-z/; $month =~ s/.*/\u$&/;
    return &timegm($sec, $min, $hour, $mday, $months{$month}, $year)
	if (defined $months{$month});
    &main'debug("Bad month $month");
    return -1;
}
