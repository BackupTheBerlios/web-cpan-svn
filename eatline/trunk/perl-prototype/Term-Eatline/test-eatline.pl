#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use Term::Eatline;

my $eatline = Term::Eatline->new();

while (my $line = $eatline->readline())
{
    print "You've entered:\n{{{{\n$line\n}}}}\n";
}
