# inc.pl -- implement support for <INC SRV...>
#
# $Id: inc.pl,v 2.1 1994/06/23 05:44:11 sanders Exp $
#
# Default file suffix is .xhtml
# There is no way to escape the <INC> command.
# I picked x-xhtml as the type (Gisle used hacked-html
#     as I had suggested on www-talk :-)
#
# From: Gisle.Aas@nr.no
# Message-Id: <9310070721.AA17252@nora.nr.no>
# Subject: Re: Generalising inlined images
# References: <9310061941.AA04259@austin.BSDI.COM>
#
package inc;

# configured in local.conf now
# $main'ext{'x-xhtml'} = 'text/x-xhtml';
# $main'trans{'text/x-xhtml'} = "text/html:inc'html";

sub html
{
    # this is a translation filter
    while (<STDIN>) {
	s/<inc\s+([^>]*)>/&inc($1)/ige;
	print;
    }
}

sub inc
{
    local($_) = $_[0];
    return scalar(`$1`)                      if /^cmd="([^"]+)"/i;
    return "<pre>\n".scalar(`$1`)."</pre>\n" if /^precmd="([^"]+)"/i;
    return eval "$1"                         if /^perl="([^"]+)"/i;
    return scalar(`cat $1`)                  if /^file="([^"]+)"/i;
    return "<em>&lt;inc $1&gt; not understood</em>";
}
1;
