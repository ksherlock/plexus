#
# access-filter.pl -- Disallow access to certain paths
#
# access-filter.pl,v 1.2 1993/10/02 07:13:06 sanders Exp
#
# by Tony Sanders <sanders@earth.com>, Oct 1993
# modified Dan Rich <drich@lerc.nasa.gov>, Nov, 1993
# integrated multiple versions, added features -- tws, Nov, 1994
#
# Read a configuration file and disallow certain paths.
# Requires configuration.

package access_filter;

&access_filter'config($main'plexus{'access-filter-config'});

sub main'access {
    local($fromfd, $peeraddr, $action, $path, $version, $authuser) = @_;
    local($line, $url, $type);
    local($pat, $methods, $users, $groups, $host);
    local($peer) = (unpack($main'sockaddr, $peeraddr))[2];
    local($_) = $path;
    &main'debug("access checking $action:$path:$authuser");
LINE:
    foreach $line (@access_filter'lines) {
	# pattern\377methods\377users\377groups\377{<ip,msk>a|<dns>d|*}{pfr}
	$type = chop($line);
	if ($type eq 'r') { $url = $line; next LINE; }
	($pat,$methods,$users,$groups,$host) = split(/\377/,$line,5);
	next LINE unless &access_filter'method_applies;	# nope...
	next LINE unless &access_filter'hostmatch;	# nope...
	next LINE unless &access_filter'usermatch;	# nope...
	next LINE unless /$pat/;			# nope...
	last LINE if $type eq 'p';			# got it!
	&access_filter'fail;				# sorry charlie
    }
}

sub fail {
    &main'redirect($url, undef, 'found') if $url;
    &main'error('forbidden', "$action $path invalid");
}

# check to see if this rule applies
sub method_applies {
    return 1 if $methods eq '*';
    $methods =~ m/\b$action\b/;
}

sub hostmatch {
    return 1 if ($host eq '*');
    local($type) = chop($host);
    if ($type eq 'a') {		# address
	local($addr,$mask) = ($host =~ m/(....)(....)/);
	vec($mask,0,1);
	return ((($peer & $mask) eq $addr));
    } else {			# domain
	# see if $host matches the last part of $peer (as a domain)
	# XXX: should do a forward lookup and double check A records?
	$peerhost = &main'hostname($peer);
	return (($peerhost =~ m/\.$host\.?$/) || ($host eq $peerhost));
    }
}

sub usermatch {
    local(%users) = ();				# okusers
    &okusers($users, &expand_groups($groups));
    return 1 if (defined $users{'*'});		# someone did a wildcard
    return 1 if (defined $users{$authuser});	# found the real user
    return 1 if (defined $users{'anonuser'} && $authuser eq '');
    return 1 if (defined $users{'authuser'} && $authuser ne '');
    return 0;
}

sub okusers {
    local(@list, $users, $user) = @_;
    foreach $users (@list) {
	foreach $user (split(/,/, $users)) { $users{$user} = 1; }
    }
}

sub expand_groups {
    local($groups) = @_;
    local($group, @groups);
    foreach $group (split(/,/, $groups)) { push(@groups, $groups{$group}); }
    @groups;
}

sub config {
    local($config) = shift(@_) || die "access_filter: no config file\n";
    local($_, $pat, $type, @spec);
    @lines = ();		# package variable
    %groups = ();		# package variable
    &main'open("access_filter'CONFIG", $config) || die "$config: $!\n";
CONFIG:
    while (<CONFIG>) {
	chop;
	next if (/^#/ || /^\s*$/);
	if (/^\s*group\s+(\S+)\s+(.*)\s*$/) {	# group name user[,user]
	    $groups{$1} = $2;
	    next CONFIG;
	} 
	if (/^\s*redirect\b\s*(.*)\s*$/) {	# redirect url
	    push(@lines, $1 . 'r');
	    next CONFIG;
	}
	if (/^\s*(pass|fail)\s+/) {		# {pass|fail} pattern ...
	    ($type, $pat, @spec) = split(" ", $_);
	    $pat = '*/' . $pat unless $pat =~ m#^[\/\*]#;
	    $pat =~ s#^/##;
	    local($host, $methods, $users, $groups) = ('*', '*', '*', '');
	    while ($spec[0]) {
		if ($spec[0] eq 'domain') {
		    shift @spec; $host = shift @spec;
		    $host =~ y/A-Z/a-z/;	# lower case
		    $host =~ s/\.+$//;	# remove trailing .'s
		    $host .= 'd';
		} elsif ($spec[0] eq 'ip') {
		    shift @spec; $host = shift @spec;
		    local($addr,$mask) = (split('/',$host));
		    $addr = pack("C4", (split('\.',$addr)));
		    $mask = pack("C4", (split('\.',$mask||'255.255.255.255')));
		    $host = $addr . $mask . 'a';
		} elsif ($spec[0] eq 'methods') {
		    shift @spec; $methods = shift @spec;
		} elsif ($spec[0] eq 'users') {
		    shift @spec; $users = shift @spec;
		} elsif ($spec[0] eq 'groups') {
		    shift @spec; $groups = shift @spec;
		}
	    }
	    push(@lines, join('',
		&main'globpat($pat), "\377",
		$methods, "\377",
		$users, "\377",
		$groups, "\377",
		$host, substr($type, $[, 1)));
	    next CONFIG;
	}
	warn "access-filter: $config: bad input: $_\n";
    }
    close(CONFIG);
}

1;
