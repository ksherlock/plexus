#
# auth-basic.pl -- "basic" authentication
# by Gisle.Aas@nr.no

package auth;

# Set up the printable encoding vector in the @enc array.
#
# Encoding scheme:
#    00-25,26-51,52-61,62,63,pad
#     A-Z   a-z   0-9   +  /   =
INIT: {
    # Set up the printable encoding vector in the @enc array.
    for ("A" .. "Z") { $enc[ord($_)] = ord($_) - ord("A"); }
    for ("a" .. "z") { $enc[ord($_)] = ord($_) - ord("a") + 26; }
    for ("0" .. "9") { $enc[ord($_)] = ord($_) - ord("0") + 52; }
    $enc[ord("+")] = 62;
    $enc[ord("/")] = 63;
    $enc[ord("=")] = -1;
}

sub main'auth
{
    local($realm) = $main'plexus{'basic-realm'};

    &denied("Bad protocol version (need HTTP/1.0 or better)")
	unless $main'version;
    local($authdata) = ($main'in_headers{'Authorization'} =~ m/^Basic\s+(.*)/);
    &denied("Invalid authorization data") unless $authdata;
    &printable_decode($authdata);
    local($user, $password) = split(':', $authdata, 2);
    local(@uinfo) = &get_uinfo($user);
    &main'debug("get_uinfo ".join(":",@uinfo)." ($password)");
    $user = undef unless ($uinfo[1] eq $password);
    # XXX: I let it pass and let access-filter deal with them.
    # &denied("Invalid authorization data") unless defined $user;
    &main'debug("$user authenticated") if defined $user;
    &main'debug("$uinfo[0] authentication failed") unless defined $user;
    $user;
}

sub denied
{
    &main'add_header(*main'out_headers,
	"WWW-Authenticate: Basic realm=\"$realm\"");
    &main'error('unauthorized',
	"Access requires ``Authorization: Basic'' for realm ``$realm'': $_[0]");
}

sub get_uinfo
{
    local($user) = shift;
    local($_);
    local($db) = "$realm-auth-realm";
    &main'debug("opening authentication file: $db");
    &main'open("auth'AUTH", $db) || die "$db: $!\n";
    while ($_ = <AUTH>) {
       chop;
       &main'debug("checking $_ for $user");
       return (split(/:/, $_)) if $_ =~ m/^$user:/;
    }
    &main'debug("get_uinfo failed!");
    return undef;
}

sub printable_decode
{
    $_[0] =~ s/(....)/&decode_aux($1)/ge;
}

sub decode_aux
{
    local(@n) = grep($_ = $enc[ord($_)], split(//, $_[0]));
    local(@m);
    $m[0] = ($n[0] << 2) | ($n[1] >> 4);
    $m[1] = (($n[1] & 0xf) << 4) | ($n[2] >> 2) if $n[2] >= 0;
    $m[2] = (($n[2] & 0x3) << 6) | $n[3]        if $n[3] >= 0;
    return pack("C*", @m);
}
