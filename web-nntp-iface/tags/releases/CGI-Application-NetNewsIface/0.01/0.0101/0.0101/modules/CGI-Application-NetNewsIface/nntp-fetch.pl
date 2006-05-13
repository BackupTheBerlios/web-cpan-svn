#!/usr/bin/perl

use strict;
use warnings;

use Net::NNTP;

use Data::Dumper;

my $nntp = Net::NNTP->new("nntp.perl.org");
my $index = shift;

my %in = 
(
    'perl.qa' => [
        # Generator for Module-Installing Makefiles
        5796,5798,5799,

        # Non-Perl TAP Implementations
        (5826 .. 5830), (5832 .. 5835), 5838,5839, (5842 .. 5852),
        ],
    'perl.advocacy' => [
        # Perl Dress Code
        (2218 .. 2222)
    ],
);

my %out;
foreach my $group (keys(%in))
{
    $nntp->group($group);
    my $ind = 1;
    $out{$group} = 
    { 
        map 
        { 
            ($ind++) => +{'head' => $nntp->head($_) }, 
        } 
        sort
        { $a <=> $b }
        @{$in{$group}}
    };
}

my $d = Data::Dumper->new([\%out], ['$data']);
$d->Useqq(1);
print $d->Dump();

