#!/usr/bin/perl -w

use strict;

use Test::More tests => 1;

$ENV{'PERL5DB_LT'} = "t/input/cancelled_trace.txt";

my $output = `perl -d:LineTrace t/scripts/script1.pl`;

ok($output eq "\$i=5\n\$j=150\n");

