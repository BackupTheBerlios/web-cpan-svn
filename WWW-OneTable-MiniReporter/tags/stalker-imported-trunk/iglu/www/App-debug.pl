#!/usr/bin/perl -w

use lib '.';

use strict;
use MyConfig;

use Shlomif::MiniReporter;

my $webapp = Shlomif::MiniReporter->new(
    PARAMS => 
    {
        'config' => $MyConfig::config,
    },    
);
$webapp->run();

