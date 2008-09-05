#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use Term::Eatline;

{
    my $eat = Term::Eatline->new();

    $eat->_curr_line("ABCD");

    # TEST
    is ($eat->_line_len(), 4, 
        "_line_len() returns length of line"
    );

    {
        my $s = "Zing went the strings of my heart.";
        $eat->_curr_line(
            $s
        );

        # TEST
        is ($eat->_line_len, length($s),
            "_line_len() returns length of line after modification."
        );
    }
}
