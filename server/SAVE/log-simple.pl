#
# log-simple.pl -- Simple logging functions
#
# $Id: log-simple.pl,v 2.5 1994/06/23 05:43:31 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, Sept 1993

package logger;

sub init {
    local($log) = $main'plexus_log || shift;
    local($umask) = umask(002);
    &main'debug("openlog $log");
    open(LOG, ">>$log") || die "$log: $!";
    select((select(LOG), $| = 1)[0]);
    &main'debug("logfd ", fileno(LOG));
    umask($umask);
}

sub message {
    local($msg) = @_;
    &main'set_timeout();
    &main'seize(LOG, &main'LOCK_EX);
    print LOG $msg;
    &main'seize(LOG, &main'LOCK_UN);
    &main'clear_timeout;
}

sub error {
    local($status, $msg) = @_;
    open(ERROR, "| $main'plexus{'mailer'} -s 'Plexus: $status' $main'plexus{'admin'} 2>/dev/null >/dev/null");
    select((select(ERROR), $| = 1)[0]);
    print ERROR "Server Error: ", $msg, "\n";
    close(ERROR);
}

sub close { close(LOG); }

1;
