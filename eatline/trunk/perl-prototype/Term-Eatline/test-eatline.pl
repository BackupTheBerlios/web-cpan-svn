#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use Term::Eatline;
use Curses;

eval {
my $eatline = Term::Eatline->new();

LINE_LOOP:
while (my $line = $eatline->readline())
{
    chomp($line);
    if ($line eq "")
    {
        last LINE_LOOP;
    }
    $eatline->_main_win()->printw("You've entered:{%s}\n", $line);
    $eatline->_main_win()->refresh();
}
};

if ($@)
{
    die $@;
}
