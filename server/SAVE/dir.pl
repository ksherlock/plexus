# dir.pl -- directory browser (with filter)
#
# $Id: dir.pl,v 2.17 1994/06/23 16:50:26 sanders Exp $
#
# Tony Sanders <sanders@earth.com>, April 1993
#

# XXX: add auto-decompression of .z .gz .Z files???
# XXX: remember to use content-encoding for HTTP/1.0
sub retrieve {
    local($path, $filter) = @_;
    -e $path || &error('not_found', "document \`\`$path\'\' does not exist");
    return -d $path ? &index_dir($path, $filter) : &wrap_file($path);
}

sub wrap_file {
    local($path) = @_;
    local($FD) = "main'FD";
    local($content);

    &main'set_timeout();
    &safeopen($FD, $path) || &error('not_found', "$path: $!");
    &seize($FD, &LOCK_SH) if $plexus{'strick_lock'} eq 'true';
    &set_file_status($path);
    &wrap_fd($FD, &deduce_content($path));
    close($FD);
}

sub wrap_fd {
    local($FD, $content) = @_;

    # XXX: need a better solution.  What will probably happen is all
    # the translation code will move into a sub process and we'll
    # open("|-") to it before doing any output.  This way *everything*
    # goes through the translation code.

    # If this fails we've lost STDOUT to the client so we just exit.
    # I'm 99% sure the only way this can happen is if the client
    # initiates a close midstream.
    open(RAW, ">& STDOUT") || exit 0;

    # &add_tranlations makes our STDOUT point to the pipeline.
    $content = &add_translations($content);

    # force headers to go directly to client, bypassing any
    # translator that got installed above.
    select(RAW); $|=1;
    if ($version) {
	&MIME_header('ok', $content)		# wrap HTTP/1.0 headers
	    unless ($content eq 'www/reply');
    } else {
	local($ext) = $path =~ m/\.(\w+)$/;
	print '<PLAINTEXT>'
	    unless(defined $content{$ext} || defined $encoding{$ext});
    }
    select(STDOUT);
    &raw_fd($FD, STDOUT);
    close($FD);
}

sub raw_file {
    local($path) = @_;
    local($FD) = "main'FD";

    &main'set_timeout();
    &safeopen($FD, $path) || &error('not_found', "$path: $!");
    &seize($FD, &LOCK_SH) if $plexus{'strick_lock'} eq 'true';
    &raw_fd($FD, STDOUT);
    close($FD);
}

# handles partial writes
sub raw_fd {
    local($FROM, $TO) = @_;
    local($_, $len, $written, $offset);

    while (($len = sysread($FROM, $_, 8192)) != 0) {
	&main'set_timeout() if defined &main'set_timeout;
        if (!defined $len) {
            next if $! =~ /^Interrupted/;
            &error('internal_error', "System read error: $!");
	}
	$offset = 0;
	while ($len) {
	    $written = syswrite($TO, $_, $len, $offset);
	    &error('internal_error', "System write error: $!")
	        unless defined $written;
	    $len -= $written;
	    $offset += $written;
	}
    }
}

# Adapted from code by Martijn Koster <m.koster@nexor.co.uk>
sub set_file_status {
    local($path) = @_;
    local($cached);

    local($modified) = (stat($path))[9];
    local($size) = -s _;			# a little perl magic

    &add_header(*out_headers,
	sprintf("Last-Modified: %s", &fmt_date($modified)));
    if (defined ($cached = $in_headers{'If-modified-since'})) {
	local($cache_date) = &unfmt_date($cached);
	&main'debug("?? Cached: $cache_date >= Modified: $modified");
	# this cheats and uses error to generate the reply: XXX
	&main'error('not_modified', '')
	    if ($cache_date >= $modified);
    }
    &add_header(*mime_headers, "Content-length: $size");
}

