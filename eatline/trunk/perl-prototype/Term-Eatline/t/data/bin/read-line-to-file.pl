#!/usr/bin/perl

use strict;
use warnings;

use blib;

use Term::Eatline;
use Getopt::Long;

my $out_file;
GetOptions(
    "o|output=s" => \$out_file,
);

if (!defined($out_file))
{
    die "output file not specified.";
}

my $line;
eval {
my $eatline = Term::Eatline->new();

$line = $eatline->readline();
};

if ($@)
{
    die $@;
}

open my $o, ">", $out_file;
print {$o} $line;
close($o);
