#!/usr/bin/perl

# httpd, the core HyperText Transfer Protocol Daemon
# by Marc VanHeyningen  March 1993

# This code forms the core of a multi-threaded perl HTTP deamon, with the
# primary emphasis being on quick responsiveness; thus, things like exec()
# and parsing are kept to a minimum when responding to requests.

require "sys/socket.h";
require "sys/wait.ph";
require "sys/file.ph";
require "ioctl.pl";
require "ctime.pl";

$sockaddr = 'S n a4 x8';

$www_dir = "/usr/local/www";
$time_out = 60;

# a crude attempt at modularity
require "$www_dir/httpd/error.pl";
require "$www_dir/httpd/front.pl";
require "$www_dir/httpd/finger.pl";
require "$www_dir/httpd/siks.pl";
require "$www_dir/httpd/neuro.pl";
require "$www_dir/httpd/sunman.pl";
require "$www_dir/httpd/inter.pl";
require "$www_dir/httpd/ucstri.pl";
require "$www_dir/httpd/lcd.pl";

# get the filedescriptor from the bind-stub
$s = shift;


sub timeout_error {
    &error("Server timed out after $time_out seconds.");
}


# do our loggging, and stay in $www_dir doing only relative refs
chdir($www_dir) || die "chdir: $!";

# Is this a real server or is Marc testing me again?
if($< == (getpwnam("mvanheyn"))[2]) {
    $log = "test/log";
} else {
    $log = "log/log";
}
$log_old = "$log.old";
unlink($log_old) || warn "unlink: $!";
rename($log, $log_old) || warn "rename: $!";
open(LOG, ">$log") || die "open: $!";
select(LOG); $| = 1;
print "----Server #$$ started at ", &ctime(time);

$restart_daemon = 0;
$SIG{'USR1'} = "restart_daemon";
sub restart_daemon {
    $restart_daemon = 1;
}
$SIG{'CHLD'} = "wait_on_kid"; 
sub wait_on_kid {	      
    wait;		  
}

# restore the socket from the fd
open(S, "+>&$s") || die "open on socket failed: $!";

# here comes the main loop
GET_CONNECTION:
    until ($restart_daemon) {

# We run the accept() in an eval() to trap the fatal error of
# an interrupted accept call.  This is a solution to a problem
# which shouldn't really even exist :-(
	eval { $addr = accept(NS, S) || die "accept: $!"; };
	if($@) {
	    next GET_CONNECTION 
		if($@ =~ /^accept: Interrupted system call/);
	    print LOG "Server exiting: $@\n";
	    die "$@";
	}

	if(($child = fork()) == 0) { # fork immediately to prevent delays
	    $SIG{'ALRM'} = "timeout_error";
	    select(NS); $| = 1;
	    ($af, $port, $inetaddr) = unpack($sockaddr, $addr);
	    @inetaddr = unpack('C4', $inetaddr);
	    $ctime = &ctime(time); chop $ctime;

	    alarm($time_out);	# provide a timeout
	    $_ = <NS>;
	    flock(LOG, &LOCK_EX);
	    print LOG join(".",@inetaddr), " ", $ctime, " ", $_;
	    close(LOG);

	    alarm($time_out);
	    &process_input();
	    close(NS);
	    exit;
	}
	close(NS);

# just in case the SIGCHLD missed some zombies...	
# probably will be able to safely remove this eventually, but it's possible
# for us to miss some kids if, say, we get a SIGCHLD while the server is
# restarting and hasn't gotten around to trapping it properly yet.
# but I'm going to see if removing it causes problems - MDVH
#	while(waitpid(-1,&WNOHANG) > 0) { ; }
	
    }

flock(LOG, &LOCK_EX);
print LOG "----Server #$$ restarting at ", &ctime(time);
close(LOG);
exec "$www_dir/httpd/httpd.pl", $s;
die "exec failed: $!";  


