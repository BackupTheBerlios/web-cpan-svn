#!/usr/bin/perl

use strict;
use warnings;

use Common;
use YAML::XS qw(LoadFile DumpFile);
use DBIx::Simple;
# Load the database.
system("mysql " . Common::get_mysql_db_name() . "< lists.sql");

my $db = DBIx::Simple->connect(
    "dbi:mysql:localhost:" . Common::get_mysql_db_name(), 
    scalar(getpwuid($<)), 
    $ENV{'MYSQL_PASSWORD'},
);

my $yaml = LoadFile(Common::get_yaml_fn());