sub deduce_content {
    local($path) = @_;
    local(@exts) = split(/\./, $path);
    local($ext, $encoding);

    &debug("deduce_content($path)");
    while (($ext = pop(@exts)) && (defined $encoding{$ext})) {
	&debug("found encoding extension: $ext -> $encoding{$ext}");
	$encoding .= '; ' if defined $encoding;
	$encoding .= $encoding{$ext};
    }
    &debug("adding... Content-encoding: $encoding") if defined $encoding;
    &add_header(*mime_headers, "Content-encoding: $encoding")
        if defined $encoding;
    return $content{$ext} if defined $content{$ext};
    return (-B $path ? $content{'__binary__'} : $content{'__text__'});
}

sub index_dir {
    local($dir, $filter) = @_;
    local($count, $_) = 1;

    local($ndx) = "$dir/$plexus{'index'}";
    do { &wrap_file($ndx); return; } if -f $ndx;

    $plexus{'autoindex'} || &error('bad_request', "$dir is a directory");
    defined($hidden{$dir}) && &error('bad_request', "$dir is a directory");
    $filter = '*' unless defined $filter;
    $filter = join(" ", &main'splitquery($filter));
    local($pfilter) = &main'printable($filter);
    $filter = &main'globpat($filter);

    &MIME_header('ok', 'text/html');
    if (-f "$dir/$dir_header") {
	&raw_file("$dir/$dir_header");
    } else {
	print <<EOT;
<HEAD>
<ISINDEX><TITLE>Index of /$dir: filter=$pfilter</TITLE>
</HEAD>
<BODY>
<H1>Directory Index of /$dir</H1>
You can use the keyword search to specify fileglobs (e.g., *.gif, *.[ch])
to select only those filenames for viewing (used to  narrow down large
directory listings).  []-style globs are restricted to alphanumeric and
you can use caret to invert the character set (e.g., [^abc]) and hypen
to specify a range (e.g., [a-z]).
EOT
    }

    print "<PRE>\n";
    local($parent) = substr($dir, $[, rindex($dir, "/"));
    printf("%39s<A NAME=%d HREF=\"/%s%s\">Parent Directory</A>\n",
           "", $count++, $parent, (length($parent)?"/":""));

    # Get directory listing
    &main'set_timeout();
    opendir(DH, $dir) || &error('not_found', "$dir: $!");
    @dirs = sort(readdir(DH));
    while ($_ = shift @dirs) {
	&main'set_timeout();
	next if /^\.$/ || /^\.\.$/;
	next if defined($hidden{"$dir/$_"}) || defined($hidden{$_}); # hidden
	next unless /$filter/;
	local($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size,
	    $atime, $mtime, $ctime, $blksize, $blocks) = stat("$dir/$_");
	local($date) = &ctime($mtime); chop $date;
	printf "%s %9d ", $date, $size;
	$_ .= "/" if &S_ISDIR($mode);
        print "<A NAME=$count HREF=\"/$dir/$_\">$_</A>\n";
	$count++;
    }
    closedir(DH);

    print "</PRE>\n";

    if (-f "$dir/$dir_footer") {
        &raw_file("$dir/$dir_footer");
    } else {
	print "</BODY>\n";
    }
}

#
# Currently we only search one deep in the conversion tree
# XXX: needs to grok Accept: fields.
#
sub add_translations {
    local($content) = @_;
    local($map, @conversions);

    # These two are required by the RFC
    $accepted{'text/html'} = $accepted{'text/plain'} = 1;
    return $content if defined $accepted{$content};
    # map if we can, otherwise punt
    if (defined ($map = $trans{$content})) {
	@conversions = split(/:/, $map);
        CONV: while ($#conversions != $[) {
	    $to = shift @conversions;
	    $how = shift @conversions;
	    if (defined $accepted{$to}) {
	        $content = $to;
	        select((select(STDOUT), $|=1, print(""))[0]);
	        open(STDOUT, "|-") || &pipecmd("&$how");
	        last CONV;
	    }
	}
    }
    # even if we can't find a conversion to something known we punt
    # and let the browser deal with whatever we can send.
    return $content;
}

sub pipecmd {
    local($caller) = caller;
    eval join(" ", "package $caller;", @_);
    die $@ if $@;
    exit 0;
}

1;
