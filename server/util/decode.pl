# decode.pl -- image selection decoder
#
# $Id: decode.pl,v 2.9 1994/06/23 05:44:08 sanders Exp $
#
# Chris McRae <mcrae@ckm.ucsf.edu>, May 1993
# bitmasks added by Tony Sanders <sanders@earth.com>, June 1993
#
# This is the support code for decoding images.
#
# FYI about bitmasks:
#   For large images using masks you'll want to scale the mask by some factor
#   depending on how accurate the results must be.  It would be better to
#   have a ppm style mask with each "color" being a different object.  If
#   you write this let me know.  Currently you need a mask for each object.
#   The code doesn't currently support this.
#	map_handle pixmask pixmap_file color1 URL1 [menu desc]
#	map_handle pixmask pixmap_file color2 URL2 [menu desc]
#
# &do_decode -- decides what to do (rectangle decoding is built-in)
# &region -- front end to &loadmask and &pixel that caches bitmasks
# &loadmask -- reads the image file into memory
# &pixel -- test if a pixel is set, image must already be loaded by &loadmask
# &rnd -- internal routine for &loadmask for rounding up to nearest byte
#
# XXX: executable URLs
# XXX: scaled bitmasks
#

# Example config lines:
# $map{'decode'} = '&do_decode($path, $query)';

sub do_decode {
    local($map_handle, $query) = @_;
    local($_, @lines, @menu) = (defined($query) && $query);
    local($X, $Y) = split(',', $_);			# unpack $query: x,y
    local($map_config_file) = $plexus{'decode_config'};
    local($title) = "Object menu for image: $map_handle";

    MAP_OPEN: {
	# extract lines from MAP for this object ($map_handle)
	@lines = ();
	&open(MAP, $map_config_file) || die "$map_config_file: $!";
	while (<MAP>) { /^\s*$map_handle\b/ && push(@lines, $_); }
	close(MAP);

	# map_handle default URL
	# map_handle title default_title_for_automenu
	# map_handle config-file map_config_file
	# map_handle bitmask bitmask_file width height URL [menu desc]
	# map_handle rect x y width height URL [menu desc]
	foreach (@lines) {
	    split(" ");					# into @_

	    if ($_[1] =~ /default/i) {
		return &retrieve($_[2]) unless defined($query);
	    } elsif ($_[1] =~ /title/i) {
		shift @_; shift @_; $title = join(" ", @_);
	    } elsif ($_[1] =~ /config-file/i) {
		# redirect to another file
		&error('internal_error', "too many lines for $map_handle in $map_config_file")
		    unless $#lines == 0;		# only one allowed
		$map_config_file = $_[2];
		redo MAP_OPEN;
	    } elsif ($_[1] =~ /bitmask/i) {
		# decode by bitmask
		local($bitmask, $w, $h, $URL) = @_[2..5];
		unless (defined($query)) {
		    splice(@_,0,6,());			# delete 0..6
		    push(@menu, join(" ", ($URL, @_)));	# rest is menu text
		    next;
		}
		# XXX: Need to embed width and height in the mask file
		&region($bitmask, $w, $h, $X, $Y) && return &retrieve($URL);
	    } elsif ($_[1] =~ /rect/i) {
		# decode by rectangle
		local($x, $y, $w, $h, $URL) = @_[2..6];
		unless (defined($query)) {
		    splice(@_,0,7,());			# delete 0..7
		    push(@menu, join(" ", ($URL, @_)));	# rest is menu text
		    next;
		}
		if (($x < $X) && (($x+$w) > $X) &&
		        ($y < $Y) && (($y+$h) > $Y)) {
		    return &retrieve($URL);
		}
	    }
	}
    }
    # No $query or nothing found -- this menu will only contain
    # the elements in the last config file read.
    &MIME_header('ok', 'text/html');
    print "<HEAD>\n<TITLE>$title</TITLE>\n</HEAD>\n";
    print "<BODY>\nYou can select one of:\n<UL>\n";
    foreach (@menu) {
	split(" ", $_, 2);
	print "<LI> <A HREF=\"$_[0]\">$_[1]</A>\n";
    }
    print "</UL>\n</BODY>\n";
}

sub rnd { local($value, $incr) = @_; ($value + ($incr-1)) & ~($incr-1); }

sub loadmask {
    local(*image) = @_;
    local($bits);	# because perl can't sysread into $image{'bits'}
    $image{'scanlen'} = &rnd($image{'width'}, 8);	# whole bytes
    open(BITS, $image{'filename'}) || die "$image{'filename'}: $!";
    sysread(BITS, $bits, $image{'scanlen'} * $image{'height'} / 8);
    close(BITS);
    $image{'bits'} = $bits;
}

sub pixel {
    local(*image, $x, $y) = @_;
    local($offset) = int((($y * $image{'scanlen'}) + $x)/8);
    local($byte) = unpack("c", substr($image{'bits'}, $offset, 4)) & 0xff;
    return (($byte & (1<<($x%8))) != 0);
}

$imgatom = "img000";				# generate unique names
%imgatom = ();

sub region {
    local($file, $width, $height, $x, $y) = @_;
    local($a);

    # cached?
    defined($a = $imgatom{$file}) || do {
	$a = $imgatom{$file} = $imgatom++;		# string increment
	eval "
	    \$$a{'filename'} = \$file;
	    \$$a{'width'} = \$width;
	    \$$a{'height'} = \$height;
	    &main'loadmask(*$a);";
	die $@ if $@;
    };
    return eval "&main'pixel(*$a, \$x, \$y)";
}

1;
