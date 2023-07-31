#!/usr/bin/env perl

# Name: WI mapping
# Purpose: Connecting to Shared drive to get the WI
# Author: Miroslaw Duraj
# Date: 30/Nov/2021
$version = '-1.5';

#use strict;
use Term::ANSIColor;
#use warnings;
use v5.10; # for say() function
use Time::Piece;
use File::Basename ();

$dir = File::Basename::dirname($0);
$logfile = "$0.log";
$time = localtime->datetime;
 
use DBI;
say "Perl MySQL Connect Database";
# MySQL database configuration
#'dsn0' is only used for checking if the SN of the machine exists in db
$dsn0 = "DBI:mysql:general:172.30.1.199";

$username = 'p3user';
$password = 'p3user';

######################################################################

$stn = substr(`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`,30,12);

system ("echo '$time\tWI mapping started\n' >> $logfile");

system "clear";
$dbh = DBI->connect($dsn0,$username,$password, \%attr) or handle_error (DBI::errstr);

commands();

check_sn($dbh);
checkVolume();
check_line();
check_mode($dbh);

if ($path eq '' || $path eq 'NA')
	{
		my $station = $stn;
		print ("Station: $stn\n");
		system ("echo '$time\t$stn\tNo path set up in db\n' >> $logfile");
		print color('bold red');
		print "$command1";
		print color('reset');
		print "$command0";
		<>;
		exit;
	} 

MOUNT:

while (1)
{
	system clear;
	print color('bold green');
	print "WI mapping$version - $station\n";
	print color('reset');

    $path = 'smb://172.30.1.199/MNF-WIs/'."$product/$mode/$path";
    $fullPath = '/usr/bin/osascript -e \'mount volume '."\"$path\"".'\'';
	
	system "$fullPath";
	
	$volume =~ s/\s/\\ /g;

if (system "cd /Volumes/$volume"){
	system clear;
	print color('bold green');
	print "WI mapping$version - $station\n";
	print color('bold red');
	print "Cannot find the correct path. Contact your Supervisor. Closing in 10 seconds...\n";
	print color('reset');
	sleep 10;
	exit;
}

	system `(open /Volumes/$volume/*.*)`;
	sleep 20;
    $unmountVolume = "/Volumes/$volume";
   
   	system `(diskutil unmountDisk force $unmountVolume)`;

    $killWICommand = 'kill $(ps aux | grep /Users/Shared/WI | grep -v \'grep /Users/Shared/WI\' | awk {\'print$2\'})';
    system "$killWICommand";
    exit;
		
}

#sub routines

sub commands{
	$command0 = "Contact Supervisor! Press Enter to continue...";
	$command1 = "Station has not been set up yet!\n";
	$command2 = "Wrong format of station setup.\n";
}

sub check_mode{
    # query from the links table
    ($dbh) = @_;
    $sql = "SELECT mode, product FROM modes
	WHERE line =('$line')";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
   
    my $ref;
    
    $ref = $sth->fetchall_arrayref([]);
    
    #print "Number of rows returned is ", 0 + @{$ref}, "\n";    
            foreach $data (@$ref)
            {
                ($mode, $product) = @$data;
            }
            
      $sth->finish;
    
    # disconnect from the MySQL database
    $dbh->disconnect();
}
sub check_sn{
    # query from the links table
    ($dbh) = @_;
    $sql = "SELECT station, serial_number, path FROM stations
	WHERE serial_number =('$stn')";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
   
    my $ref;
    
    $ref = $sth->fetchall_arrayref([]);
    
    #print "Number of rows returned is ", 0 + @{$ref}, "\n";    
            foreach $data (@$ref)
            {
                ($station, $serial, $path) = @$data;
            }
            
      $sth->finish;
    print "$path";
    # disconnect from the MySQL database
    $dbh->disconnect();
}

sub checkVolume{

	my ($str_begin ,$str_end , $nth_begin, $nth_end, $find, $p_begin, $p_end, $p);

	$str_begin = $path;
	$str_end = $path;
	$nth_begin = 1; $find = '/'; $nth_end = $nth_begin+1;

	$str_begin =~ m/(?:.*?$find){$nth_begin}/g;
	$str_end =~ m/(?:.*?$find){$nth_end}/g;
	$p_begin = pos($str_begin) - length($find) +1;
	$p_end = pos($str_end) - length($find);
    $lenVolume = length($str_end) - $p_begin;
	$p = ($p_end - $p_begin);
  	$volume = substr($str_begin, $p_begin, $lenVolume) if $p_begin>-1;
   
}

sub check_line{

	my ($str_begin ,$str_end , $nth_begin, $nth_end, $find, $p_begin, $p_end, $p);

	$str_begin = $station;
	$str_end = $station;
	$nth_begin = 1; $find = '_'; $nth_end = $nth_begin+1;

	$str_begin =~ m/(?:.*?$find){$nth_begin}/g;
	$str_end =~ m/(?:.*?$find){$nth_end}/g;
	$p_begin = pos($str_begin) - length($find) +1;
	$p_end = pos($str_end) - length($find);
	$p = ($p_end - $p_begin);

	$line = substr($str_begin, $p_begin, 4) if $p_begin>-1;
}

sub handle_error{
	print color('bold red');
	$time = localtime->datetime;
	system ("echo '$time\tUnable to connect to database\n' >> $logfile");
	print "Unable to connect to database. Contact your Supervisor\n";
	system ("afplay '$dir/wrongansr.wav'");
	print "Press Enter to close...\n";
	print color('reset');
	<>;
	exit;
}