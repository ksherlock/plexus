#!/usr/bin/perl
#
# archieplex.pl,v 2.6 1993/09/08 15:29:55 sanders Exp
#
# ArchiePlex: Archie search to HTML in Perl
# Version 1.2
# Date: Thu Sep 23 14:54:05 BST 1993
#
# Martijn Koster (m.koster@nexor.co.uk)
# Improvements by Tony Sanders (sanders@earth.com)
# Bug fixes and a little error checking, and modified to never use the shell
#  (for security reasons) by Bill Fenner (fenner@cmf.nrl.navy.mil)
#
# This program is placed in the public domain;
# you are free to redistribute it without restriction,
# but it would be nice if you would leave the credits
# and mention any changes you've made from the original.
#
# Known bugs: sometimes I get a "Error: panic: restorelist inconsistency"
#
# Requires archie command line client, tested with
# "Client version 1.4.1 based upon Prospero version Beta.4.2E with debugging."

# To install in Plexus 3.0, add the following lines to your local.conf file:
#     load archieplex.pl
#     map archieplex archieplex.pl &do_archieplex($path, $top, $rest, $query)
# To install in previous versions of Plexus add similar lines to plexus.conf

package archieplex;

# Configuration

$archie		= "../bin/archie";
$archie_timeout = 240;
$defaultserver	= "archie.sura.net";
$maintainer	= "<A HREF=\"/mak/mak.html\">Martijn Koster</A>";
$info		= "<A HREF=\"http://web.nexor.co.uk/archieplex-info/info.html\">ArchiePlex info</A>.";
$servers	= "http://web.nexor.co.uk/archie.html";
		
# associations between types and archie commandline arguments

$args{"by-host"}     = "";
$args{"by-date"}     = "-t";

$args{"exact"}	     = "-e";
$args{"substring"}   = "-s";
$args{"subcase"}     = "-c";
$args{"regexp"}      = "-r";

# idem for titles
			       
$titles{"by-host"}   = "";
$titles{"by-date"}   = " by Date";

$titles{"exact"}     = "ArchiePlex Exact Search";
$titles{"substring"} = "ArchiePlex Substring Search";
$titles{"subcase"}   = "ArchiePlex Case Insensitive Substring Search";
$titles{"regexp"}    = "ArchiePlex Regular Expression Search";

# the archieplex subroutine (exported to package main)

sub main'do_archieplex
{
    # $top is the first component of the url, indicating the gateway selector, e.g. "archieplex"
    # $rest is the rest of the URL, e.g. "archie.sura.net/substring/by-host"
    # $simple is $top/$rest
    # $query is a list of search words separated by +, e.g. "gnu+pcnfsd.c"
    local($simple, $top, $rest, $query) = @_;

    # in ArchiePlex a URL $rest looks like <server>/<type>/<order>
    # where server is a domain name or IP address
    # and type is one of "exact", "substring", "subcase", or "regexp"
    #
    # e.g.:  http://web.nexor.co.uk/archieplex/
    #        http://web.nexor.co.uk/archieplex/archie.sura.net/subcase/by-host
    local($server, $type, $order) = split('/', $rest);
    
    $server = $defaultserver if ($server eq "default" || !$server);
    $order = "by-host" if (!defined($args{$order}));
    $type = "substring" if (!defined($args{$type}));

    # A title consists of the type title and the order title
    local($title) = $titles{$type} . $titles{$order};

    $query ? &archie_data : &archie_index;

    print "<P>________________________________________\n";
    print "<ADDRESS>$maintainer</ADDRESS>\n";
    print "</BODY>\n";
}

