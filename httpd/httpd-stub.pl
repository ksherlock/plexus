#!/usr/bin/perl

# httpd-stub.pl, the bind-stub for the perl HyperText Tranfer Protocol Daemon
# Marc VanHeyningen  March 1993
# this does the critical root-stuff like binding to the port

require "sys/socket.h";

if($< == 0) {
    $port = 80;			# should use getservbyname()
} else {
    $port = 3456;
}



$sockaddr = 'S n a4 x8';        # I wish I knew exactly what this means

($name, $aliases, $proto) = getprotobyname('tcp');
$this = pack($sockaddr, &AF_INET, $port, "\0\0\0\0");

select(NS); $| = 1;

socket(S, &AF_INET, &SOCK_STREAM, $proto) || die "socket: $!";
bind(S, $this) || die "bind: $!";
listen(S,&SOMAXCONN) || die "connect: $!";

select(S); $| = 1;

if($< == 0) {
    $( = $) = (getgrnam("www"))[2];
    $< = $> = (getpwnam("daemon"))[2];
}

exec "/usr/local/www/httpd/httpd.pl", fileno(S);
