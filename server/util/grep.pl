;#
;#      @(#)$Id: grep.pl,v 2.5 1993/09/20 22:42:18 sanders Exp $
;#
;# flexible grep
;#
;# Author:  Tony Sanders
;# Returns: undef if eval fails (pattern was bad)
;# Usage:   &grep($matched, flags, pattern, *FILEHANDLE);
;#              matched    : function to call on match
;#              flags      : options:
;#                           i = ignore case
;#                           v = reverse
;#                           p = paragraph mode
;#              pattern    : a regexp to match
;#              FILEHANDLE : an opened FILEHANDLE to read from
;#
;#          $matched can access $_ which is the data matched
;#          if $matched returns true the grep is aborted.

package _fgrep;

sub main'grep {
    local($f, $flg, $p, *FH) = @_;
    local($i, $v, $_);
    local($k) = caller;
    $i = 'i' if ($flg =~ /i/);
    $v = '!' if ($flg =~ /v/);
    eval "package $k; local(\$*, \$/) = (1, '') if (\$_fgrep'flg =~ /p/);
          while(<_fgrep'FH>) { last if $v /\$_fgrep'p/o$i && &$f(); } 1";
}

;#
;# Example code: Paragraph grep
;#
;#
sub ppgrep {
    $0 =~ s,.*/,,; $usage = "Usage: $0 [-pslhive | --] [expr] pattern [files...]\n";
    $flags = ""; $lflag = $hflag = $sflag = 0;
    $main'ARGV[0] =~ /^-[^-]/ && do {
	$_ = shift(@main'ARGV);
	/i/ && do { $flags .= "i"; };		# ignore case
	/v/ && do { $flags .= "v"; };		# reverse match
	/p/ && do { $flags .= "p"; };		# paragraph mode
	/l/ && do { $lflag++; };		# only list files
	/h/ && do { $hflag++; };		# hide filenames
	/s/ && do { $sflag++; };		# match white space
	/e/ && do { $eflag++; };
    };

    if ($eflag) { ($expr = shift(@main'ARGV)) || die $usage; }
    $pat = shift(@main'ARGV) || die $usage;
    $sflag && $pat =~ s/\s+/\\s+/g;
    $hflag++ if ($#main'ARGV <= 0);		# hide filename if 0 or 1 args
    $colon = ($lflag ? "\n" : ":");		# do the right thing for -l
    $ever_matched = 1;

    unshift(@main'ARGV, '-') unless @main'ARGV;
    while ($main'ARGV = shift(@main'ARGV)) {
	open(FH, $main'ARGV) || warn "Couldn't open $main'ARGV\n";
	&main'grep('ppgrok', $flags, $pat, *FH) || warn $@;
	close(FH) if $lflag || eof;		# reset line number
    }
    exit $ever_matched;
}

sub ppgrok {
    $ever_matched = 0;
    print $main'ARGV,$colon unless $hflag;
    return 1 if $lflag;
    defined $expr ? eval $expr : (print($_), 0)[1];
}

1;
