#!/usr/bin/perl -w

use strict;

use DBI;
use MyConfig;
use POSIX;
my $dbh = DBI->connect($MyConfig::config->{'dsn'});

# Probably better done with one of them date modules
my @time = localtime(time());
# Find the date 8 months back
$time[4] -= 8;
if ($time[4] < 0)
{
    $time[4] += 12;
    $time[5]--;
}
my $date = POSIX::strftime("%Y-%m-%d", @time);
my $query = "UPDATE jobs2 SET status=1 WHERE post_date < '$date'";
# print $query;
$dbh->do($query);


