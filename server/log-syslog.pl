#
# log-syslog.pl -- Log errors using syslog
#
# $Id: log-syslog.pl,v 2.3 1994/06/23 05:43:32 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, Sept 1993
#

require 'syslog.pl';

package logger;

sub init { &main'openlog('plexus', 'cons,pid,ndelay', 'daemon'); }
sub message { &main'syslog('info', '%s', join(' ', @_)); }
sub error {
    local($status, $msg) = @_;
    &main'syslog('notice', "$status: $msg"); }
sub close { &main'closelog(); }

1;
