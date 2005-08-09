#!/usr/bin/perl -w

use lib '.';

use CGI;

use strict;
use MyConfig;
use Shlomif::MiniReporter;

my $q = new CGI;

my $r = Shlomif::MiniReporter->new($config, $q);

print $q->header();

print $r->add_form();
