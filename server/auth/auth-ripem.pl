#
# auth-ripem.pl -- RIPEM authentication protocol
#
# $Id: auth-ripem.pl,v 1.2 1994/06/23 05:42:53 sanders Exp $
#
# by Tony Sanders <sanders@earth.com>, Sept 1993
#
# To create keypairs (use -b 1024 for server keypair):
#   ripem -g -R eks -P xxxpub -S xxxprv -u user@host.domain
# The RIPEM server only needs the users public keys.

package ripem_auth;

$auth = "RIPEM-1.1";

$ripem = "/usr/local/bin/ripem";
$agent = "webmaster@sample.host";
$secret_password = "sample";
$prv = "$main'http_sdir/auth/ripem-prv";	# server private key
$pub = "$main'http_sdir/auth/ripem-pub";	# authorized users

$req = "www/ripem1.1-request";
$repl = "www/ripem1.1-reply";

sub decode { exec $ripem, "-d", "-k", $secret_password, "-u", $agent, "-p", $pub, "-s", $prv; die "exec: $!"; }
sub encode { exec $ripem, "-e", "-h", "i", "-Y", "f", "-T", "a", "-k", $secret_password, "-u", $agent, "-p", $pub, "-s", $prv, "-r", @_; die "exec: $!"; }

sub denied {
    &main'add_header(*main'out_headers, "WWW-Authenticate: $auth entity=\"$agent\"");
    &main'error('unauthorized', "Access requires ``Authorization: $auth'': $_[0]");
}

sub main'auth {
    undef $main'ENV{'RIPEM_ARGS'};
    &main'debug("checking RIPEM authentication");
    &denied("Bad version") unless $main'version;
    &denied("Bad content") unless ($main'in_headers{'Content-type'} eq $req);
    local($recipient) = ($main'in_headers{'Authorization'} =~ m/entity\s*=\s*"([^"]*)"/);
    &denied("No authorization or bad recipient") unless $recipient;
    &main'debug("recipient is $recipient");

    # Send the "fake" ok header.  The real stuff get encrypted.
    &main'MIME_header('ok', $repl);

    # decrypt request from client and make it our "STDIN"
    do { local($/)=undef; $buf = <STDIN>; };
    open(STDIN, "-|") || &main'pipecmd('print $buf');
    open(STDIN, "-|") || &main'pipecmd('&decode');

    # encrypt resulting output and send back to client
    open(STDOUT, "|-") || &main'pipecmd('&encode($recipient)');
    &main'set_timeout();

    &main'debug("redoing request");
    $_ = &main'get_request;
    &main'grok_request;
    return $recipient;
}

1;
