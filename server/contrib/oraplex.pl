# oraplex.pl -- oracle -> WWW Gateway
#
# Requires oraperl
#
# $Id: oraplex.pl,v 2.5 1993/10/02 06:13:30 sanders Exp $
#
# Guy Decoux <decoux@moulon.inra.fr>, Sept 1993
#
# NOTE: Cannot be preloaded unless you get rid of the 'o' options on s///o
# This is for performance.
 
# Example config:
$map{'oracle'} = 'require "$http_sdir/oraplex.pl";
                  &do_oracle($path, $query, $version)';

package oracle;

$oraperl = "/usr/local/bin/oraperl";

sub do_script {
    local ($_) = @_;
    local ($top, $rest, $subdir, $file) = (undef, undef, undef, undef);

    #
    # preprocess the request
    #
    s:.*:/$&/:;	s:/+:/:g;		# force leading and trailing /
    ($plexus{'relative'} ne 'enabled') && m:/\.+/: && return 2;	
    m:[\<\|\>\`]: && return 2;
    s:^/::; s:/$::;				# cleanup
    ($top, $rest) = split("/", $_, 2);
    return 2 if $top ne "oracle";
    ($subdir,$file) = split("/", $rest, 2);
    return 2 if $subdir ne "perl";
    1;
}

sub main'do_oracle {
    local($_, $query, $version) = @_;

    return &main'retrieve($_) unless defined $query;

    $keyword = $query;
    if(($keyword =~ m#%#) && ($keyword !~ m#\+#)) {
	$keyword =~ s/%(..)/pack(c,hex($1))/eg;
    } else {
	$keyword =~ s/\+/ /g;
	$keyword =~ s/%(..)/pack(c,hex($1))/eg if $version;
    }

    s/\.html$/\.sql/;
    open(ORAFILE, $_) || &main'error('not_found', "$_: $!");
    &main'MIME_header('ok', 'text/html');
    print "<HEAD><ISINDEX><TITLE>OraPlex: ", $keyword;
    print "</TITLE></HEAD><BODY>\n";
    while(<ORAFILE>) {
	if(($Avant,$script,$Apres) = ( m#(.*)<sql\s+([\w,/,.]+)\s*>(.*)#)) {
            $Avant =~ s/<ESC>/$query/gi;
            $Avant =~ s/<UNESC>/$keyword/gi;
	    print $Avant;
	    if(&do_script($script) == 2) {
		print "</BODY>";
		close(ORAFILE);
	        &main'error('not_authorized', "Invalid Perl Script Directory");
	    }
	    $oldsig = $main'SIG{'CHLD'};
	    $main'SIG{'CHLD'} = '';			# so we get $?
	    system qq'$oraperl $script "$keyword"';
	    $main'SIG{'CHLD'} = $oldsig;
	    if($? != 0) {
		print "</BODY>";
		close(ORAFILE);
		return;
	    }
            $Apres =~ s/<ESC>/$query/gi;
            $Apres =~ s/<UNESC>/$keyword/gi;
	    print $Apres;
	    next;
	}
	s/<ESC>/$query/gi;
	s/<UNESC>/$keyword/gi;
	print;
    }
    close(ORAFILE);
    print "</BODY>\n";
}

1;
