#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Playerian' );
}

diag( "Testing App::Playerian $App::Playerian::VERSION, Perl $], $^X" );
