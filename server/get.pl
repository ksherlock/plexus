# get.pl -- Handle GET requests
#
# $Id: get.pl,v 2.10 1994/06/23 05:43:29 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, April 1993
#

# XXX: should probably handle TEXTSEARCH requests here also

sub do_get {
    local ($path, $top, $rest, $query, $version) = @_;
    local ($_, $map);

    $map = (defined $map{$top}) ? $top : "__get_default__";
    eval $map{$map}; die $@ if $@;
}

sub do_head { $main'access_via_head = 1; &do_get(@_); }

1;
