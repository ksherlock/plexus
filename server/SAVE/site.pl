#
# site.pl -- Site dependent code (mostly defining system params)
#
# $Id: site.pl,v 2.13 1994/06/23 05:43:38 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, July 1993
#

# Configure logger: select one or the other
require 'log-simple.pl'; &logger'init('log');
# require 'log-syslog.pl'; &logger'init();

#
# Error codes
#
do 'errno.ph';
eval 'sub ENOENT {2;}'		unless defined &ENOENT;
eval 'sub EINTR {4;}'		unless defined &EINTR;
eval 'sub EINVAL {22;}'		unless defined &EINVAL;

#
# Socket/Networking support
#
do 'sys/socket.ph';
eval 'sub AF_INET {2;}'		unless defined &AF_INET;
eval 'sub SOCK_STREAM {1;}'	unless defined &SOCK_STREAM;
eval 'sub SOMAXCONN {5;}'	unless defined &SOMAXCONN;
eval 'sub SOL_SOCKET {0xffff;}'	unless defined &SOL_SOCKET;
eval 'sub SO_REUSEADDR {0x04;}' unless defined &SO_REUSEADDR;
$sockaddr = 'S n a4 x8';	# socket structure format

#
# File locking
#
do 'sys/unistd.ph';
eval 'sub SEEK_SET {0;}'	unless defined &SEEK_SET;

do 'sys/file.ph';
eval 'sub LOCK_SH {0x01;}'	unless defined &LOCK_SH;
eval 'sub LOCK_EX {0x02;}'	unless defined &LOCK_EX;
eval 'sub LOCK_NB {0x04;}'	unless defined &LOCK_NB;
eval 'sub LOCK_UN {0x08;}'	unless defined &LOCK_UN;

do 'fcntl.ph';
eval 'sub F_GETFD {1;}'		unless defined &F_GETFD;
eval 'sub F_SETFD {2;}'		unless defined &F_SETFD;
eval 'sub F_GETFL {3;}'		unless defined &F_GETFL;
eval 'sub F_SETFL {4;}'		unless defined &F_SETFL;
eval 'sub O_NONBLOCK {0x0004;}'	unless defined &O_NONBLOCK;
eval 'sub F_SETLK {8;}'		unless defined &F_SETLK;	# nonblocking
eval 'sub F_SETLKW {9;}'	unless defined &F_SETLKW;	# lockwait
eval 'sub F_RDLCK {1;}'		unless defined &F_RDLCK;
eval 'sub F_UNLCK {2;}'		unless defined &F_UNLCK;
eval 'sub F_WRLCK {3;}'		unless defined &F_WRLCK;
$s_flock = "sslll";		# struct flock {type, whence, start, len, pid}

sub seize {
    local ($FH, $lock) = @_;
    if ($plexus{'locking'} eq "flock") {
        flock($FH, $lock);
    } else {
	local ($flock, $type) = 0;
	if ($lock & &LOCK_SH) { $type = &F_RDLCK; }
	elsif ($lock & &LOCK_EX) { $type = &F_WRLCK; }
	elsif ($lock & &LOCK_UN) { $type = &F_UNLCK; }
	else { $! = &EINVAL; return undef; }
	$flock = pack($s_flock, $type, &SEEK_SET, 0, 0, 0);
	fcntl($FH, ($lock & &LOCK_NB) ? &F_SETLK : &F_SETLKW, $flock);
    }
}

sub setfd {
    local($flag, $_) = shift @_;
    while ($_ = shift @_) {
        fcntl($_, &F_SETFD, $flag);		# set/clear close-on-exec
    }
}

#
# File/Directory support
#
do 'sys/stat.ph';
eval 'sub S_ISDIR {
    local($m) = @_;
    eval "(($m & 0170000) == 0040000)";
}'				unless defined &S_ISDIR;

#
# Processes
#
do 'sys/wait.ph';
eval 'sub WNOHANG {1;}'		unless defined &WNOHANG;

1;
