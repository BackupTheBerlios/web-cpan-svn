#!/usr/bin/perl

use lib '.';

use strict;
use warnings;

use MyConfig;
use Shlomif::MiniReporter;

my $config = $MyConfig::config;
my $webapp = Shlomif::MiniReporter->new(
    PARAMS =>
    {
        'config' => $config,
    },
);

my $dbh = $webapp->_get_dbh();

$dbh->do("CREATE TABLE " . $config->{text_table_name} . " (id INTEGER PRIMARY KEY, mytext TEXT)");

$webapp->update_texts_for_all_records();
