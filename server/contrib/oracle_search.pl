#!/usr/local/bin/oraperl
# oracle_search.pl -- search the oracle database
#
# $Id: oracle_search.pl,v 2.2 1993/10/02 06:13:27 sanders Exp $
#
# Guy Decoux <decoux@moulon.inra.fr>, Sept 1993
#
$statement = ($statement)?$statement:'select * from emp';
$database  = ($database)?$database:'A';
$user      = ($user)?$user:'scott';
$password  = ($password)?$password:'tiger';
$maxselect = ($maxselect)?$maxselect:40;
$list      = ($list)?$list:'@column';
$statement =~ s/<unesc>/@ARGV/gi;

$lda = &ora_login($database,$user,$password) || &oracle_erreur($ora_errstr);
$csr = &ora_open($lda,$statement) || &oracle_erreur($ora_errstr);
while (($maxselect--) && (@column = &ora_fetch($csr))) { 
  printf $format,eval $list; 
}
warn $ora_errstr if $ora_errno;
&oracle_erreur("fetch error: $ora_errstr") if $ora_errno;
do ora_close($csr) || &oracle_erreur("can't close cursor");
do ora_logoff($lda) || &oracle_erreur("can't log off Oracle");

sub oracle_erreur {
  print "OraPlex Error :",@_,"<p>",$statement;
  exit 3;
}

1;
