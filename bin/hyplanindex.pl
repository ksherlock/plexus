#!/usr/bin/perl

require "sys/file.ph";

$( = $) = (getgrnam("www"))[2];

$hyplan_dir = "/usr/local/www/hyplan";

sub process_passwd {
    local($machine) = @_;
    local($login, $passwd, $uid, $gid, $gcos, $home, $shell);

    open(PASSWD,"/nfs/$machine/etc/passwd") || 
	die "Cannot open passwd file for $machine, $!";
  USER:
    while(<PASSWD>) {
	($login, $passwd, $uid, $gid, $gcos, $home, $shell) =
	    split(":");

	next USER if(defined $hyplanned{$login});
	
	if(-r "/nfs/$machine/$home/.hyplan.html") {
	    unlink("$hyplan_dir/$login.html") || warn "New hyplan for $login";
	    symlink("/nfs/$machine/$home/.hyplan.html",
		    "$hyplan_dir/$login.html");
	    if(-d "/nfs/$machine/$home/.hyplan") {
		unlink("$hyplan_dir/$login")
		    || warn "New hyplan-dir for $login";
		symlink("/nfs/$machine/$home/.hyplan",
			"$hyplan_dir/$login");
	    }
	    ($hyplanned{$login} = $gcos) =~ s/,.*//;
	}
    }
    close PASSWD;
}

sub generate_pointer {
    local($i);

    $i = 1;
    open(PFH, "> /usr/local/www/hyplan/directory.html");
    flock(PFH, &LOCK_EX);
    select PFH;
    print '<TITLE>IUCS hyplan directory</TITLE>', "\n";
    print '<H1>Computer Science Department Hyplan Directory</H1>', "\n";
    print '<UL>', "\n";
    foreach $user (sort(keys %hyplanned)) {
	print '<LI> <A NAME=', $i++, ' HREF="', $user, '.html">',
	"$hyplanned{$user} ($user)", '</A>', "\n";
    }
    print '</UL>', "\n";
    close PFH;
}

 
#opendir(HYPLAN, $hyplan_dir);
#unlink(grep(!/^\./, readdir(HYPLAN)));
#closedir(HYPLAN);

&process_passwd("moose");
&process_passwd("whale");
&process_passwd("kiwi");

&generate_pointer();
