#
# virtual.pl -- path virtualization support code
# Orig by Martijn Koster <m.koster@nexor.co.uk>
# hacked on by Tony Sanders <sanders@earth.com>, Nov 1994
#
package virtual;

sub main'p_virtualpath {
    local(@_) = split(" ", $_, 2);
    &main'debug("virtualpath $_[0] $_[1]");
    if ($#_ != 1) {
	warn("malformed virtualpath $_, need \`virtualpath from to\'");
    } else {
	push(@virtualpaths, "$_[0] $_[1]");
    }
}

sub main'p_redirect {
    local(@_) = split(" ", $_, 2);
    &main'debug("redirect $_[0] $_[1]");
    if ($#_ != 1) {
	warn("malformed redirect $_, need \`redirect from to\'");
    } elsif ($_[1] !~ /\w+\:/) {
	warn("Illegal url '$_[1]'\n");
    } else {
	push(@redirects, "$_[0] $_[1]");
    }
}

sub resolve_redirect
{
    local($path) = @_;
    local($_, $a, $b);
    &main'debug("&resolve_redirect($path)");
    for $_ (@redirects) {
        ($a, $b) = split(" ", $_, 2);
	$a =~ s/(\W)/\\$1/g;
	if ($path =~ s/^$a/$b/) {
	    &main'debug("redirected to $path");
	    &main'redirect($path, undef, 'found');
	}
    }
    $path;
}

sub virtualise
{
    local($path) = @_;
    local($_, $a, $b);
    &main'debug("&virtualise($path)");
    for $_ (@virtualpaths) {
        ($a, $b) = split(" ", $_, 2);
	$a =~ s/(\W)/\\$1/g;
	if ($path =~ s/^$a/$b/) {
	    &main'debug("translated $a to $b");
	}
    }
    $path;
}

# for ~ expansion you can either use an associative
# array read on startup, or getpwnam. Which is better
# depends on how often you expect twiddle expansion,
# and how big you user base is.
sub process_twiddles
{
    &main'debug("preloading %twiddles");
    local(@pwent);
    # ($name,$passwd,$uid,$gid,$quota,$comment,$gcos,$dir,$shell)
    while (@pwent = getpwent) {
        $twiddles{$pwent[0]} = $pwent[7];
    }
}

# expand user directories
# the twiddle prefix is defined by $main'plexus{'twiddle_prefix'}
# typical values are `~' and `home/'.
#
# the home HTML directory is defined by $main'plexus{'twiddle_export'}
#
# e.g., home/sanders/bio.html -> /users/bsdi/sanders/public_html/bio.html
#       ~sanders/bio.html     -> /users/bsdi/sanders/public_html/bio.html
#
# Only makes sense in file system (dir.pl: &retrieve)
sub resolve_twiddle {
    local($path) = @_;
    local($pre) = $main'plexus{'twiddle_prefix'} || '~';
    local($export) = '/' . ($main'plexus{'twiddle_export'} || 'public_html');

    if ($path =~ m#^$pre([^/]+)#) {
	local($name, $dir);
        $name = $1;

	# resolve twiddle
	if (defined %twiddles) {
	    $dir = $twiddles{$name} if defined $twiddles{$name};
	} else {
	    $dir = (getpwnam($name))[7];
	}
	return $path unless ($dir);
	# append user directory
	$dir .= $export;

	$path =~ s/^$pre$name/$dir/;
	&main'debug("resolved $pre$name to $path")
    }
    $path;
}

1;