sub archie_data {
    local(@terms) = &main'splitquery($query);
    $pquery = join(',', @terms);

    pipe(ARCHIE_IN,WFD);
    if (($cpid = fork()) == 0) {
	close(ARCHIE_IN);
	open(STDOUT,">&WFD");
	open(STDERR,">&WFD");
	# construct archie command line. The -l produces a
	# one-file-per-line parseable listing.
	@cmd=("archie","-l","-h",$server);
	push(@cmd,$args{$type}) if ($args{$type});
	push(@cmd,$args{$order}) if ($args{$order});
	push(@cmd,"--",@terms);
	exec $archie @cmd;
	die "exec: $archie: $!\n";
    }
    close(WFD);
        
    $savesig=$main'SIG{'ALRM'};
    $main'SIG{'ALRM'}="archieplex'archie_timeout";	# sigh.  children are such a pain.
    alarm($archie_timeout);			# archie searches take a while...

    # process results

    $cachedline=<ARCHIE_IN>;
    if ($cachedline =~ s/^\S+ failed://) {
	if ($cachedline =~ /Timed out/)
	{
		print "<TITLE>Archie Timeout</TITLE>\n";
		print "<H1>Archie Timeout</H1>\n";
		print "The Archie Server on <CODE>$server</CODE> timed out.\n";
		print "<P>You might want to try a simpler search, or use another server ";
		print "(See the <A HREF=\"$servers\">List of Hypertext servers</A>).";

		return 1;
	}
	else
	{
	&main'error('internal_error',
"<B>Archie failed</B> for $pquery at <CODE>$server</CODE>: $cachedline");
	}
    }
    if ($cachedline =~ /^Usage:/) {
	&main'error('internal_error',"Badly formed request");
    }
    if ($cachedline =~ /^exec:/) {
	&main'error('internal_error',$cachedline);
    }
				
    &main'MIME_header('ok', 'text/html');

    if ($timeoutexceeded)
    {
	print "<TITLE>ArchiePlex Timeout</TITLE>\n";
	print "<H1>ArchiePlex Timeout</H1>\n";
	print "The Archie Server on <CODE>$server</CODE> has not responded ";
	print "withing $archie_timeout seconds.\n";
	print "<P>You might want to try a simpler search, or use another server ";
	print "(See the <A HREF=\"$servers\">List of Hypertext servers</A>).";

	return 1;
    }

    print "<HEAD>\n<TITLE>Result for $title</TITLE>\n</HEAD>\n<BODY>\n";
    print "<H1>Result for $title</H1>\n";

    print "These are the results found for the\n";
    print "<A HREF=\"/$top/$server/$type/$order\">$titles{$type}$titles{$order}</A>\n";
    print "for <CODE>$pquery</CODE>\n";

    while($_ = ($cachedline || <ARCHIE_IN>)) {
	chop;
	undef $cachedline;
	local($datetime, $size, $host, $path) = split;
	local($date_fields) = 'A4 A2  A2 A2 A2 A2';	# fixed width date fields
	local($year, $month, $day, $hour, $min, $sec) = unpack($date_fields, $datetime);
	$year = $year - 1900 if ($year >= 1900 && $year < 2000);
	local($datedescription) = "$day-$month-$year";

	# maintain sections per host

	if ($host ne $lasthost) {
	    print "</UL>\n" if $lasthost;		# terminate last list
	    print "<H2><A HREF=\"file://$host/\">$host</A></H2>";
	    print "<UL>\n";

	    $lasthost = $host;
	}

	# print per-line info

	if ($path=~/\/$/) {				# it's a directory
	    chop $path;
	    print "<LI>Directory <A HREF=\"file://$host$path\">$path</A> ($datedescription)\n";
	} else {
	    # split path from file

	    local(@comps) = split('/', $path);
	    local($file) = pop(@comps);
	    local($location) = join('/', @comps);

	    local($sizedescription) = "$size bytes";
	    $sizedescription =  int($size / 1000) . "K" if ($size > 1000);
	    $sizedescription = int($size / 1000000) . "M" if ($size > 1000000);

	    print "<LI>\n";
	    print "<A HREF=\"file://$host$path\">$file</A> $sizedescription ($datedescription) in\n";
	    print "<A HREF=\"file://$host$location/\">$location/</A>\n";
	}
    }
    $main'SIG{'ALRM'}=$savesig;
    $lasthost ? print "</UL>\n" : print "<P>No items found.\n";
}

sub archie_index {
    &main'MIME_header('ok', 'text/html');
    print "<HEAD>\n<ISINDEX>\n";
    print "<TITLE>$title</TITLE>\n</HEAD>\n<BODY>";
    print "<H1>$title</H1>\n";

    print "ArchiePlex locates files available for anonymous FTP.\n";
    print "This service uses the Archie server at <CODE>$server</CODE>\n";
    print "to execute the searches.\n";
    print "For more information see $info\n";

    print "<P>Please specify a search term.\n";
    print "<P>See also:\n";

    print "<UL>\n";
    ($order eq "by-date")  && print "<LI><A HREF=\"/$top/$server/$type/by-host\">This search sorted by Host</A>\n";
    ($order eq "by-host")  && print "<LI><A HREF=\"/$top/$server/$type/by-date\">This search sorted by Date</A>\n";
    ($type ne "substring") && print "<LI><A HREF=\"/$top/$server/substring/$order\">$titles{substring}$titles{$order}</A>\n";
    ($type ne "subcase")   && print "<LI><A HREF=\"/$top/$server/subcase/$order\">$titles{subcase}$titles{$order}</A>\n";
    ($type ne "exact")     && print "<LI><A HREF=\"/$top/$server/exact/$order\">$titles{exact}$titles{$order}</A>\n";
    print "</UL>\n";
}

sub archie_timeout {
    kill 15,$cpid if $cpid;	# Kill the archie that we spawned

#    &main'error('internal_error',
#	    "Archie Server timed out after $archie_timeout seconds.");

    $timeoutexceeded = 1;
}

1;
