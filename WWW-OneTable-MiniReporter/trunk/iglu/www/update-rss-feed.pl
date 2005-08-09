#!/usr/bin/perl

use strict;
use warnings;

use MyConfig;
use Shlomif::MiniReporter;

my $webapp = Shlomif::MiniReporter->new(
    PARAMS =>
    {
        'config' => $MyConfig::config,
    },
);
$webapp->update_rss_feed($webapp->dbi_connect());

