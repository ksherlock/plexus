# forms.pl -- Handle forms data
#
# $Id: forms.pl,v 2.5 1994/12/07 23:45:46 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, June 1994
#

package forms;

# $indent is a bit of optional data processing I put it for
# formatting the data nicely when you are emailing it.
# This is derived from code by Denis Howe <dbh@doc.ic.ac.uk>
# and Thomas A Fine <fine@cis.ohio-state.edu>
sub decode {
    local($form, *data, $indent, $key, $_) = @_;
    # turns out that using & was a bad idea so the current
    # HTML 2.0 spec recommends accepting ``;'' as well so
    # that perhaps this could be used instead at some point in the future.
    local(@keys);
    foreach $_ (split(/[&;]/, $form)) {
	($key, $_) = split(/=/, $_, 2);
	$_   =~ s/\+/ /g;				# + -> space
	$key =~ s/\+/ /g;				# + -> space
	$_   =~ s/%([\da-f]{1,2})/pack(C,hex($1))/eig;	# undo % escapes
	$key =~ s/%([\da-f]{1,2})/pack(C,hex($1))/eig;	# undo % escapes
	$_   =~ s/[\r\n]+/\n\t/g if defined($indent);	# indent data after \n
	push(@keys, $key);
	$data{$key} = $_;
    }
    @keys;
}
sub string {
    local(*form, $_, $key) = @_;
    $_ = "";
    foreach $key (keys %form) {
	$_ .= join("", $key, " = ", $form{$key}, "\n");
    }
    $_;
}
sub stringify_list {
    local(*form, @keys, $_, $key) = @_;
    $_ = "";
    foreach $key (@keys) {
	$_ .= join("", $key, " = ", $form{$key}, "\n");
    }
    $_;
}

# This functions takes a form a it's format information and tries
# to make sure it meets the designers specifications:
#     item=[rn]/item=[rn]/...    required and/or numeric fields
sub verify {
    local($format, *form) = @_;
    local($item, $who, $how);
    local($errors) = undef;
    foreach $item (split('/', $format)) {
	($who, $how) = split('=', $item, 2);
	if ($how =~ /r/) {			# required field
	    $errors .= "field `$who' is required; "
		unless (defined($form{$who}) && ($form{$who} !~ /^\s*$/));
	}
	if ($how =~ /n/) {			# numeric field
	    $errors .= "field `$who' must be numeric; "
		if (defined($form{$who}) && ($form{$who} =~ /[^0-9.,()+-]/));
	}
    }
    $errors;
}

# You can use this function to have the form emailed to a certain person.
# The email address and subject are passed in from local.conf for security
# instead of being taken from the URL data.
#
# To use in test mode leave $whom undefined.
sub emailto {
    local($top, $rest, $query, $whom, $subject) = @_;
    local($url) = &main'printable("$top/$rest");
    $url .= "?" . &main'printable($query) if ($query);
    local($from) = &main'hostname((unpack($main'sockaddr, $main'peeraddr))[2]);
    local(*form, $old);

    &main'error('bad_request', 'No form data') if (!$main'body && !$query);
    local(@keys) = &decode(($main'body || $query), *form, 1);
    $error = &verify($rest, *form);
    &main'error('bad_request', $error) if (defined($error));

    if ($whom) {
	open(MAILER, "| $main'plexus{'mailer'} -s 'FORM: $subject' $whom "
		    . "2>/dev/null >/dev/null");
	$old = select(MAILER);
    } else {
	&main'MIME_header('ok', 'text/html');
	print "<TITLE>Form debug results</TITLE>\n";
	print "<PRE>\n";
    }

    print "Form: $subject\n";
    print &main'resolve_header(*main'in_headers, 'From');
    print &main'resolve_header(*main'in_headers, 'Referer');
    print &main'resolve_header(*main'in_headers, 'User-agent');
    print "Hostname: $from\n";
    print "URL: $url\n";
    print "----------------\n";
    print &stringify_list(*form, @keys);
    print "----------------\n";

    if ($whom) {
	close(MAILER);
	select($old);
	# If you store the document you could return the URL like this
	# &main'add_header(*main'out_headers, "URL: XXX");
	&main'MIME_header('ok', 'text/html');
	print "<TITLE>Form was sent</TITLE>\n";
	print "Form data sent to $whom\n";
    } else {
	print "</PRE>\n";
    }
}

1;
