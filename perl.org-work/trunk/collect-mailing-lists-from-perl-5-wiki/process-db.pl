#!/usr/bin/perl

use strict;
use warnings;

use Common;
use YAML::XS qw(LoadFile DumpFile);
use DBIx::Simple;
# use autodie qw(:all);

# Load the database.
system("mysql " . Common::get_mysql_db_name() . "< lists.sql");

my $db = DBIx::Simple->connect(
    "dbi:mysql:localhost:" . Common::get_mysql_db_name(), 
    scalar(getpwuid($<)), 
    $ENV{'MYSQL_PASSWORD'},
);

my $yaml = LoadFile(Common::get_yaml_fn());

foreach my $page (keys(%$yaml))
{
    my $page_mls = $yaml->{$page}->{'mailing_lists'};

    foreach my $ml (@$page_mls)
    {
        my $description = $ml->{'desc'};
        my $items_raw = $ml->{'items'};

        my $items = 
        {
            map 
            { $_->{'canon_key'} => $_ } 
            @$items_raw
        };

        my $name = $items->{'basename'}->{'value_content'};

        if (!defined($name))
        {
            die "The name of Page '$page' and ML '$description' is undefined!";
        }
        # print "$name\n";
    }
}
