# post.pl -- Handle POST requests
#
# $Id: post.pl,v 2.4 1994/06/23 05:43:37 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, Sept 1993
#

sub do_post {
    local ($path, $top, $rest, $query, $version) = @_;
    local ($map, $_) = $top;
    $map = "__post_default__" unless defined $map{$map};
    eval $map{$map}; die $@ if $@;
}

package post;

sub test {
    local($path, $query) = @_;
    local($url) = join("", &main'printable($path), "?", &main'printable($query));
    local($from) = &main'hostname((unpack($main'sockaddr, $main'peeraddr))[2]);
    &main'MIME_header('ok', 'text/html');
    print "<TITLE>Post Test results</TITLE>\n";
    print "<PRE>\n";
    print "Post: $from: $url\n";
    print &form_at($main'body);
    print "</PRE>\n";
}

sub form_at {
    local($form) = @_;
    join("\n", grep((s/\+/ /g, s/%([\da-f]{1,2})/pack(C,hex($1))/eig,
	    s/[\r\n]+/\n\t/g, 1), split(/\&/, $form))), "\n";
}

sub poster {
    local($path, $query) = @_;
    local($url) = join("", &main'printable($path), "?", &main'printable($query));
    local($from) = &main'hostname((unpack($main'sockaddr, $main'peeraddr))[2]);
    open(MAILER, "| $main'plexus{'mailer'} -s 'Post: $from: $url' $main'plexus{'admin'} 2>/dev/null >/dev/null");
    print MAILER &form_at($main'body),"\n";
    print MAILER "End Of Message\n";
    close(MAILER);
    # Something like this is supposed to point to where we stored the document
    # &main'add_header(*main'out_headers, "URL: XXX");
    &main'MIME_header('ok', 'text/html');
    print "<TITLE>POSTED</TITLE>\n";
    print "Data Posted to $main'plexus{'admin'}\n";
}

1;
