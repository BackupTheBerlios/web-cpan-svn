#!/usr/bin/perl -w

use lib '.';

use strict;

use CGI;
use Shlomif::MiniReporter;

use strict;

use MyConfig;

my $q = new CGI;

my $r = Shlomif::MiniReporter->new($config, $q);

print $q->header();

print $r->add_post();
