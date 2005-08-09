#!/usr/bin/perl 

use lib '.';

use strict;
use warnings;

use ConsultantsConfig;

use Shlomif::MiniReporter;

my $webapp = Shlomif::MiniReporter->new(
    PARAMS => 
    {
        'config' => $ConsultantsConfig::config,
    },
);
$webapp->run();

